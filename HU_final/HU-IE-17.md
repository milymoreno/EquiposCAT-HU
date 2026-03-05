# HU-IE-17: Asignación de Registro y/o Licencia de Importación (VUCE)

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** GESTIÓN DE LICENCIAS Y REGISTROS  
**Requerimiento Original:** REQ-17 — El sistema debe permitir asignar el número de Registro o Licencia de Importación (VUCE) a los modelos de equipos, especialmente para equipos remanufacturados donde este requisito es obligatorio.

---

### Como:
Analista de Importaciones / Coordinador de Comercio Exterior

### Quiero:
Vincular los números de Registro o Licencia obtenidos en la VUCE a los modelos y tipos de equipos dentro de una guía confirmada.

### Para:
Cumplir con la normativa aduanera colombiana, permitiendo la generación de la Declaración de Importación (DIM) con la información legal requerida.

---

## Dependencias Técnicas y de Proceso
- **Guía Confirmada (HU-IE-18):** El proceso no puede iniciar si la Guía no está en estado "Confirmada".
- **Maestro de VUCE:** Información de Registros/Licencias vigentes.
- **Tipificación de Equipos:** Definición de si el equipo es "Nuevo" o "Remanufacturado".

---

## Reglas de Negocio

### RN-01: Obligatoriedad por Tipificación
- Si el equipo es **Remanufacturado**, el campo "Número de Licencia" es **Obligatorio**.
- Si el equipo es **Nuevo**, el campo "Número de Registro" es opcional/condicional según la subpartida arancelaria.

### RN-02: Herencia desde la Guía
- El sistema debe filtrar los modelos de equipos disponibles basándose en las facturas asociadas a la **Guía (BL)** seleccionada.

### RN-03: Validación de Vigencia
- El sistema debe alertar si la fecha del Registro/Licencia está vencida respecto a la fecha de llegada estimada del BL.

### RN-04: Persistencia en el Flujo
- Una vez asignado el registro/licencia, la Guía cambia a estado **"Licencia Asignada"**, habilitando el paso de **Consolidación de Costos (REQ-19)** y **Generación de DIM**.

---

## Criterios de Aceptación

### Escenario 1: Asignación exitosa para equipos remanufacturados
- **Dado** una Guía en estado "Confirmada".
- **Y** que contiene modelos tipificados como "Remanufacturados".
- **Cuando** el usuario ingresa el número de Licencia VUCE.
- **Entonces** el sistema debe permitir guardar y cambiar el estado de la Guía a "Licencia Asignada".

### Escenario 2: Bloqueo por falta de Licencia en Remanufacturados
- **Dado** un equipo Remanufacturado.
- **Cuando** se intente avanzar sin asignar Licencia.
- **Entonces** el sistema debe mostrar un error: "La Licencia de Importación es obligatoria para equipos remanufacturados".

---

## Auditoría y Control
- El sistema debe registrar el usuario, fecha y hora de la asignación.
- Cualquier cambio posterior a la "Licencia Asignada" debe requerir anulación de estado previo (Backtracking con restricciones).
