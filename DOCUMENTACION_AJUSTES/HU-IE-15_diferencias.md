# HU-IE-15-01 — Documento de Diferencias y Justificaciones de Ajuste

**HU:** HU-IE-15-01 – Sincronización Automática de Facturas desde D365  
**HU Inicial:** `HU_Inicial/HU-IE-15-01 Sincronización Automática.md`  
**HU Final:** `HU_final/HU-IE-15-01.md`  
**Fecha de revisión:** 2026-03-05  
**Fuentes consultadas:**
- Sesión de levantamiento: `TRANSCRIPT/HU_ImportaciónEquiposCAT_20260302_1400.txt`
- Requerimiento original: `REQUERIMIENTOS/requeriments.txt` (REQ-15)

---

## Resumen General

La HU inicial capturaba el proceso de sincronización de facturas a nivel conceptual y técnico básico. Tras la revisión del transcript de la sesión del 02/03/2026 con el equipo de Importación de Equipos CAT (Fabiani, Angie, Óscar, Cheche, Mili y otros), se identificaron decisiones de negocio clave, restricciones técnicas y compromisos que enriquecen y en algunos casos **cambian** la dirección del diseño de forma significativa.

---

## Tabla de Diferencias

| # | Elemento | HU Inicial | HU Final | Justificación |
|---|----------|-----------|----------|---------------|
| 1 | **Código de proveedor** | No especificaba qué código usar (SII o D365). | Se define que el **código D365 de 6 dígitos** (vendor account) es la fuente oficial, eliminando el código SII legado (3 dígitos). | En sesión (líneas 222–460, transcript 02/03) se evidenció que coexisten dos códigos con una tabla de mapeo manual que genera duplicidad y riesgo de inconsistencia. El equipo decidió usar D365 como fuente maestra para eliminar esa complejidad. |
| 2 | **Tabla de mapeo SII-D365** | No mencionada. | Se declara **obsoleta** en SII 2.0. | El equipo acordó (líneas 425–460, transcript 02/03) eliminar la complejidad del mapeo y fluir directamente el código D365 entre sistemas, incluyendo la declaración de importación (ida y vuelta). |
| 3 | **Creación automática de proveedor** | No contemplada. | Se agrega **RN-06**: si el proveedor no existe en SII 2.0 al sincronizar, se crea automáticamente con datos mínimos. | Mili (speaker_6, líneas 534–576) preguntó si la sincronización es bidireccional. En respuesta, Fabiani aclaró que si un proveedor nuevo llega, el SII debe poder crearlo y completar datos después. Óscar formalizó el compromiso (línea 596). |
| 4 | **Caracteres en referencias** | Mencionado como validación técnica al final. | Elevado a **RN-05 y campo explícito en tabla**: sin ningún límite de longitud ni tipo de carácter en OC y número de factura. | El REQ-15 lo indica explícitamente: *"la cantidad de caracteres que traiga la OC, caracteres especiales, mayúsculas y minúsculas, no debe ser limitante"*. Se agrega escenario Gherkin 6 específico para asegurar cobertura de prueba. |
| 5 | **Soporte multicompañía** | Mencionaba "compañía" de forma genérica. | Se agrega **RN-07** explícito: el proceso debe soportar múltiples compañías, no solo la 001. | En sesión (líneas 77–86, transcript 02/03) Fabiani aclaró que la compañía 001 es GColza pero el proceso no se limita a ella; hay otras compañías operando el mismo proceso. |
| 6 | **Bidireccionalidad del código D365** | No mencionada. | Documentada en Notas Técnicas: el código D365 se usa en la declaración de importación (DI) que se transmite a la DIAN. | Cheche (speaker_4, líneas 442–464, transcript 02/03) aclaró que el código es de "ida y vuelta": entra al SII y también sale hacia la DI y la DIAN. |
| 7 | **Sección As-Is** | No existía. | Se agrega **Contexto del Proceso (As-Is)** describiendo el flujo actual con la tabla de mapeo, los dos tipos de código y el proceso manual de consulta. | Proporciona trazabilidad entre el proceso actual y el nuevo, esencial para que el equipo de desarrollo entienda qué cambia y qué se elimina. |
| 8 | **Escenarios Gherkin** | 5 escenarios. | 7 escenarios. | Se agregaron **Escenario 6** (caracteres especiales) y **Escenario 7** (proveedor inexistente), que emergen directamente del transcript y cubren riesgos funcionales no contemplados inicialmente. |
| 9 | **Reglas de negocio** | 4 reglas en formato de secciones `###`. | 8 reglas en **tabla estructurada** con ID. | Se agrega el formato estándar con ID de regla y se incorporan RN-04 a RN-08 surgidas de la sesión. El formato de tabla facilita trazabilidad y referencia cruzada. |
| 10 | **Tabla de campos a sincronizar** | Lista simple de campos. | **Tabla con columnas**: campo, descripción y observación. | Se agrega la observación sobre la restricción de caracteres en OC y número de factura, y se clarifica que el código D365 es el almacenado. |

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
