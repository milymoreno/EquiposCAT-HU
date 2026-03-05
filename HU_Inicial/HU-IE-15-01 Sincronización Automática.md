# HU-IE-15-01: Sincronización Automática de Facturas desde D365

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** VALIDACIÓN DE FACTURAS  
**Requerimiento Original:** 15 - El proceso inicia con el registro de facturas en D365. Esta información cae al SII para poder generar el embarque.

---

### Como:
Sistema SII 2.0  

### Quiero:
Sincronizar automáticamente las facturas registradas en D365  

### Para:
Que puedan ser utilizadas en el proceso de generación de embarques y nacionalización en el SII.

---

## Arquitectura de Integración

- La integración debe realizarse exclusivamente mediante servicios (API).
- No se permitirá acceso directo a bases de datos productivas de D365.
- El diseño debe evitar acoplamiento fuerte entre sistemas.
- Debe soportar evolución futura sin afectar continuidad operativa.

---

## Información a Sincronizar

Por cada factura:

- Compañía
- Código proveedor
- Nombre proveedor
- Número de factura
- Fecha factura
- Valor total factura
- INCOTERM
- Moneda
- ID Equipo
- Orden de Compra
- Valor equipo
- Valor fletes
- Valor seguros
- Valor INLAND
- Valor otros

---

## Reglas de Negocio

### RN-01: Clave de Unicidad
Factura + Fecha = identificador único.

Si ya fue procesada:
- No debe cargarse nuevamente.
- No debe sobrescribirse.

---

### RN-02: Facturas de años anteriores
- No deben procesarse automáticamente si ya fueron migradas.
- Solo se permitirán si no existen previamente registradas.

---

### RN-03: No reproceso automático
Si la factura llega nuevamente con:
- Mismo número
- Misma fecha

Debe ignorarse y registrarse en log como duplicado.

---

### RN-04: Nueva versión válida
Si la factura llega con:
- Mismo número
- Fecha diferente

Debe procesarse como nuevo registro válido.

---

## Monitoreo de Sincronización

El sistema debe permitir visualizar:

- Fecha y hora de última sincronización.
- Cantidad de registros procesados.
- Cantidad de errores.
- Cantidad de duplicados.
- Estado: Exitosa / Parcial / Fallida.

---

## Registro de Logs

Cada ejecución debe registrar:

- ID de ejecución.
- Usuario sistema (servicio).
- Fecha y hora.
- Total registros recibidos.
- Total insertados.
- Total rechazados.
- Motivo del rechazo.

---

## Validaciones Técnicas

- No permitir procesar facturas sin proveedor.
- No permitir procesar facturas sin OC.
- No permitir procesar facturas sin ID equipo.
- No permitir referencias con truncamiento de caracteres.

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Sincronización exitosa
Dado que existen facturas nuevas en D365  
Cuando se ejecute el servicio de sincronización  
Entonces el sistema debe registrarlas correctamente en SII.

---

### Escenario 2 – Factura duplicada
Dado que una factura + fecha ya existe  
Cuando llegue nuevamente  
Entonces no debe cargarse y debe registrarse en log como duplicada.

---

### Escenario 3 – Factura año anterior ya migrada
Dado que una factura pertenece a año anterior y ya fue procesada  
Cuando llegue nuevamente  
Entonces no debe procesarse.

---

### Escenario 4 – Factura con nueva fecha
Dado que una factura tiene mismo número pero nueva fecha  
Cuando se sincronice  
Entonces debe registrarse como nuevo documento.

---

### Escenario 5 – Error en sincronización
Dado que falle el servicio  
Cuando se consulte el monitoreo  
Entonces debe reflejar estado Fallido y detalle técnico.