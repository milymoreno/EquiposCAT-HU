# HU-IE-20 — Documento de Diferencias y Justificaciones de Ajuste

**HU:** HU-IE-20 – Registro y Persistencia de Tipificación Activo Fijo  
**HU Inicial:** `HU_Inicial/HU-IE-20 Registro y Persistencia de Tipificación.md`  
**HU Final:** `HU_final/HU-IE-20.md`  
**Fecha de revisión:** 2026-03-05  

---

## Resumen de Ajustes

La HU final formaliza la necesidad de persistencia técnica para una decisión que antes era volátil o indirecta.

### 1. Cambio de Dato Calculado a Persistido
- **Cambio:** Se exige que el flag de Activo Fijo sea un campo persistente en la base de datos.
- **Justificación:** En el levantamiento se detectó que el sistema actual no guarda explícitamente esta decisión (basándose en lógicas implícitas dificultando la auditoría). La nueva versión debe asegurar la trazabilidad.

### 2. Integración como Bloqueante
- **Cambio:** Se integró la tipificación como un paso obligatorio previo a la Consolidación (REQ-22).
- **Justificación:** Para evitar errores contables en el ERP, es crítico que el analista confirme la naturaleza del equipo (Activo Fijo o Gasto/Inventario) antes de que los datos fluyan a D365.

### 3. Trazabilidad de Auditoría
- **Cambio:** Se detalló la necesidad de registrar quién y cuándo define el flag.
- **Justificación:** Dado el impacto fiscal del tratamiento de Activo Fijo, es un requisito de cumplimiento (compliance) saber quién tomó la decisión técnica.

### 4. Relación con DI/DAV
- **Cambio:** Se explicitó que este dato es la fuente para las declaraciones oficiales ante la DIAN.
- **Justificación:** Asegurar la consistencia entre lo que se registra en el SII y lo que se declara legalmente.
