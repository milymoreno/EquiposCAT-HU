# HU-IE-16 — Documento de Diferencias y Justificaciones de Ajuste

**HU:** HU-IE-16 – Integración con Logística Internacional para Recepción de BL  
**HU Inicial:** `HU_Inicial/HU-IE-16 Integración con Logística.md`  
**HU Final:** `HU_final/HU-IE-16.md`  
**Fecha de revisión:** 2026-03-05  

---

## Resumen de Ajustes

La HU inicial era muy genérica sobre la integración. Tras el análisis del transcript de la sesión del 02-Mar, se incorporaron precisiones operativas críticas.

### 1. Definición de la "Llave" de Integración
- **Cambio:** Se especificó que la llave es **Número de Guía + Dealer** (Angie/Fabiani, líneas 765-791).
- **Justificación:** Sin esta combinación, el sistema no puede identificar unívocamente la carga ni su destino correcto.

### 2. Lógica del Dealer
- **Cambio:** Se incluyó el mapeo mandatorio de Dealer a Puerto (Ej: R490 a Buenaventura).
- **Justificación:** Automatiza la asignación del puerto de llegada, reduciendo errores manuales en la creación del embarque (Angie, línea 1098).

### 3. Diferenciación de Negocio (E vs R)
- **Cambio:** Se agregó la RN-02 sobre la validación de Dealer para Equipos (E) o Repuestos (R).
- **Justificación:** Durante la sesión (líneas 905-924) se enfatizó que poner el dealer incorrecto (ej: R cuando es de Equipos) genera rechazos automáticos en la validación.

### 4. Asociación de Facturas
- **Cambio:** Se explicitó que el BL es el contenedor de las facturas del REQ-15.
- **Justificación:** El BL consolida la carga física que respalda las facturas comerciales sincronizadas previamente.
