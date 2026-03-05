# HU-IE-15-03 — Documento de Diferencias y Justificaciones de Ajuste

**HU:** HU-IE-15-03 – Creación Automática de Proveedores  
**HU Inicial:** `HU_Inicial/HU-IE-15-03 Creación Automática y Unificación.md`  
**HU Final:** `HU_final/HU-IE-15-03.md`  
**Fecha de revisión:** 2026-03-05  

---

## Diferencias Identificadas

1. **Unificación de Código:** Se documentó la obsolescencia definitiva de la tabla de mapeo de 3 dígitos (código SII legado).
2. **Creación con Datos Mínimos:** Si un proveedor no existe durante la carga de facturas, se registra automáticamente con los datos básicos que vienen de D365 para no bloquear la operación.
3. **Sincronización Unidireccional:** Se aclaró que el SII no debe enviar datos de vuelta a D365 sobre maestros de proveedores.
