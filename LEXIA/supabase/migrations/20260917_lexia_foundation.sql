-- LEXIA foundation. Run in the Supabase SQL editor or via the Supabase CLI.
create type public.user_role as enum ('student', 'parent_guardian', 'teacher');
create type public.article_source as enum ('pasted', 'upload', 'ai_simplified');
create type public.assessment_kind as enum ('word_recognition', 'spelling', 'reading_passage', 'voice_reading');
create type public.assessment_status as enum ('draft', 'in_progress', 'submitted', 'analysed');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  role public.user_role not null default 'student',
  avatar_url text,
  reading_preferences jsonb not null default '{"font":"atkinson","font_size":1,"letter_spacing":"normal","line_spacing":"comfortable","page_tint":"lavender","focus_mode":false}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.articles (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  title text not null default 'Untitled article',
  original_text text not null,
  simplified_text text,
  simplification_level text check (simplification_level in ('basic', 'easier', 'very_simple')),
  source public.article_source not null default 'pasted',
  storage_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.reading_history (
  id bigint generated always as identity primary key,
  student_id uuid not null references public.profiles(id) on delete cascade,
  article_id uuid references public.articles(id) on delete set null,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  progress_percent integer not null default 0 check (progress_percent between 0 and 100)
);

create table public.assessments (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  kind public.assessment_kind not null,
  status public.assessment_status not null default 'draft',
  title text not null,
  started_at timestamptz,
  submitted_at timestamptz,
  duration_seconds integer,
  created_at timestamptz not null default now()
);

create table public.answers (
  id uuid primary key default gen_random_uuid(),
  assessment_id uuid not null references public.assessments(id) on delete cascade,
  item_key text not null,
  response jsonb not null,
  is_correct boolean,
  created_at timestamptz not null default now(),
  unique (assessment_id, item_key)
);

create table public.scores (
  id uuid primary key default gen_random_uuid(),
  assessment_id uuid not null unique references public.assessments(id) on delete cascade,
  overall_score numeric(5,2) check (overall_score between 0 and 100),
  breakdown jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.error_patterns (
  id uuid primary key default gen_random_uuid(),
  assessment_id uuid not null references public.assessments(id) on delete cascade,
  pattern_key text not null,
  severity text not null check (severity in ('low', 'medium', 'high')),
  description text not null,
  occurrences integer not null default 0 check (occurrences >= 0),
  created_at timestamptz not null default now()
);

create table public.recommendations (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  assessment_id uuid references public.assessments(id) on delete set null,
  title text not null,
  content text not null,
  priority text not null default 'medium' check (priority in ('low', 'medium', 'high')),
  created_at timestamptz not null default now(),
  dismissed_at timestamptz
);

create table public.progress_history (
  id bigint generated always as identity primary key,
  student_id uuid not null references public.profiles(id) on delete cascade,
  metric_key text not null,
  metric_value numeric(8,2) not null,
  recorded_at timestamptz not null default now()
);

create table public.student_links (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  observer_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(student_id, observer_id),
  check(student_id <> observer_id)
);

-- Private uploads; object names must start with the authenticated user's UUID.
insert into storage.buckets (id, name, public) values ('article-files', 'article-files', false)
on conflict (id) do nothing;

create or replace function public.is_linked_observer(target_student uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.student_links l join public.profiles p on p.id = l.observer_id
    where l.student_id = target_student and l.observer_id = auth.uid()
      and p.role in ('parent_guardian', 'teacher')
  );
$$;

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, full_name, role)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', ''), coalesce((new.raw_user_meta_data->>'role')::public.user_role, 'student'));
  return new;
end; $$;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.articles enable row level security;
alter table public.reading_history enable row level security;
alter table public.assessments enable row level security;
alter table public.answers enable row level security;
alter table public.scores enable row level security;
alter table public.error_patterns enable row level security;
alter table public.recommendations enable row level security;
alter table public.progress_history enable row level security;
alter table public.student_links enable row level security;

create policy "profiles self or linked observer" on public.profiles for select using (id = auth.uid() or public.is_linked_observer(id));
create policy "profiles update self" on public.profiles for update using (id = auth.uid()) with check (id = auth.uid());
create policy "articles owner" on public.articles for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "history self or observer" on public.reading_history for select using (student_id = auth.uid() or public.is_linked_observer(student_id));
create policy "history student write" on public.reading_history for insert with check (student_id = auth.uid());
create policy "history student update" on public.reading_history for update using (student_id = auth.uid()) with check (student_id = auth.uid());
create policy "assessments self or observer" on public.assessments for select using (student_id = auth.uid() or public.is_linked_observer(student_id));
create policy "assessments student write" on public.assessments for all using (student_id = auth.uid()) with check (student_id = auth.uid());
create policy "answers if assessment visible" on public.answers for select using (exists (select 1 from public.assessments a where a.id = assessment_id and (a.student_id = auth.uid() or public.is_linked_observer(a.student_id))));
create policy "answers student write" on public.answers for all using (exists (select 1 from public.assessments a where a.id = assessment_id and a.student_id = auth.uid())) with check (exists (select 1 from public.assessments a where a.id = assessment_id and a.student_id = auth.uid()));
create policy "scores if assessment visible" on public.scores for select using (exists (select 1 from public.assessments a where a.id = assessment_id and (a.student_id = auth.uid() or public.is_linked_observer(a.student_id))));
create policy "patterns if assessment visible" on public.error_patterns for select using (exists (select 1 from public.assessments a where a.id = assessment_id and (a.student_id = auth.uid() or public.is_linked_observer(a.student_id))));
create policy "recommendations self or observer" on public.recommendations for select using (student_id = auth.uid() or public.is_linked_observer(student_id));
create policy "recommendations self update" on public.recommendations for update using (student_id = auth.uid()) with check (student_id = auth.uid());
create policy "progress self or observer" on public.progress_history for select using (student_id = auth.uid() or public.is_linked_observer(student_id));
create policy "links participant read" on public.student_links for select using (student_id = auth.uid() or observer_id = auth.uid());
-- Links must be created by an invitation/approval flow through a trusted server action.
-- Do not grant direct client inserts: otherwise an observer could attach any student.
create policy "links observer delete" on public.student_links for delete using (observer_id = auth.uid());

create policy "article files owner read" on storage.objects for select using (
  bucket_id = 'article-files' and (storage.foldername(name))[1] = auth.uid()::text
);
create policy "article files owner upload" on storage.objects for insert with check (
  bucket_id = 'article-files' and (storage.foldername(name))[1] = auth.uid()::text
);
create policy "article files owner update" on storage.objects for update using (
  bucket_id = 'article-files' and (storage.foldername(name))[1] = auth.uid()::text
);
create policy "article files owner delete" on storage.objects for delete using (
  bucket_id = 'article-files' and (storage.foldername(name))[1] = auth.uid()::text
);

create index articles_owner_created_idx on public.articles(owner_id, created_at desc);
create index assessments_student_created_idx on public.assessments(student_id, created_at desc);
create index progress_student_recorded_idx on public.progress_history(student_id, recorded_at desc);
