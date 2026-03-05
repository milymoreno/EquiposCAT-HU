# HU-IE-15 — Documento de Diferencias y Justificaciones de Ajuste (REQ-15)

**HU:** HU-IE-15 – Sincronización, Validación y Creación de Proveedores  
**HU Iniciales de referencia:** HU-IE-15-01, HU-IE-15-02, HU-IE-15-03  
**Fecha de revisión:** 2026-03-05  

---

## Resumen de Ajustes Consolidados

El REQ-15 ha sido unificado para evitar la proliferación de sub-documentos, asegurando que el flujo desde la llegada de la factura hasta la creación del proveedor sea coherente.

### 1. Sincronización y Referencias
- Se eliminó el truncamiento de caracteres. Las referencias de OC y Factura ahora admiten longitudes extendidas y caracteres especiales, como se solicitó expresamente en la sesión (Mili, speaker_2).
- Se implementó la lógica de unicidad por **Factura + Fecha**.

### 2. Validación y Consulta
- Se reemplazó el proceso de conciliación manual por un módulo de consulta dentro del SII.
- Se agregaron campos de visualización crítica: INCOTERM, ID Equipo y OC, para facilitar la comparación con D365.

### 3. Gestión de Proveedores
- Se oficializó el uso del **Código D365 de 6 dígitos**.
- Se habilitó la **creación automática** de proveedores durante la sincronización, evitando bloqueos operativos.
- Se documentó la sincronización unidireccional (D365 -> SII).

---

## Decisiones Clave de Negocio
- **No retroaceso manual a Excel:** Toda la validación debe ocurrir en el SII para mantener la trazabilidad.
- **D365 como Fuente de Verdad:** Los datos maestros nacen en D365 y mueren en la DIAN, pasando por el SII.

---

## Ajustes que NO cambiaron

- El proceso sigue siendo: **D365 registra facturas → SII las sincroniza automáticamente** para habilitar embarques.
- La clave de unicidad **Factura + Fecha** se mantuvo (RN-01).
- Las reglas de no reproceso de duplicados y de facturas de años anteriores se conservaron (RN-02 y RN-03).
- El monitoreo con estado Exitosa / Parcial / Fallida se mantuvo.
- La restricción de integración solo por API (sin acceso directo a BD de D365) se conservó.

---

## Decisiones de Diseño Clave

> **Eliminación de la tabla de mapeo SII-D365:** La existencia de dos códigos (SII 3 dígitos y D365 6 dígitos) con una tabla de traducción manual fue identificada como un punto de falla y complejidad innecesaria. Se decidió en sesión que D365 es la fuente oficial y el SII 2.0 adoptará directamente el código de 6 dígitos. Esto impacta el modelo de datos, la migración histórica y todas las interfaces relacionadas.

> **Creación automática de proveedor como extensión de la sincronización:** En lugar de bloquear la sincronización si el proveedor no existe, el sistema creará el registro con datos mínimos y permitirá su complementación posterior. Esto evita cuellos de botella operativos y mantiene la sincronización no supervisada.

> **Pendiente crítico antes del desarrollo:** Debe definirse la estructura mínima de campos para la creación automática del proveedor en SII 2.0 (en conjunto con Daisy y el equipo de Comercio Exterior), y confirmar el impacto del cambio de código en las interfaces existentes hacia terceros.
