# HU-IE-16: Integración con Logística Internacional para Recepción de BL

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** INTEGRACIÓN LOGÍSTICA INTERNACIONAL  
**Requerimiento Original:** REQ-16 — El sistema se integra con Logística Internacional para obtener información del BL (Bill of Lading / Conocimiento de Embarque) de forma automática.  
**Versión:** 2.0  
**Fecha de revisión:** 2026-03-05  
**Estado:** Revisada con base en sesión de levantamiento (02-Mar-2026)

---

## Historia de Usuario

### Como:
Sistema SII 2.0 / Analista de Comercio Exterior

### Quiero:
Recibir automáticamente la información detallada de los BL (Bill of Lading) desde el sistema de Logística Internacional mediante una integración segura y controlada.

### Para:
Garantizar la integridad de la información logística, automatizar la asociación de facturas al documento de transporte y permitir que el proceso de nacionalización avance sin errores de transcripción manual.

---

## Contexto del Proceso (As-Is)

1. La información de los embarques (BL) llega actualmente por diversos medios (correos, reportes externos).
2. Existe el riesgo de inconsistencias entre los datos reportados por la transportadora y los registrados en el SII.
3. El BL es el documento maestro que "ampara" o agrupa un conjunto de facturas de mercancía.
4. Sin la recepción formal y validada del BL, no se pueden iniciar los trámites ante la aduana (DIAN).

---

## Descripción Funcional

El sistema debe:

1. **Recibir la información vía API REST**: La integración debe ser desasociada de bases de datos directas, operando mediante una capa de servicios segura (OAuth2/Token).
2. **Crear el registro de BL en el SII**: Al recibir el payload, el sistema debe insertar el BL si no existe, o actualizarlo si el estado lo permite.
3. **Manejar la asociación de facturas**: El BL viene con una lista de facturas asociadas. El sistema debe validar que dichas facturas ya existan en el SII (sincronizadas previamente desde D365 en HU-IE-15-01).
4. **Gestionar estados logísticos**: El BL debe transicionar por estados (Recibido → Validado → Disponible para Guía → Asociado a Guía → Cerrado).
5. **Controlar la integridad técnica**: No permitir bultos o pesos negativos, validar formatos de fecha y existencia de puertos en los catálogos maestros del SII.

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Recepción de BL con facturas existentes
```gherkin
Dado que llega un mensaje de integración con un BL y 3 números de facturas
Cuando el SII verifique que las 3 facturas ya fueron sincronizadas desde D365 (REQ-15)
Entonces el sistema debe crear el BL en estado "Recibido"
  Y asociar automáticamente las 3 facturas al BL.
```

### Escenario 2 – Recepción de BL con facturas faltantes
```gherkin
Dado que llega un BL con una factura que aún no ha sido sincronizada desde D365
Cuando el sistema procese la integración
Entonces debe crear el BL en estado "Parcial - Pendiente Facturas"
  Y registrar en el log técnico la factura faltante
  Y notificar al analista mediante el monitor de integraciones.
```

### Escenario 3 – BL duplicado (Idempotencia)
```gherkin
Dado que el BL "HLCUBCN12345" ya existe en el SII para la compañía 001
Cuando el sistema de Logística envíe nuevamente el mismo BL
Entonces el SII no debe crear un nuevo registro
  Y debe registrar el evento como "Duplicado - Ignorado" en el log de integración.
```

### Escenario 4 – Validación de datos maestros (Puertos)
```gherkin
Dado que el payload del BL trae un código de puerto origen "XYZ"
Cuando el sistema verifique contra el catálogo de puertos del SII
Y el código "XYZ" no existe
Entonces el sistema debe rechazar el registro del BL
  Y marcar la ejecución con error "Catálogo: Puerto no encontrado".
```

---

## Reglas de Negocio

| ID    | Regla |
|-------|-------|
| RN-01 | **Identificado único:** La combinación de Número de BL + Compañía define un registro único en el sistema. |
| RN-02 | **Precedencia:** Un BL no puede pasar a estado "Validado" si las facturas que lo componen no están todas presentes y validadas en el SII. |
| RN-03 | **Unidireccionalidad:** Los datos maestros del BL (peso, bultos, transportadora) vienen de Logística. Cualquier cambio manual en el SII debe quedar auditado. |
| RN-04 | **Control de Peso:** El peso bruto debe ser un valor numérico positivo. Si viene en cero o negativo, el registro debe ser rechazado. |
| RN-05 | **Asociación Dinámica:** Si una factura llega después que el BL, el sistema debe tener la capacidad de re-escanear BLs pendientes ("Parciales") para completar la asociación automáticamente. |
| RN-06 | **Estados Mandatorios:** Todo BL debe pasar por el flujo de estados definido para garantizar que la información esté lista para la generación de la guía de nacionalización. |

---

## Información a Sincronizar (Campos Clave)

| Campo | Descripción | Tipo |
|-------|-------------|------|
| Compañía | Código de la empresa del grupo (ej: 001) | String (3) |
| Número BL | Identificador del Conocimiento de Embarque | String (50) |
| Fecha BL | Fecha de emisión del documento | Date |
| Puerto Origen | Código del puerto de salida | String (10) |
| Puerto Destino | Código del puerto de llegada a Colombia | String (10) |
| Transportadora | Nombre o código de la naviera/agente | String (100) |
| Vía Transporte | Marítima, Aérea, Terrestre | Enum |
| Peso Bruto | Peso total reportado en el BL | Decimal |
| Bultas | Cantidad de bultos/unidades | Integer |
| Facturas | Lista de números de factura asociados | List<String> |

---

## Pendientes / Compromisos Identificados en Sesión

| # | Compromiso | Responsable |
|---|-----------|-------------|
| 1 | Definir los códigos oficiales de estados logísticos para el API | Equipo Técnico / TI |
| 2 | Confirmar si el peso debe enviarse en KG o Libras para estandarizar | Logística Internacional |
| 3 | Validar si existen BLs que amparen facturas de múltiples compañías simultáneamente | Comercio Exterior |

---

## Notas Técnicas

- La integración debe soportar **OAuth2** para seguridad entre sistemas.
- Se debe implementar un mecanismo de **reintentos automáticos** (Retrier) ante fallas 5xx del servicio.
- El payload original (JSON/XML) debe almacenarse en una tabla de auditoría (blob o similar) para respaldo ante disputas de información.
- Conexión crítica: Este módulo es el disparador del **REQ-18 (Generación de Documento de Transporte)**.
