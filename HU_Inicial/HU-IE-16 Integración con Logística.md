# HU-IE-16: Integración con Logística Internacional para Recepción de BL

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** INTEGRACIÓN LOGÍSTICA INTERNACIONAL  
**Requerimiento Original:** 16 - El sistema se integra con Logística Internacional para obtener información del BL.

---

### Como:
Sistema SII 2.0  

### Quiero:
Recibir automáticamente la información del BL desde el sistema de Logística Internacional  

### Para:
Permitir la generación controlada del documento de transporte y garantizar integridad de la información logística.

---

## Arquitectura de Integración

- La integración debe realizarse exclusivamente mediante servicios (API REST o equivalente).
- No se permitirá acceso directo a bases de datos externas.
- Debe implementarse autenticación segura (OAuth2 o token seguro).
- Debe permitir versionamiento del servicio.
- Debe soportar reintentos automáticos ante fallas transitorias.
- Debe desacoplarse mediante capa de integración (middleware o adapter).

---

## Información a Sincronizar (BL)

Por cada BL recibido:

- Compañía
- Número BL
- Fecha BL
- Puerto origen
- Puerto destino
- País compra
- País origen
- País procedencia
- Transportadora
- Vía transporte
- Peso bruto
- Bultos
- Estado logístico
- Lista de facturas asociadas

---

## Reglas de Negocio

### RN-01: Identificador único
BL + Compañía = identificador único.

---

### RN-02: No reproceso
Si el BL ya fue procesado:
- No debe cargarse nuevamente.
- Debe registrarse en log como duplicado.

---

### RN-03: Integridad obligatoria
No permitir registrar BL si falta:
- Compañía
- Número BL
- Fecha BL

---

### RN-04: Validación cruzada
El BL debe validar coherencia con:
- Facturas previamente sincronizadas (HU-IE-15-01).
- Compañía activa.

---

### RN-05: Control de concurrencia
Si dos procesos intentan registrar el mismo BL simultáneamente:
- Debe permitirse solo una inserción.
- El segundo intento debe fallar controladamente.

---

### RN-06: Estados del BL
El BL debe manejar estados:

- Recibido
- Validado
- Disponible para guía
- Asociado a guía
- Cerrado

---

## Monitoreo de Integración

Debe permitir visualizar:

- Fecha última sincronización.
- Total BL recibidos.
- Total procesados.
- Total duplicados.
- Total con error.
- Tiempo promedio de procesamiento.
- Estado general (Exitosa / Parcial / Fallida).

---

## Registro de Logs

Cada ejecución debe registrar:

- ID de ejecución
- Fecha y hora
- Cantidad recibida
- Cantidad válida
- Cantidad rechazada
- Motivo de rechazo
- Detalle técnico del error

---

## Auditoría

Debe registrar:

- Usuario sistema (servicio)
- Timestamp de recepción
- Payload original (almacenado cifrado)
- Resultado del procesamiento

---

## Validaciones Técnicas

- No permitir caracteres truncados.
- Validar formato de fechas.
- Validar peso numérico positivo.
- Validar puerto existente en catálogo.

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Recepción exitosa
Dado que Logística envía BL válido  
Cuando el servicio se ejecute  
Entonces el BL debe registrarse y quedar disponible.

---

### Escenario 2 – BL duplicado
Dado que el BL ya existe  
Cuando llegue nuevamente  
Entonces no debe cargarse y debe registrarse como duplicado.

---

### Escenario 3 – Error de servicio
Dado que el servicio falle  
Cuando se consulte monitoreo  
Entonces debe reflejar estado Fallido con detalle técnico.

---

### Escenario 4 – Concurrencia
Dado que dos procesos intentan registrar el mismo BL  
Entonces solo uno debe insertarlo exitosamente.