# HU-IE-15-02 — Glosario de Términos de Negocio (Estilo Dummies)

**Aplica a:** HU-IE-15-02 – Consulta y Validación de Facturas Sincronizadas desde D365  
**Fecha:** 2026-03-05

> Este glosario explica cada término en lenguaje sencillo para que cualquier persona del equipo pueda entender de qué se habla en esta historia de usuario.

---

## A

### Analista de Comercio Exterior
Persona del equipo encargada de gestionar los trámites de importación: valida facturas, genera embarques, coordina con la aduana. Es el usuario principal de esta HU: quien consulta, valida y corrige la información de facturas en el SII.

---

### Auditoría / Trazabilidad
Registro automático que guarda **quién hizo qué y cuándo** en el sistema. En esta HU: si un analista corrige un dato de una factura (ej: asigna el INCOTERM), el sistema debe guardar su nombre, la fecha y el motivo del cambio. Sirve para que cualquier persona pueda reconstruir el historial de cambios y justificarlos ante una auditoría externa.

---

## B

### Bitácora (de conciliación)
Documento de registro — actualmente en Excel — que el analista mantiene manualmente para anotar las facturas revisadas, los errores encontrados y las correcciones hechas. **En SII 2.0 esta bitácora se reemplaza por esta funcionalidad dentro del sistema**, garantizando trazabilidad y eliminando el riesgo de pérdida o inconsistencia del archivo manual.

---

### Bloqueo de embarque
Control del sistema que impide usar una factura en estado "Con error" o "Pendiente validación" para generar una guía de embarque. Es como un semáforo en rojo: si la factura no está en verde ("Lista para embarque"), el proceso no puede avanzar. Esto evita que errores se propaguen hacia etapas más difíciles de corregir.

---

## C

### Campo corregible (en el SII)
Campo de una factura que el analista puede modificar directamente dentro del SII sin necesidad de ir a D365. El ejemplo más común es el **INCOTERM**: a veces la factura llega del D365 sin este dato, y el analista puede asignarlo en el SII. No todos los campos son corregibles; solo los que el equipo funcional habilite explícitamente.

---

### Conciliación
Proceso de comparar la información registrada en D365 con la que llegó al SII para verificar que **son iguales**. Si hay diferencias, se detectan errores y se corrigen antes de continuar. Es como cotejar dos copias de un mismo documento para asegurarse de que no les falte ni sobre nada.

---

## E

### Estado de factura
Etiqueta que indica en qué punto del proceso está una factura sincronizada. Los estados posibles son:
- **Sincronizada:** llegó bien desde D365, sin errores.
- **Con error:** falló alguna validación; no puede usarse para embarque.
- **Duplicada:** llegó repetida (mismo número + fecha); no se procesó.
- **Pendiente validación:** necesita revisión manual.
- **Lista para embarque:** aprobada; puede incluirse en una guía.

---

### Exportación a Excel
Función del sistema que permite descargar el listado de facturas (con los filtros aplicados) en un archivo Excel. **No reemplaza la consulta en el SII**, sino que complementa para compartir información o archivar. El archivo siempre incluye fecha, hora y usuario que lo generó.

---

## F

### Filtro
Parámetro que el analista usa para reducir el listado de facturas a solo las que le interesan. Ejemplos: filtrar por proveedor, por rango de fechas, por estado "Con error". Funciona igual que los filtros de una hoja Excel, pero dentro del sistema.

---

## G

### Guía de embarque
Ver: **Embarque (Documento de Transporte)** en el Glosario Unificado. En el contexto de esta HU: una factura en estado "Con error" **no puede incluirse** en una guía de embarque. Si el error se detecta después de generar la guía, es necesario borrarla y reiniciar todo el proceso desde la selección de facturas.

---

## I

### INCOTERM (en el contexto de esta HU)
Es un campo crítico de la factura que define el término de negociación (FOB, CIF, DPU, etc.). En el proceso actual, algunas facturas **llegan al SII sin INCOTERM** aunque en D365 sí lo tenían. El SII debe permitir que el analista lo asigne manualmente como corrección controlada, con registro de auditoría.

---

## M

### Módulo de consulta de facturas
Pantalla del SII donde el analista puede ver, filtrar y revisar las facturas sincronizadas desde D365. Es el reemplazo digital de la bitácora manual en Excel. Debe mostrar todos los campos de la factura, su estado y las opciones de corrección disponibles.

---

## P

### Pendiente de definición (campos corregibles)
En la sesión del 02/03/2026 se identificó que el INCOTERM es un campo que puede corregirse desde el SII. Sin embargo, **no quedó definida la lista completa** de campos corregibles. Este es un pendiente crítico que debe resolverse con el equipo funcional antes del desarrollo.

---

## R

### Retroceso de proceso
Situación que ocurre cuando se detecta un error en una factura **después** de haber generado la guía de embarque. Para corregirlo, el analista debe:
1. Borrar la guía de embarque.
2. Corregir la factura (en SII o D365 según corresponda).
3. Volver a generar la guía.

El objetivo de la validación previa (esta HU) es **evitar completamente este escenario**.

---

## S

### Solo lectura
Modo de una pantalla en el que el usuario puede ver la información pero **no modificarla**. Esta HU es principalmente de solo lectura, excepto para los campos habilitados explícitamente para corrección menor (como el INCOTERM).

---

## Relación entre los Términos Principales

```
[Facturas sincronizadas en SII]  ←── HU-IE-15-01
            │
            ▼
[Módulo de Consulta y Validación]  ←── Esta HU (HU-IE-15-02)
            │
            ├── Filtros → resultado reducido
            ├── Revisión de estados → detectar errores
            ├── Corrección menor (ej: INCOTERM) → con auditoría
            └── Exportación a Excel → como respaldo/reporte
            │
            ▼
   [Factura: "Lista para embarque"]
            │
            ▼
   [Puede incluirse en Guía] ←── HU-IE-15-03 / HU-IE-18
```

La validación previa es el **filtro de calidad** entre la sincronización de facturas y la generación del embarque. Si este paso falla, todo el proceso posterior se ve afectado.
