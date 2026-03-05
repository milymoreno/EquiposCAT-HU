# HU-IE-15-01 — Documento de Diferencias y Justificaciones de Ajuste

**HU:** HU-IE-15-01 – Sincronización Automática de Facturas desde D365  
**HU Inicial:** `HU_Inicial/HU-IE-15-01 Sincronización Automática.md`  
**HU Final:** `HU_final/HU-IE-15-01.md`  
**Fecha de revisión:** 2026-03-05  

---

## Diferencias Identificadas

1. **Identificador de Proveedor:** Se cambió el uso del código SII (3 dígitos) por el **Código D365 (6 dígitos)** oficial de Dynamics.
2. **Clave de Unicidad:** Se definió como la combinación de **Número de factura + Fecha** para permitir re-emisiones de facturas con el mismo número pero distinta fecha (Mili, sesión 02-Mar).
3. **No Truncamiento:** Se agregó la regla explícita de soportar cualquier longitud y caracteres especiales en OC y Factura para cumplir con el requerimiento original sin limitaciones técnicas.
4. **Responsable de Carga Masiva**: Se asignó a **Fabian Barragán** como responsable funcional del proceso masivo y sus notificaciones.
