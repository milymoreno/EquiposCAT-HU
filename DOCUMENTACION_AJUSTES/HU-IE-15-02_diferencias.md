# HU-IE-15-02 — Documento de Diferencias y Justificaciones de Ajuste

**HU:** HU-IE-15-02 – Consulta y Validación de Facturas Sincronizadas desde D365  
**HU Inicial:** `HU_Inicial/HU-IE-15-02 Consulta y Validación de Facturas.md`  
**HU Final:** `HU_final/HU-IE-15-02.md`  
**Fecha de revisión:** 2026-03-05  
**Fuentes consultadas:**
- Sesión de levantamiento: `TRANSCRIPT/HU_ImportaciónEquiposCAT_20260302_1400.txt`
- Requerimiento original: `REQUERIMIENTOS/requeriments.txt` (REQ-15)

---

## Resumen General

La HU inicial definía correctamente el propósito de la consulta a nivel funcional. Sin embargo, la sesión del 02/03/2026 reveló detalles operativos clave: el proceso actual se apoya en una **bitácora manual en Excel** que el analista mantiene fuera del sistema, existen correcciones que deben poder hacerse dentro del SII (especialmente el INCOTERM), y el bloqueo de embarque cuando hay errores no estaba lo suficientemente detallado. Además, se identificó que hay una cadena de consecuencias si el error se detecta tarde (borrar guía y reiniciar).

---

## Tabla de Diferencias

| # | Elemento | HU Inicial | HU Final | Justificación |
|---|----------|-----------|----------|---------------|
| 1 | **Contexto As-Is** | No existía. | Se agrega sección completa con el flujo actual: correo con Excel, bitácora manual, corrección en SII y consecuencias de error tardío. | En sesión (líneas 155–165, transcript 02/03) Angie (speaker_3) describió el proceso actual: el SII le envía un Excel por correo. Línea 1978: Fabiani explicitó que "es la validación que queremos en SII 2.0, que no quede en un Excel". |
| 2 | **Corrección de INCOTERM desde el SII** | No contemplada; la HU inicial asumía solo lectura. | Se agrega funcionalidad explícita: **el analista puede asignar INCOTERM** a facturas que llegaron sin él, directamente en el SII, con trazabilidad. | En sesión (líneas 2022–2097, transcript 02/03) Angie describió: "las facturas llegan al SII sin INCOTERM" y "yo tengo una opción en el SII para asignarle el Incoterm". Este es un escenario frecuente que debe preservarse en SII 2.0. |
| 3 | **Trazabilidad de correcciones** | No mencionada. | Toda corrección menor realizada en el SII debe registrar **usuario, fecha y motivo** (RN-03). | Las correcciones manuales en sistemas sin auditoría son un riesgo de control. La sesión evidenció que estas correcciones ocurren con frecuencia y deben quedar rastreables. |
| 4 | **Consecuencia de error tardío (guía ya generada)** | No contemplada. | Se documenta en notas técnicas: si el error se detecta después de generar la guía, se debe **anular la guía y reiniciar**. RN-05: no se puede modificar factura ya asociada a guía. | Angie (líneas 1967–1975, transcript 02/03) describió el caso: "cuando eso pasaba, me tocaba borrar la guía y volver a empezar". Esto motiva que la validación previa sea robusta. |
| 5 | **Reemplazo de la bitácora en Excel** | No mencionado. | Se agrega como objetivo explícito: la funcionalidad **reemplaza** la bitácora manual (RN-07). | Línea 1978: Fabiani (speaker_1): "es la validación que queremos hoy en día en el SII 2.0, que no quede en un Excel". Esto eleva el propósito de la HU: no es solo un reporte, es el reemplazo de un proceso manual crítico. |
| 6 | **Tabla de estados de factura** | Se listaban los estados sin descripción. | Se agrega **tabla de estados** con descripción detallada de cada uno y su implicación en el flujo. | Los estados son la base del control del proceso. Sin descripción clara, el equipo de desarrollo podría implementar estados incompletos o incorrectos. |
| 7 | **Bloqueo de embarque** | Mencionado en validaciones al final. | Elevado a **RN-02** y **Escenario 4** con Gherkin explícito: bloqueo con mensaje de motivo visible para el analista. | Si el analista no ve claramente por qué está bloqueado, intentará saltarse el paso o escalar innecesariamente. El mensaje de motivo es clave para autonomía operativa. |
| 8 | **Tabla de filtros** | Lista simple de filtros. | **Tabla de filtros** con tipo de cada campo (texto libre, selector, rango de fechas). | Facilita el diseño de la interfaz y el desarrollo del componente de búsqueda con los tipos de control correctos. |
| 9 | **Escenarios Gherkin** | 5 escenarios. | 6 escenarios. | Se agrega **Escenario 5** (corrección de INCOTERM desde SII), que es un flujo nuevo identificado en sesión y ausente en la HU inicial. |

---

## Ajustes que NO cambiaron

- El objetivo central de conciliar D365 vs SII antes de generar embarques se mantiene.
- Los campos mínimos del reporte (código/nombre proveedor, número/fecha factura, valores, ID, OC, INCOTERM) se conservan del REQ-15.
- La exportación a Excel como mecanismo de descarga se mantuvo, pero como complemento al sistema, no como reemplazo.
- El bloqueo de proceso cuando la factura tiene error se conservó (RN-02).
- Los filtros por proveedor, fecha, OC, ID equipo y compañía se mantuvieron; se sumaron filtros de estado y fecha de sincronización.

---

## Decisiones de Diseño Clave

> **La bitácora en Excel es un proceso de negocio, no solo un reporte:** El equipo aclaró en sesión que esta validación no es un reporte opcional, sino un paso obligatorio antes de generar embarques. El SII 2.0 debe formalizarlo como una etapa del flujo con estados y controles, no como una pantalla de consulta secundaria.

> **Corrección de datos menores en el SII como funcionalidad crítica:** La posibilidad de asignar INCOTERM directamente en el SII (sin volver a D365) debe mantenerse y extenderse a otros campos que el equipo funcional identifique. Esto evita retrocesos costosos en el proceso.

> **Pendiente crítico:** Debe definirse la lista completa de campos corregibles desde el SII, ya que hoy solo se conoce el caso del INCOTERM. Este mapeo debe hacerse con el equipo funcional antes del sprint de desarrollo.
