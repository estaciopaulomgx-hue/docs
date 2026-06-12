-- Run this in the Supabase SQL editor

-- 1) Table for uploaded document records
create table if not exists public.uploads (
  id uuid primary key default gen_random_uuid(),
  file_name   text not null,
  file_type   text,
  file_size   bigint,
  storage_path text not null,
  storage_url  text not null,
  uploaded_at  timestamptz not null default now()
);

alter table public.uploads enable row level security;

-- Demo policies (open). Tighten for production.
drop policy if exists "uploads_read"   on public.uploads;
drop policy if exists "uploads_insert" on public.uploads;
drop policy if exists "uploads_delete" on public.uploads;

create policy "uploads_read"   on public.uploads for select using (true);
create policy "uploads_insert" on public.uploads for insert with check (true);
create policy "uploads_delete" on public.uploads for delete using (true);

-- 2) Storage bucket (public so download links work directly)
insert into storage.buckets (id, name, public)
values ('documents', 'documents', true)
on conflict (id) do update set public = true;

-- Storage policies for the bucket
drop policy if exists "documents_read"   on storage.objects;
drop policy if exists "documents_insert" on storage.objects;
drop policy if exists "documents_delete" on storage.objects;

create policy "documents_read"
  on storage.objects for select
  using (bucket_id = 'documents');

create policy "documents_insert"
  on storage.objects for insert
  with check (bucket_id = 'documents');

create policy "documents_delete"
  on storage.objects for delete
  using (bucket_id = 'documents');

-- 3) Realtime
alter publication supabase_realtime add table public.uploads;
