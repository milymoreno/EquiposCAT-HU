# HU-IE-15-04 — Documento de Diferencias y Justificaciones de Ajuste

**HU:** HU-IE-15-04 – Identificación y Resolución de Errores de Carga  
**HU Inicial:** N/A (Nueva historia identificada en sesión de refinamiento)  
**HU Final:** `HU_final/HU-IE-15-04.md`  
**Fecha de creación:** 2026-03-05  

---

## Justificación de la Creación

Esta historia de usuario no existía en el levantamiento inicial, pero se identificó como crítica durante las sesiones de refinamiento por las siguientes razones:

1.  **Carga Masiva**: Al introducir la carga masiva (Fabian Barragán), el riesgo de errores parciales aumenta. Se requiere una forma de gestionar el "reproceso" de registros fallidos.
2.  **Responsabilidad Compartida**: Deisy Rincón y Fabian Barragán requieren herramientas de visibilidad sobre los fallos de la interfaz con D365 para actuar proactivamente.
3.  **Flexibilidad Operativa**: Se definió que el SII debe permitir correcciones menores (como Incoterms) sin obligar a borrar y volver a sincronizar todo desde el ERP, optimizando el tiempo del analista.
