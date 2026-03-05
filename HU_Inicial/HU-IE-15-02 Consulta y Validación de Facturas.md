# HU-IE-15-02: Consulta y Validación de Facturas Sincronizadas desde D365

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** VALIDACIÓN DE FACTURAS  
**Requerimiento Original:** 15 - Se requiere una validación previa por medio de un reporte que permita conciliar que lo registrado en D365 cayó correctamente al SII.

---

### Como:
Analista de Comercio Exterior  

### Quiero:
Consultar y validar las facturas sincronizadas desde D365  

### Para:
Confirmar que la información registrada en D365 fue correctamente cargada en el SII antes de generar embarques.

---

## Descripción Funcional

El sistema debe permitir consultar las facturas sincronizadas mostrando como mínimo:

- Compañía
- Código proveedor
- Nombre proveedor
- Número factura
- Fecha factura
- Valor total factura
- INCOTERM
- Moneda
- ID Equipo
- Orden de compra
- Valor equipo
- Valor fletes
- Valor seguros
- Valor INLAND
- Valor otros

---

## Objetivo de la Consulta

- Conciliar información D365 vs SII.
- Validar que no existan valores truncados.
- Validar que no existan inconsistencias en montos.
- Confirmar que el INCOTERM fue correctamente interpretado.
- Confirmar que la factura está lista para proceso de embarque.

---

## Filtros Disponibles

El sistema debe permitir filtrar por:

- Rango de fechas de factura
- Número de factura
- Proveedor
- Orden de compra
- ID Equipo
- Compañía
- Estado de sincronización
- Fecha de sincronización

---

## Estados de Registro

Cada factura debe mostrar estado:

- Sincronizada
- Con error
- Duplicada
- Pendiente validación
- Lista para embarque

---

## Exportación de Resultados

El sistema debe permitir:

- Descargar el resultado de la consulta en formato Excel.
- Exportar únicamente los registros filtrados.
- Incluir fecha y hora de generación del reporte.
- Incluir usuario que genera el reporte.

---

## Validaciones

- No permitir generación de embarque si la factura tiene estado:
  - Con error
  - Pendiente validación
- No permitir modificar valores desde esta pantalla (solo consulta).

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Consulta general
Dado que existen facturas sincronizadas  
Cuando el usuario ingrese al módulo de consulta  
Entonces el sistema debe mostrar listado completo con filtros disponibles.

---

### Escenario 2 – Filtro por proveedor
Dado que el usuario filtre por proveedor  
Cuando aplique filtro  
Entonces el sistema debe mostrar únicamente facturas asociadas.

---

### Escenario 3 – Exportación exitosa
Dado que el usuario aplique filtros  
Cuando descargue el archivo  
Entonces el sistema debe exportar únicamente los registros filtrados.

---

### Escenario 4 – Factura con error
Dado que una factura tenga error de sincronización  
Cuando el usuario la consulte  
Entonces debe visualizar detalle del error técnico.

---

### Escenario 5 – Control previo a embarque
Dado que una factura esté en estado Con error  
Cuando el usuario intente usarla para generar guía  
Entonces el sistema debe bloquear la operación.