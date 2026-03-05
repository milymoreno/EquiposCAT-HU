# HU-IE-15-03: Creación Automática y Unificación de Proveedores

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** VALIDACIÓN DE FACTURAS – GESTIÓN DE PROVEEDORES  
**Requerimiento Relacionado:** 15  
**Origen Adicional:** Comentarios técnicos sesión – Unificación de códigos proveedor SII y D365.

---

### Como:
Sistema SII 2.0  

### Quiero:
Crear automáticamente proveedores que no existan al momento de sincronizar facturas  

### Para:
Evitar reprocesos manuales y eliminar la coexistencia de códigos duplicados entre SII y D365.

---

## Problema Identificado

Actualmente existen:

- Código proveedor en SII.
- Código proveedor en D365.

Esto genera:
- Duplicidad.
- Mapeos manuales.
- Riesgo de inconsistencia.
- Impacto en migración de datos históricos.

---

## Objetivo del Nuevo Modelo

- Unificar modelo de identificación de proveedor.
- Tomar D365 como fuente oficial.
- Evitar doble codificación.
- Permitir creación automática controlada.

---

## Descripción Funcional

Cuando el sistema sincronice una factura:

1️⃣ Validar si el proveedor existe en SII 2.0.  

2️⃣ Si no existe:
- Crear automáticamente el proveedor.
- Asignar identificador único interno.
- Registrar que fue creado automáticamente.

3️⃣ Permitir que posteriormente:
- Se complemente información adicional.
- Se asignen configuraciones contables o tributarias.

---

## Información Mínima para Creación Automática

- Código proveedor D365
- Nombre proveedor
- País
- Tipo proveedor
- Estado activo

---

## Migración de Datos Históricos

El sistema debe:

- Migrar los códigos actuales de proveedor SII.
- Mapearlos a proveedor D365.
- Evitar que existan dos registros para el mismo proveedor.

Debe existir un proceso controlado de:
- Depuración.
- Consolidación.
- Auditoría de migración.

---

## Reglas de Negocio

### RN-01: Fuente oficial
D365 será la fuente oficial de identificación de proveedor.

---

### RN-02: No duplicidad
No se permitirá crear proveedor si ya existe con mismo código D365.

---

### RN-03: Creación automática controlada
Los proveedores creados automáticamente deben quedar con estado:
- Pendiente de validación administrativa.

---

### RN-04: Edición por roles
Solo usuarios con rol autorizado podrán:
- Modificar datos del proveedor.
- Completar información adicional.

---

### RN-05: Impacto en Migración
Se debe documentar el impacto en:
- Facturas históricas.
- Embarques antiguos.
- Costeos ya realizados.

---

## Validaciones

- No permitir sincronización de factura si proveedor no puede crearse.
- No permitir eliminar proveedor si tiene facturas asociadas.
- No permitir modificar código D365 una vez creado.

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Proveedor inexistente
Dado que una factura llega con proveedor no registrado  
Cuando el sistema la sincronice  
Entonces debe crear automáticamente el proveedor.

---

### Escenario 2 – Proveedor ya existente
Dado que el proveedor ya existe  
Cuando llegue una nueva factura  
Entonces no debe crearse un nuevo registro.

---

### Escenario 3 – Complementar información
Dado que el proveedor fue creado automáticamente  
Cuando un usuario autorizado acceda  
Entonces debe poder complementar información adicional.

---

### Escenario 4 – Migración histórica
Dado que existen códigos antiguos en SII  
Cuando se ejecute proceso de migración  
Entonces debe mapearlos correctamente sin duplicados.

---

### Escenario 5 – Control de edición
Dado que un usuario sin permisos intente modificar proveedor  
Entonces el sistema debe bloquear la operación.