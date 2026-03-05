# HU-IE-15-01: Sincronización Automática de Facturas desde D365

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** VALIDACIÓN DE FACTURAS  
**Requerimiento Original:** REQ-15 — El proceso inicia con el registro de facturas en D365 (asignación de costos según término de negociación). Esta información cae al SII para poder generar el embarque. El sistema debe permitir generar las referencias con la cantidad de caracteres que traiga la OC, caracteres especiales, mayúsculas y minúsculas, no debe ser limitante.  
**Versión:** 2.0  
**Fecha de revisión:** 2026-03-05  
**Estado:** Revisada con base en sesión de levantamiento (02-Mar-2026)

---

## Historia de Usuario

### Como:
Sistema SII 2.0

### Quiero:
Sincronizar automáticamente las facturas registradas en D365 al SII, utilizando como identificador oficial el código de proveedor de Dynamics 365 (6 dígitos), sin limitación en la longitud ni tipo de caracteres de las referencias.

### Para:
Que las facturas estén disponibles en el SII para el proceso de generación de embarques y nacionalización, con datos íntegros y sin necesidad de intervención manual.

---

## Contexto del Proceso (As-Is)

1. Las facturas se registran manualmente en **D365** con sus respectivos **Cargos** (fletes, seguros, INLAND, etc.) según el INCOTERM acordado con el proveedor.
2. D365 sincroniza periódicamente la información al SII mediante un proceso automático (job/scheduler).
3. El SII actual usa un **código proveedor de 3 dígitos** (código SII legado). Ej: Caterpillar = `021`.
4. D365 usa un **código proveedor de 6 dígitos** (vendor account). Ej: Caterpillar = `221372`.
5. Actualmente existe una **tabla de mapeo** entre los dos códigos, administrada manualmente, que genera complejidad operativa y riesgo de inconsistencia.
6. Al consultar facturas en el sistema actual, el usuario puede buscar por rango de fechas y proveedor; el resultado se visualiza una a una o en forma de listado.
7. El proceso opera para múltiples compañías (no solo compañía 001 / GColza).

---

## Descripción Funcional

El sistema debe:

1. **Ejecutar periódicamente la sincronización** de facturas registradas en D365 hacia el SII, mediante integración por API (sin acceso directo a base de datos de D365).
2. **Validar la clave de unicidad** de cada factura antes de insertarla (Número de factura + Fecha).
3. **Almacenar los campos de la factura** tal como vienen de D365, sin truncar caracteres en ningún campo de referencia (número de factura, OC).
4. **Usar el código de proveedor D365 (6 dígitos)** como identificador oficial, eliminando la dependencia de la tabla de mapeo SII-D365.
5. **Si el proveedor no existe en SII 2.0**, crearlo automáticamente con datos mínimos (ver HU-IE-15-03).
6. **Registrar en log** el resultado de cada ejecución: insertados, rechazados, duplicados y motivo de rechazo.
7. **Permitir monitoreo** del estado de las sincronizaciones desde el SII.

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Sincronización exitosa
```gherkin
Dado que existen facturas nuevas en D365
Cuando se ejecute el servicio de sincronización periódica
Entonces el sistema debe registrarlas correctamente en SII
  Y el código de proveedor almacenado debe ser el código D365 de 6 dígitos
  Y el log debe reflejar estado Exitoso con total de registros insertados.
```

### Escenario 2 – Factura duplicada (mismo número + misma fecha)
```gherkin
Dado que una factura con la misma combinación número + fecha ya existe en SII
Cuando llegue nuevamente desde D365
Entonces no debe cargarse ni sobrescribirse
  Y debe registrarse en log como duplicada con motivo explícito.
```

### Escenario 3 – Factura de año anterior ya migrada
```gherkin
Dado que una factura pertenece a un año anterior y ya fue procesada previamente
Cuando llegue nuevamente en la sincronización
Entonces el sistema no debe procesarla automáticamente.
```

### Escenario 4 – Factura con misma referencia pero nueva fecha
```gherkin
Dado que una factura tiene el mismo número pero una fecha diferente
Cuando se ejecute la sincronización
Entonces debe registrarse como un nuevo documento válido.
```

### Escenario 5 – Error en el servicio de sincronización
```gherkin
Dado que el servicio falle durante la ejecución
Cuando el usuario consulte el monitoreo
Entonces debe reflejar estado Fallido con detalle técnico del error.
```

### Escenario 6 – Referencia con caracteres especiales y longitud extendida
```gherkin
Dado que una OC o número de factura contiene caracteres especiales, mayúsculas, minúsculas o longitud extendida
Cuando se sincronice desde D365
Entonces el sistema debe almacenarla sin truncamiento ni modificación de ningún carácter.
```

### Escenario 7 – Proveedor inexistente en SII durante sincronización
```gherkin
Dado que una factura llega con un código de proveedor no registrado en SII 2.0
Cuando se procese la sincronización
Entonces el sistema debe crear automáticamente el proveedor con datos mínimos
  Y continuar el proceso de sincronización de la factura sin interrumpirlo.
```

---

## Reglas de Negocio

| ID    | Regla |
|-------|-------|
| RN-01 | La clave de unicidad de una factura es: **Número de factura + Fecha**. No se permite carga duplicada con la misma combinación. |
| RN-02 | Las facturas de años anteriores ya migradas no deben reprocesarse automáticamente. |
| RN-03 | Si una factura llega con el mismo número pero distinta fecha, se trata como un nuevo registro válido. |
| RN-04 | El sistema debe usar el **código proveedor D365 (6 dígitos)** como identificador oficial. La tabla de mapeo SII-D365 queda obsoleta. |
| RN-05 | Ningún campo de referencia (número de factura, OC) debe truncarse. El sistema debe admitir cualquier longitud y tipo de carácter. |
| RN-06 | Si el proveedor no existe en SII 2.0 al momento de la sincronización, debe crearse automáticamente con datos mínimos (código D365, nombre, país, estado activo). |
| RN-07 | La sincronización debe soportar múltiples compañías; no se limita a la compañía 001. |
| RN-08 | La integración debe realizarse exclusivamente por API; no se permite acceso directo a la base de datos de D365. |

---

## Información a Sincronizar por Factura

| Campo | Descripción | Observación |
|-------|-------------|-------------|
| Compañía | Código de compañía en D365 | Ej: 001, 021 |
| Código proveedor D365 | Vendor account (6 dígitos) | Fuente oficial en SII 2.0 |
| Nombre proveedor | Nombre oficial del proveedor | |
| Número de factura | Referencia de la factura en D365 | Sin límite de caracteres ni tipo |
| Fecha factura | Fecha de emisión | |
| Valor total factura | Valor total en moneda de la factura | |
| INCOTERM | Término de negociación internacional | Ej: DPU, CFR, CIF, FOB |
| Moneda | Moneda de la factura | |
| ID Equipo | Identificador del equipo CAT | |
| Orden de Compra (OC) | Referencia OC asociada | Sin límite de caracteres ni tipo |
| Valor equipo | Costo del equipo | |
| Valor fletes | Costo de flete | |
| Valor seguros | Costo de seguro | |
| Valor INLAND | Transporte terrestre en destino | |
| Valor otros | Otros costos adicionales | |

---

## Monitoreo de Sincronización

El sistema debe permitir visualizar:

- Fecha y hora de la última sincronización.
- Cantidad de registros procesados.
- Cantidad de errores.
- Cantidad de duplicados.
- Estado: **Exitosa / Parcial / Fallida**.

---

## Pendientes / Compromisos Identificados en Sesión

| # | Compromiso | Responsable |
|---|-----------|-------------|
| 1 | Validar la estructura de campos requeridos para crear el proveedor en SII 2.0 (NIT, dirección, teléfono, etc.) | Fabiani / Comercio Exterior |
| 2 | Confirmar si el cambio de código de proveedor afecta interfaces existentes hacia sistemas externos | Cheche / TI |
| 3 | Definir proceso de migración del código de proveedor histórico (SII 3 dígitos → D365 6 dígitos) | Equipo técnico con Daisy |

---

## Notas Técnicas

- La sincronización opera con un job/scheduler periódico; no es un proceso disparado manualmente por el usuario.
- El código D365 de 6 dígitos es **bidireccional**: se usa tanto al recibir la factura como en la declaración de importación (DI) que se transmite a la DIAN.
- Los "Cargos" en D365 (fletes, seguros, INLAND) son asignados al momento de registrar la factura y determinan el costo total del embarque.
- El sistema actual (S400/v1) usaba la tabla de mapeo SII-D365; esta tabla **queda obsoleta** en SII 2.0.
