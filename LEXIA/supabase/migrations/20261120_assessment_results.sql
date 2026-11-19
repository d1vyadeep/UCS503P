-- Allows a student to persist the result of an assessment they own.
create policy "scores student write" on public.scores
for insert with check (
  exists (select 1 from public.assessments a where a.id = assessment_id and a.student_id = auth.uid())
);

create policy "patterns student write" on public.error_patterns
for insert with check (
  exists (select 1 from public.assessments a where a.id = assessment_id and a.student_id = auth.uid())
);

create policy "recommendations student write" on public.recommendations
for insert with check (student_id = auth.uid());
