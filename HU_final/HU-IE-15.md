# HU-IE-15: Sincronización, Validación de Facturas y Creación de Proveedores

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** VALIDACIÓN DE FACTURAS Y GESTIÓN DE PROVEEDORES  
**Requerimiento Original:** REQ-15 — El proceso inicia con el registro de facturas en D365 (asignación de costos según término de negociación). El sistema debe permitir generar las referencias con la cantidad de caracteres que traiga la OC, caracteres especiales, mayúsculas y minúsculas. Debe migrar el código de proveedor al de 6 dígitos (D365) y permitir la creación automática de proveedores.  
**Versión:** 3.0 (Consolidada)  
**Fecha de revisión:** 2026-03-05  
**Estado:** Revisada con base en sesión de levantamiento (02-Mar-2026)

---

## Historia de Usuario

### Como:
Analista de Comercio Exterior / Sistema SII 2.0

### Quiero:
Sincronizar automáticamente las facturas de D365, validar su correcta recepción mediante reportes de conciliación y asegurar que los proveedores se creen o actualicen usando el código oficial de 6 dígitos de Dynamics.

### Para:
Eliminar la dependencia de tablas de mapeo manuales, asegurar la integridad de los datos logísticos y financieros desde el inicio del proceso y permitir la generación fluida de los embarques de nacionalización.

---

## Contexto del Proceso (As-Is)

1. Las facturas se registran en **D365** con cargos (fletes, seguros, INLAND) según el INCOTERM.
2. El sistema actual usa códigos de proveedor de 3 dígitos y una **tabla de mapeo** manual hacia los 6 dígitos de D365, lo cual genera errores y lentitud.
3. El equipo de Comex realiza una conciliación manual (usualmente apoyada en archivos Excel) para verificar que lo registrado en D365 coincida con lo que el SII recibió.
4. Si un proveedor no existe en el SII, la factura se bloquea y requiere registro manual por parte del área de TI o coordinadores.

---

## Descripción Funcional

El requerimiento 15 se desglosa en tres capacidades críticas:

### 1. Sincronización Automática (Backend)
- Ejecución periódica vía API para traer facturas nuevas.
- Almacenamiento íntegro de referencias (OC, Factura) sin truncamiento de caracteres especiales o longitudes extendidas.
- Registro en log de cada evento (insertado, duplicado, rechazado).

### 2. Consulta y Validación (Reporte de Conciliación)
- El sistema debe ofrecer una pantalla de consulta con filtros por **Proveedor, Factura, Fecha y ID Equipo**.
- Debe permitir comparar los valores de D365 vs SII.
- Debe incluir campos críticos: Código/Nombre Proveedor, Número Factura, Valor, OC, ID Equipo e INCOTERM.
- Opción de exportación a Excel para auditorías rápidas.

### 3. Gestión y Creación de Proveedores
- Uso exclusivo del **código D365 de 6 dígitos**.
- **Creación automática**: Si llega una factura de un proveedor inexistente, el sistema lo crea con datos mínimos (Nombre, País, Código) y lo marca como "Datos Incompletos".
- Permite la complementación manual de datos (NIT, dirección) directamente en el SII con trazabilidad.

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Sincronización y Creación de Proveedor
```gherkin
Dado que llega una factura de D365 con código de proveedor 221372 que NO existe en el SII
Cuando se ejecute la sincronización automática
Entonces el sistema debe crear al proveedor automáticamente con sus datos mínimos
  Y debe registrar la factura exitosamente asociándola al nuevo código de 6 dígitos.
```

### Escenario 2 – Validación mediante Reporte
```gherkin
Dado que el analista necesita conciliar las facturas del día
Cuando acceda al módulo de "Consulta y Validación de Facturas"
Entonces el sistema debe mostrar el listado con los campos: Proveedor, Factura, Valor, OC, ID Equipo e INCOTERM
  Y debe permitir exportar esta información para compararla con los reportes de D365.
```

### Escenario 3 – Manejo de Referencias Especiales
```gherkin
Dado que una Orden de Compra tiene 45 caracteres y símbolos como "/" o "-"
Cuando se sincronice al SII
Entonces el sistema debe guardarla exactamente igual, sin truncar ni cambiar el formato.
```

---

## Reglas de Negocio Clave

| ID | Regla |
| :--- | :--- |
| **RN-01** | La clave de unicidad es **Número de Factura + Fecha**. |
| **RN-02** | El **Código de 6 dígitos (Vendor Account)** es el identificador único oficial. La tabla de 3 dígitos queda obsoleta. |
| **RN-03** | La creación automática de proveedores no detiene la carga de facturas. |
| **RN-04** | El sistema debe soportar **múltiples compañías** (GColza, etc.). |
| **RN-05** | Los datos del proveedor se sincronizan **unidireccionalmente** (D365 -> SII). |

---

## Pendientes Identificados

1. Definir con Daisy la estructura mínima de campos de proveedor para la creación automática (NIT, Dirección, etc.).
2. Validar impacto en interfaces externas por el cambio de 3 a 6 dígitos en el código de proveedor.

---

## Notas Técnicas
- Implementación vía API REST con seguridad OAuth2.
- Registro de logs detallado para auditoría de sincronización.
- Opción de reintento para facturas que quedaron en estado "Fallido" o "Parcial".
