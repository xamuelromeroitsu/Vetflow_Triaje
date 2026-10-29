-- Triggers que aplican las funciones al guardar perfiles y visitas.
drop trigger if exists set_visit_owner_before_write on public.visits;
create trigger set_visit_owner_before_write
  before insert or update of pet_id on public.visits
  for each row execute function public.set_visit_owner();

drop trigger if exists on_auth_user_created_profile on auth.users;
create trigger on_auth_user_created_profile
  after insert on auth.users
  for each row execute function public.create_user_profile();

drop trigger if exists prevent_profile_role_change on public.user_profiles;
create trigger prevent_profile_role_change
  before update on public.user_profiles
  for each row execute function public.prevent_profile_role_change();

drop trigger if exists protect_visit_updates on public.visits;
create trigger protect_visit_updates
  before update on public.visits
  for each row execute function public.protect_visit_updates();

-- Políticas de acceso por fila (RLS) para las tablas de la aplicación.
alter table public.user_profiles enable row level security;
alter table public.owners enable row level security;
alter table public.pets enable row level security;
alter table public.visits enable row level security;
alter table public.clinics enable row level security;

drop policy if exists "read own profile" on public.user_profiles;
create policy "read own profile"
  on public.user_profiles for select to authenticated
  using (id = auth.uid());
drop policy if exists "insert own owner profile" on public.user_profiles;
create policy "insert own owner profile"
  on public.user_profiles for insert to authenticated
  with check (id = auth.uid() and role = 'dueno');
drop policy if exists "update own profile" on public.user_profiles;
create policy "update own profile"
  on public.user_profiles for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

drop policy if exists "owner reads own owner record" on public.owners;
create policy "owner reads own owner record"
  on public.owners for select to authenticated
  using (owner_id = auth.uid());
drop policy if exists "owner creates own owner record" on public.owners;
create policy "owner creates own owner record"
  on public.owners for insert to authenticated
  with check (owner_id = auth.uid() and id = auth.uid()::text);
drop policy if exists "owner updates own owner record" on public.owners;
create policy "owner updates own owner record"
  on public.owners for update to authenticated
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid() and id = auth.uid()::text);

drop policy if exists "owners and assigned staff read pets" on public.pets;
create policy "owners and assigned staff read pets"
  on public.pets for select to authenticated
  using (
    owner_id = auth.uid()
    or public.staff_can_access_pet(id)
  );
drop policy if exists "owners create own pets" on public.pets;
create policy "owners create own pets"
  on public.pets for insert to authenticated
  with check (owner_id = auth.uid());
drop policy if exists "owners update own pets" on public.pets;
create policy "owners update own pets"
  on public.pets for update to authenticated
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

drop policy if exists "owners and clinic staff read visits" on public.visits;
create policy "owners and clinic staff read visits"
  on public.visits for select to authenticated
  using (
    owner_id = auth.uid()
    or public.user_is_personal_for_company(company_id)
  );
drop policy if exists "owners create own visits" on public.visits;
create policy "owners create own visits"
  on public.visits for insert to authenticated
  with check (
    owner_id = auth.uid()
    and public.user_owns_pet(pet_id)
  );
drop policy if exists "owners and clinic staff update visits" on public.visits;
create policy "owners and clinic staff update visits"
  on public.visits for update to authenticated
  using (
    owner_id = auth.uid()
    or public.user_is_personal_for_company(company_id)
  )
  with check (
    owner_id = auth.uid()
    or public.user_is_personal_for_company(company_id)
  );

drop trigger if exists prevent_owner_triage_confirmation on public.visits;

drop policy if exists "authenticated users read clinics" on public.clinics;
create policy "authenticated users read clinics"
  on public.clinics for select to authenticated
  using (true);
drop policy if exists "clinic staff manage own clinic" on public.clinics;
create policy "clinic staff manage own clinic"
  on public.clinics for all to authenticated
  using (public.user_is_personal_for_company(id))
  with check (public.user_is_personal_for_company(id));
