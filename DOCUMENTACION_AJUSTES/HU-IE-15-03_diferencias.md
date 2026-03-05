# HU-IE-15-03 — Documento de Diferencias y Justificaciones de Ajuste

**HU:** HU-IE-15-03 – Creación Automática y Unificación de Proveedores en SII 2.0  
**HU Inicial:** `HU_Inicial/HU-IE-15-03 Creación Automática y Unificación.md`  
**HU Final:** `HU_final/HU-IE-15-03.md`  
**Fecha de revisión:** 2026-03-05  
**Fuentes consultadas:**
- Sesión de levantamiento: `TRANSCRIPT/HU_ImportaciónEquiposCAT_20260302_1400.txt`
- Requerimiento original: `REQUERIMIENTOS/requeriments.txt` (REQ-15)

---

## Resumen General

La HU inicial proponía la unificación de códigos de proveedor correctamente. La sesión del 02/03/2026 aportó el detalle operativo y técnico: se desmontó la mecánica actual de la tabla de mapeo, se definió que la creación automática ocurre durante la sincronización de facturas (no en un proceso separado), se aclaró la unidireccionalidad de la sincronización y emergió la necesidad de un pendiente técnico crítico (definición de campos mínimos con Daisy). También se resolvió la ambigüedad terminológica "proveedor" vs "exportador".

---

## Tabla de Diferencias

| # | Elemento | HU Inicial | HU Final | Justificación |
|---|----------|-----------|----------|---------------|
| 1 | **Contexto As-Is** | No existía. | Se agrega descripción del proceso actual: tabla de exportadores de 3 dígitos, tabla de mapeo manual, proceso de registro de nuevos proveedores. | Fabiani (speaker_1, líneas 241–258, transcript 02/03) explicó el proceso actual: "uno entra acá a una tabla que se llama exportadores". Sin este contexto el equipo de desarrollo no sabe qué eliminar. |
| 2 | **Momento de creación automática** | Descrito como un proceso de migración/inicialización separado. | Integrado como parte de la sincronización de facturas: **si llega una factura con proveedor desconocido, se crea en el acto**. | Mili (speaker_6, líneas 534–543, transcript 02/03): "¿cómo están sincronizando los proveedores de Dynamics?". La sesión aclaró que no es un proceso batch separado, sino que ocurre al moment de la primera factura del proveedor. |
| 3 | **Sincronización unidireccional** | No especificada. | Documentada explícitamente: D365 → SII. Cambios en el SII **no regresan a D365** como regla general. | Mili (speaker_6, líneas 541–543): "¿me queda claro si es bidireccional?". Fabiani (speaker_1, línea 549) respondió "No". Se agrega pendiente para definir política ante cambios futuros en D365. |
| 4 | **Datos mínimos vs datos completos** | Mencionaba "datos mínimos" sin especificar cuáles eran. | Tabla de campos con su origen (D365 o SII), si son obligatorios al crear y si son editables. Campos por definir marcados explícitamente. | Mili (speaker_2, líneas 260–266, transcript 02/03): "los datos mínimos que están ahí te permitan crearlo". Fabiani (líneas 500–502): "el nombre, el NIT, el país, estos sí son datos complementarios, la dirección, el teléfono". Los campos pendientes se identificaron explícitamente. |
| 5 | **Unificación terminológica** | No contemplada. | Se agrega **RN-06**: el término oficial es "Proveedor". "Exportador" queda obsoleto en la interfaz del SII 2.0. | Mili (speaker_2, líneas 504–509, transcript 02/03): "hay un tema de ambigüedad, porque dentro del proceso ustedes lo llaman proveedor, código proveedor". Fabiani (speaker_1): "lo vamos a dejar con un solo término". |
| 6 | **Tabla de mapeo de 3 dígitos queda obsoleta** | Mencionado conceptualmente. | Agrega **RN-07** y **Escenario 5** con Gherkin: la tabla queda inhabilitada y SII 2.0 ignora cualquier referencia al código de 3 dígitos. | Óscar (speaker_4, líneas 268–270): "ya el sistema no tiene que venir a leer el de tres dígitos en el SI, sino el de seis dígitos". Confirmado por Fabiani (líneas 429–433). |
| 7 | **Modificación posterior en SII** | Mencionado someramente. | Funcionalidad explícita con RN-05 y Escenario 3: el analista puede completar/modificar campos en el SII con trazabilidad. | Fabiani (speaker_1, líneas 564–572, transcript 02/03): "no estamos exceptos de que un proveedor cambie su domicilio. Sí tiene que estar susceptible a modificación." |
| 8 | **Estado del proveedor creado automáticamente** | No contemplado. | Agrega **RN-08**: proveedor creado automáticamente queda marcado "Datos incompletos" hasta validación del analista. | Garantiza que el equipo sepa cuáles proveedores requieren revisión posterior sin necesidad de búsquedas manuales. |
| 9 | **Pendiente crítico: campos mínimos con Daisy** | No documentado. | Se documenta como compromiso formal en tabla de pendientes (#1). | Mili (speaker_2, líneas 489–496, transcript 02/03): "esa tarea tenemos que hacer un barrido con Daisy". Fabiani asumió la tarea de llevar el inventario de campos requeridos. |

---

## Ajustes que NO cambiaron

- El objetivo de usar el código D365 de 6 dígitos como identificador oficial se mantiene desde la HU inicial.
- La eliminación de la tabla de mapeo como meta del proceso se conservó.
- D365 sigue siendo la fuente oficial de datos de proveedores.
- La integración vía API (sin acceso directo a BD) se mantiene como restricción técnica.

---

## Decisiones de Diseño Clave

> **La creación automática ocurre en tiempo real durante la sincronización:** No es un proceso batch de migración previo. Cuando llega la primera factura de un proveedor nuevo, el SII lo crea en ese momento con datos mínimos y continúa. Esto asegura que el proceso de sincronización no se interrumpa nunca por la ausencia de un proveedor.

> **La sincronización es unidireccional por defecto:** D365 es la fuente de verdad. El SII puede enrichecer los datos del proveedor, pero no los sobreescribe de vuelta a D365. La política ante actualizaciones futuras de D365 es un pendiente técnico crítico.

> **Pendiente bloqueante para desarrollo:** Los campos mínimos requeridos para crear un proveedor deben definirse con Daisy y el equipo de Comercio Exterior **antes del sprint**. Sin esto, el equipo de desarrollo no puede construir el modelo de datos de proveedores ni la lógica de creación automática.
