create or replace function public.create_user_profile()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  owner_name text := nullif(btrim(new.raw_user_meta_data ->> 'name'), '');
  owner_phone text := nullif(btrim(new.raw_user_meta_data ->> 'phone'), '');
begin
  insert into public.user_profiles (id, email, role, owner_id)
  values (new.id, coalesce(new.email, ''), 'dueno', new.id)
  on conflict (id) do nothing;

  if owner_name is not null and owner_phone is not null then
    insert into public.owners (id, owner_id, name, phone, email)
    values (new.id::text, new.id, owner_name, owner_phone, new.email)
    on conflict (id) do nothing;
  end if;

  return new;
end;
$$;
