-- Datos ficticios para desarrollo local. No ejecutar contra produccion.
-- No se incluyen usuarios, duenos, mascotas ni visitas.
insert into public.clinics (
  id,
  name,
  address,
  phone,
  email,
  specialties,
  hours,
  emergency_24h,
  services
)
values (
  'vetflow-local-demo-clinic',
  'Clinica veterinaria de demostracion (local)',
  'Direccion ficticia - solo desarrollo',
  '0000000000',
  'demo@example.invalid',
  array[]::text[],
  '{}'::jsonb,
  false,
  array[]::text[]
)
on conflict (id) do nothing;
