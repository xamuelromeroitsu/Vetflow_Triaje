# ADR-0003 · Triaje por reglas versionadas

**Estado:** Propuesta

## Contexto
Necesitamos un triaje explicable y validable por un veterinario. Una IA no está validada ni es explicable.

## Decisión
Motor de reglas simples en un archivo versionado (`rulesVersion`). Cada triaje guarda nivel sugerido, motivos y versión. El veterinario confirma.

## Consecuencias
- ✅ Explicable y auditable; fácil de corregir con el veterinario.
- ✅ Se puede medir sugerido vs confirmado para mejorar.
- ⚠️ Menos flexible que un modelo de IA; cubre menos casos raros (por eso "ante la duda, subir").
