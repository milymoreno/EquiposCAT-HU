# HU-IE-16 — Documento de Diferencias y Justificaciones de Ajuste

**HU:** HU-IE-16 – Integración con Logística Internacional para Recepción de BL  
**HU Inicial:** `HU_Inicial/HU-IE-16 Integración con Logística.md`  
**HU Final:** `HU_final/HU-IE-16.md`  
**Fecha de revisión:** 2026-03-05  
**Fuentes consultadas:**
- Requerimiento original: `REQUERIMIENTOS/requeriments.txt` (REQ-16)
- Sesión de levantamiento: `TRANSCRIPT/HU_ImportaciónEquiposCAT_20260302_1400.txt`

---

## Resumen General

La HU-IE-16 inicial era una descripción técnica de una interfaz de comunicación. La versión final incorpora la lógica de negocio necesaria para que esa interfaz sea útil en la operación: se definieron los estados del proceso logístico dentro del SII, se estableció la validación crítica de asociación con las facturas del REQ-15 y se agregaron reglas de integridad de datos (como el manejo de pesos y duplicados) basadas en las preocupaciones de trazabilidad expresadas en el transcript.

---

## Tabla de Diferencias

| # | Elemento | HU Inicial | HU Final | Justificación |
|---|----------|-----------|----------|---------------|
| 1 | **Contexto As-Is** | No existía. | Se agrega la descripción del proceso actual (recepción por correo/reportes) para resaltar la necesidad de automatización. | Necesario para dimensionar el impacto de la reducción de errores manuales mencionados por Mili (speaker_2) en la sesión. |
| 2 | **Estados del BL** | Mencionaba una lista simple. | Se detalla el flujo de estados: **Recibido → Validado → Disponible para Guía → Asociado a Guía → Cerrado**. | El transcript (líneas 1150-1200 en sesiones relacionadas) sugiere que el BL tiene un ciclo de vida antes de convertirse en un documento de transporte nacionalizable. |
| 3 | **Validación vs REQ-15** | Mención genérica. | **RN-05:** Asociación dinámica. El sistema busca facturas sincronizadas. Si no están, el BL queda en estado "Parcial". | Garantiza que no se procese un BL "vacío" o con información financiera incompleta (confirmado por Mili, speaker_2, sobre la importancia de la conciliación). |
| 4 | **Regla de Idempotencia** | "No reproceso". | Escenario 3 (Gherkin): **BL + Compañía = Único**. Rechazo silencioso con registro en log si es duplicado. | Evita la duplicidad de costos y bultos en los reportes de importación ante envíos repetidos del middleware. |
| 5 | **Validación de Puertos** | "Debe validar coherencia". | Especifica validación contra el **catálogo de maestros del SII**. | Sin esta validación, se transmitirían códigos de puerto erróneos a Open Comex/DIAN, causando rechazos en la DI. |
| 6 | **Campos a Sincronizar** | Lista simple. | Tabla detallada con tipo de dato y origen de la información. | Facilita el mapeo técnico para el equipo que desarrollará el API de integración. |
| 7 | **Audit Log / Payload** | "Debe registrar". | Requisito de **almacenar el payload original cifrado** para auditoría. | Seguridad y cumplimiento para resolver disputas de "quién envió qué dato" en discrepancias logísticas. |
| 8 | **Nota sobre REQ-18** | No incluida. | Se especifica que el BL es el **insumo principal** para la generación de la guía (Documento de Transporte). | Claridad en la dependencia funcional del proceso: REQ-15 → REQ-16 → REQ-18. |

---

## Ajustes que NO cambiaron

- La arquitectura sigue siendo basada exclusivamente en APIs REST.
- La prohibición de acceso directo a bases de datos se mantiene.
- Los campos básicos del BL (Número, Fecha, Puerto, Peso, Bultos) son consistentes con la propuesta inicial.

---

## Decisiones de Diseño Clave

> **Manejo de estados para control de flujo:** A diferencia de una simple tabla de "recibidos", el BL actúa como una entidad con vida propia que debe ser validada financieramente (teniendo sus facturas asociadas) antes de poder avanzar al siguiente paso del requerimiento de transporte.

> **Sincronización Asíncrona:** El sistema asume que el BL y las Facturas pueden llegar en momentos distintos. La regla de asociación dinámica asegura que el orden de llegada no rompa el proceso, siempre y cuando ambos datos existan antes de la validación final.
