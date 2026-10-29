-- Funciones auxiliares de autorización, creación de perfiles y protección de datos.
create or replace function public.user_is_personal_for_company(target_company text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.user_profiles profile
    where profile.id = auth.uid()
      and profile.role = 'personal'
      and profile.company_id = target_company
  );
$$;
comment on function public.user_is_personal_for_company(text) is
  'Comprueba si el usuario autenticado pertenece al personal de la clínica indicada.';

create or replace function public.set_visit_owner()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.owner_id is null then
    select pet.owner_id
      into new.owner_id
      from public.pets pet
      where pet.id = new.pet_id;
  end if;
  return new;
end;
$$;
comment on function public.set_visit_owner() is
  'Completa el dueño de una visita a partir del dueño registrado en la mascota cuando no se indicó uno.';

create or replace function public.staff_can_access_pet(target_pet_id text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.visits visit
    where visit.pet_id = target_pet_id
      and public.user_is_personal_for_company(visit.company_id)
  );
$$;
comment on function public.staff_can_access_pet(text) is
  'Comprueba si el personal de alguna clínica asignada a una visita puede acceder a la mascota.';

create or replace function public.create_user_profile()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.user_profiles (id, email, role, owner_id)
  values (new.id, coalesce(new.email, ''), 'dueno', new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;
comment on function public.create_user_profile() is
  'Crea el perfil inicial con rol de dueño cuando se registra una cuenta en Supabase Auth.';

create or replace function public.prevent_profile_role_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if coalesce(auth.role(), '') <> 'service_role'
    and (
      new.role is distinct from old.role
      or new.owner_id is distinct from old.owner_id
      or new.company_id is distinct from old.company_id
    ) then
    raise exception 'Profile authorization fields cannot be changed by the client';
  end if;
  return new;
end;
$$;
comment on function public.prevent_profile_role_change() is
  'Impide que el cliente cambie el rol o las asociaciones de dueño y clínica de un perfil.';

create or replace function public.user_owns_pet(target_pet_id text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.pets pet
    where pet.id = target_pet_id
      and pet.owner_id = auth.uid()
  );
$$;
comment on function public.user_owns_pet(text) is
  'Comprueba si la mascota indicada pertenece al usuario autenticado.';

create or replace function public.protect_visit_updates()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  old_level integer;
  new_level integer;
begin
  if coalesce(auth.role(), '') <> 'service_role' then
    if new.pet_id is distinct from old.pet_id
      or new.owner_id is distinct from old.owner_id
      or new.company_id is distinct from old.company_id then
      raise exception 'Visit ownership and clinic cannot be changed by the client';
    end if;

    if auth.uid() = old.owner_id
      and (
        new.triage is distinct from old.triage
        or new.status is distinct from old.status
        or new.assigned_room is distinct from old.assigned_room
        or new.assigned_veterinarian is distinct from old.assigned_veterinarian
        or new.position is distinct from old.position
      ) then
      raise exception 'Only clinic staff can update triage or queue fields';
    end if;

    if public.user_is_personal_for_company(old.company_id) then
      old_level := case old.triage->>'suggested'
        when 'consulta' then 1
        when 'urgencia' then 2
        when 'emergencia' then 3
        else 0
      end;
      new_level := case new.triage->>'suggested'
        when 'consulta' then 1
        when 'urgencia' then 2
        when 'emergencia' then 3
        else 0
      end;
      if new_level < old_level then
        raise exception 'Suggested triage level cannot be lowered';
      end if;
    end if;
  end if;
  return new;
end;
$$;
comment on function public.protect_visit_updates() is
  'Protege la propiedad y asignación clínica de una visita, y evita que el personal rebaje el nivel sugerido de triaje.';
