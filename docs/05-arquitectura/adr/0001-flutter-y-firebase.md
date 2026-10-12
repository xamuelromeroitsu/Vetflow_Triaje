# ADR-0001 · Flutter + Firebase

**Estado:** Propuesta

## Contexto
Equipo pequeño, necesidad de salir rápido, app móvil con base de datos en tiempo real, fotos y modo offline.

## Decisión
Usar Flutter para la app y Firebase (Auth, Firestore, Storage) como backend.

## Consecuencias
- ✅ Un solo código para Android e iOS; sin servidor propio; offline integrado.
- ✅ Cola en tiempo real con poco esfuerzo.
- ⚠️ Dependencia de un proveedor; los costes crecen con el uso.
- ⚠️ Consultas complejas (analítica) serán limitadas; se revisará en Fase 4.

## Alternativas
Backend propio (más control, más trabajo); Supabase (SQL, menos madurez offline).
