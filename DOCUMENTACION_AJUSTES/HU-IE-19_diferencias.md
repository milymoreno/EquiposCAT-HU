# HU-IE-19 — Documento de Diferencias y Justificaciones de Ajuste

**HU:** HU-IE-19 – Ingreso de Costos de Nacionalización  
**HU Inicial:** `HU_Inicial/HU-IE-19 Ingreso de Costos de Nacionali.md`  
**HU Final:** `HU_final/HU-IE-19.md`  
**Fecha de revisión:** 2026-03-05  

---

## Resumen de Ajustes

La HU final se refinó para dar cumplimiento a los estrictos controles financieros detectados en el transcript de la reunión de marzo.

### 1. Definición de la Fuente de Datos
- **Cambio:** Se especificó que los "Cargos" se heredan de D365.
- **Justificación:** Se aclaró que el sistema no debe permitir la invención de fletes o seguros que no tengan una orden de compra o factura soporte sincronizada previamente de Dynamics 365.

### 2. Bloqueo Crítico por Consolidación
- **Cambio:** Se elevó la regla de Consolidación a "bloqueo absoluto".
- **Justificación:** Según el transcript (línea 2053), "la consolidación de costos cierra por completo el sistema y no hay manera de corregir nada". Esto es vital para evitar descuadres contables entre el SII y el ERP.

### 3. Tratamiento de Activo Fijo (AF)
- **Cambio:** Se integró la decisión de marcar equipos como Activo Fijo directamente en el prorrateo.
- **Justificación:** Se identificó que la decisión de AF no es solo informativa, sino que impacta la base imponible y el manejo del IVA en la nacionalización de equipos pesados.

### 4. Métodos de Prorrateo
- **Cambio:** Se limitaron los métodos a Valor FOB, Peso y Unidades como estándar.
- **Justificación:** Para simplificar la interfaz y asegurar que el cálculo sea auditable y reproducible por el departamento de finanzas.
