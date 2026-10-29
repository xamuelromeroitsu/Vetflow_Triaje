# ADR-0001 · Flutter + Supabase

**Estado:** Aceptada

## Contexto
La aplicación requiere autenticación por correo, persistencia de datos clínicos,
políticas de acceso por propietario y clínica, carga privada de fotos y cambios
en tiempo real. La implementación inicial basada en Firebase se migró antes de
la puesta en producción; no hay datos reales de Firebase que deban conservarse.

## Decisión
Usar Flutter para la app y Supabase Auth, PostgreSQL con RLS, Realtime y Storage
como backend. Mantener el dominio aislado mediante puertos y adaptadores
Supabase en `infrastructure/supabase/`.

## Consecuencias
- ✅ Esquema relacional, constraints y políticas de acceso verificadas en la
  base de datos mediante RLS.
- ✅ Auth, datos, Storage y cola en tiempo real quedan en el mismo proveedor.
- ⚠️ La app móvil requiere una clave pública `anon`/`publishable`; la protección
  de datos depende de RLS y políticas de Storage, no de ocultar esa clave.
- ⚠️ Supabase no aporta automáticamente el modo offline de Firestore; caché y
  sincronización diferida siguen pendientes.
- ⚠️ La migración SQL debe aplicarse y validarse en el proyecto remoto antes de
  habilitar operaciones reales.

## Alternativas
Firebase (offline integrado, pero menos adecuado al modelo relacional requerido)
y backend propio (más control, mayor coste de desarrollo).
