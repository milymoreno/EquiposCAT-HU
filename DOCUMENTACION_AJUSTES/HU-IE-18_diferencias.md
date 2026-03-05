# HU-IE-18 — Documento de Diferencias y Justificaciones de Ajuste

**HU:** HU-IE-18 – Generación de Documento de Transporte (Guía)  
**HU Inicial:** `HU_Inicial/HU-IE-18 Generación de Documento de Transporte.md`  
**HU Final:** `HU_final/HU-IE-18.md`  
**Fecha de revisión:** 2026-03-05  

---

## Resumen de Ajustes

La HU final para la generación del documento de transporte se ajustó para reflejar la integración real entre Logística y Finanzas.

### 1. Fortalecimiento de la Llave de Integración
- **Cambio:** Se estableció el uso de **BL + Dealer** como punto de partida obligatorio.
- **Justificación:** Consistentemente con los REQ-15 y REQ-16, esta llave asegura que no se mezclen embarques de distintos puertos o distribuidores.

### 2. Automatización de Cálculos
- **Cambio:** Se especificó que el Peso Bruto y el Total FOB deben ser sumatorias automáticas de las facturas asociadas.
- **Justificación:** Para evitar errores de digitación manual y asegurar que la Guía cuadre exactamente con los valores contables de D365.

### 3. Control de Estados Mejorado
- **Cambio:** Se refinó el flujo de estados (Borrador -> Confirmada -> ... -> Cerrada).
- **Justificación:** Para dar trazabilidad clara al usuario sobre en qué punto del proceso de nacionalización se encuentra la mercancía.

### 4. Restricciones de Usuario
- **Cambio:** Se agregaron bloqueos explícitos para no permitir cambios en la guía si ya existe una Declaración de Importación (DI) asociada.
- **Justificación:** Garantizar la integridad legal de los datos transmitidos a la aduana.
