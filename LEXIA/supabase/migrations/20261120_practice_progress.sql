-- Allows an authenticated student to record their own completed practice exercise.
create policy "progress student write" on public.progress_history
for insert with check (student_id = auth.uid());
