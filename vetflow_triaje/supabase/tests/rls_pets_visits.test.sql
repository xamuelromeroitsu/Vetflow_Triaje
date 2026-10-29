begin;

create extension if not exists pgtap with schema extensions;
select plan(16);

insert into auth.users (
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at
)
values
  (
    '10000000-0000-4000-8000-000000000001',
    'authenticated',
    'authenticated',
    'rls-owner-a@example.invalid',
    '',
    now(),
    now(),
    now()
  ),
  (
    '10000000-0000-4000-8000-000000000002',
    'authenticated',
    'authenticated',
    'rls-owner-b@example.invalid',
    '',
    now(),
    now(),
    now()
  )
on conflict (id) do nothing;

set local role authenticated;
select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-4000-8000-000000000001',
  true
);

select lives_ok(
  $$
    insert into public.pets (id, owner_id, name, species, breed, age_months)
    values (
      'rls-pet-owner-a',
      auth.uid(),
      'Prueba RLS',
      'perro',
      'Mestizo',
      12
    )
  $$,
  'el dueño autenticado puede crear su mascota'
);

select is(
  (select count(*)::integer from public.pets where owner_id = auth.uid()),
  1,
  'el dueño puede leer su propia mascota'
);

select throws_ok(
  $$
    insert into public.pets (id, owner_id, name, species, breed, age_months)
    values (
      'rls-pet-owner-b-spoofed',
      '10000000-0000-4000-8000-000000000002',
      'No autorizada',
      'gato',
      'Común',
      6
    )
  $$,
  '42501',
  null,
  'el dueño no puede crear una mascota para otra cuenta'
);

select lives_ok(
  $$
    insert into public.visits (pet_id, status, triage)
    values (
      'rls-pet-owner-a',
      'pendiente',
      '{"suggested":"urgencia","confirmed":null,"reasons":["motivo de prueba"],"rulesVersion":"0.2"}'::jsonb
    )
  $$,
  'el dueño puede crear una visita para su mascota'
);

select is(
  (select id <> '' from public.visits where pet_id = 'rls-pet-owner-a'),
  true,
  'PostgreSQL genera el ID de la visita'
);

select is(
  (
    select owner_id
    from public.visits
    where pet_id = 'rls-pet-owner-a'
  ),
  auth.uid(),
  'la base asigna el dueño de la visita desde la mascota'
);

select is(
  (select triage->>'suggested' from public.visits where pet_id = 'rls-pet-owner-a'),
  'urgencia',
  'se conserva el nivel sugerido del triaje'
);

select ok(
  (select triage ? 'confirmed' from public.visits where pet_id = 'rls-pet-owner-a'),
  'se conserva la clave confirmed aunque todavía sea null'
);

select is(
  (select triage->'confirmed' from public.visits where pet_id = 'rls-pet-owner-a'),
  'null'::jsonb,
  'el nivel confirmado permanece null hasta la confirmación veterinaria'
);

select is(
  (select triage->'reasons' from public.visits where pet_id = 'rls-pet-owner-a'),
  '["motivo de prueba"]'::jsonb,
  'se conservan los motivos del resultado'
);

select is(
  (select triage->>'rulesVersion' from public.visits where pet_id = 'rls-pet-owner-a'),
  '0.2',
  'se conserva la versión de reglas aplicada'
);

select lives_ok(
  $$
    update public.visits
    set triage = '{"suggested":"urgencia","confirmed":null,"reasons":["motivo actualizado"],"rulesVersion":"0.2"}'::jsonb
    where pet_id = 'rls-pet-owner-a'
  $$,
  'el dueño puede guardar la sugerencia sin confirmar el triaje'
);

select is(
  (select triage from public.visits where pet_id = 'rls-pet-owner-a'),
  '{"suggested":"urgencia","confirmed":null,"reasons":["motivo actualizado"],"rulesVersion":"0.2"}'::jsonb,
  'la actualización conserva suggested, confirmed, reasons y rulesVersion'
);

select throws_ok(
  $$
    update public.visits
    set triage = jsonb_set(triage, '{confirmed}', '"urgencia"'::jsonb)
    where pet_id = 'rls-pet-owner-a'
  $$,
  'P0001',
  'Only clinic staff can confirm triage',
  'el dueño no puede confirmar el nivel sugerido'
);

select throws_ok(
  $$
    update public.visits
    set triage = jsonb_set(triage, '{suggested}', '"consulta"'::jsonb)
    where pet_id = 'rls-pet-owner-a'
  $$,
  'P0001',
  'Suggested triage level cannot be lowered',
  'el dueño no puede bajar el nivel de triaje guardado'
);

select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-4000-8000-000000000002',
  true
);

select throws_ok(
  $$
    insert into public.visits (id, pet_id, status)
    values ('rls-visit-owner-b-spoofed', 'rls-pet-owner-a', 'pendiente')
  $$,
  '42501',
  null,
  'el dueño no puede iniciar una visita para la mascota ajena'
);

select * from finish();
rollback;
