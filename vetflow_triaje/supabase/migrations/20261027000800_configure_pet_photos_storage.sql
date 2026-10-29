-- Bucket privado para fotos de mascotas y políticas de acceso a sus archivos.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('pet-photos', 'pet-photos', false, 5242880, array['image/jpeg', 'image/png'])
on conflict (id) do update
set public = false,
    file_size_limit = 5242880,
    allowed_mime_types = array['image/jpeg', 'image/png'];

drop policy if exists "owners read own pet photos" on storage.objects;
create policy "owners read own pet photos"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'pet-photos'
    and (storage.foldername(name))[1] = 'mascotas'
    and (
      public.user_owns_pet((storage.foldername(name))[2])
      or public.staff_can_access_pet((storage.foldername(name))[2])
    )
  );
drop policy if exists "owners upload own pet photos" on storage.objects;
create policy "owners upload own pet photos"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'pet-photos'
    and (storage.foldername(name))[1] = 'mascotas'
    and (storage.foldername(name))[3] = 'fotos'
    and public.user_owns_pet((storage.foldername(name))[2])
    and metadata->>'mimetype' in ('image/jpeg', 'image/png')
    and coalesce((metadata->>'size')::bigint, 0) <= 5242880
  );
drop policy if exists "owners delete own pet photos" on storage.objects;
create policy "owners delete own pet photos"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'pet-photos'
    and (storage.foldername(name))[1] = 'mascotas'
    and public.user_owns_pet((storage.foldername(name))[2])
  );
