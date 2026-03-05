# HU-IE-15-03 — Glosario de Términos de Negocio (Estilo Dummies)

**Aplica a:** HU-IE-15-03 – Creación Automática y Unificación de Proveedores en SII 2.0  
**Fecha:** 2026-03-05

> Glosario en lenguaje sencillo para que cualquier persona del equipo entienda los términos usados en esta historia de usuario.

---

## C

### Catálogo de Proveedores (en SII 2.0)
La lista oficial de todos los proveedores registrados en el SII 2.0, identificados por su código D365 de 6 dígitos. Reemplaza la antigua "tabla de exportadores" de 3 dígitos. Es el directorio maestro que el sistema consulta cada vez que llega una factura para verificar si el proveedor ya existe.

---

### Código D365 / Vendor Account (6 dígitos)
Ver también en el **Glosario Unificado**. En el contexto de esta HU: es la clave primaria del proveedor en SII 2.0. No puede cambiarse una vez asignado. Ejemplo: Caterpillar Inc. = `221372`. Este código también aparece en la Declaración de Importación enviada a la DIAN.

---

### Código SII Legado (3 dígitos)
El código antiguo de 3 dígitos que usaba el sistema anterior (S400/SII v1) para identificar proveedores. Ejemplo: Caterpillar = `021`. **Queda completamente obsoleto** en SII 2.0. No se crea, no se lee, no se usa. Es solo historia.

---

### Creación automática (de proveedor)
Proceso por el que el SII 2.0 crea un nuevo proveedor **en el momento exacto** en que llega la primera factura de ese proveedor desde D365, sin que nadie tenga que pedirlo o autorizar la creación. Se crea con los **datos mínimos** disponibles (código D365, nombre, país, estado activo) y luego puede completarse. Es como registrarse automáticamente en un evento cuando compras el tiquete, sin llenar el formulario completo de inmediato.

---

## D

### Datos incompletos (estado del proveedor)
Estado asignado automáticamente a un proveedor recién creado por el proceso de sincronización, indicando que tiene la información mínima necesaria para operar pero le falta información complementaria (NIT, dirección, teléfono). Es una señal para el analista de que ese proveedor necesita revisión.

---

### Datos mínimos (de proveedor)
El conjunto mínimo de campos necesarios para que el SII 2.0 pueda crear un proveedor y asociarle facturas. Se conocen actualmente: código D365, nombre, país y estado activo. Los demás campos (NIT, dirección, teléfono) están pendientes de definición con Daisy.

---

## E

### Exportador
Término anterior con el que también se conocía al proveedor en el proceso. Dentro del SII 2.0 **se unifica bajo el término "Proveedor"**. Se mantiene aquí solo como referencia histórica para entender por qué en algunos documentos pueden aparecer los dos términos.

---

## M

### Migración de proveedores históricos
El proceso de convertir los registros de proveedores del sistema antiguo (código de 3 dígitos) al nuevo formato (código D365 de 6 dígitos). Es un trabajo de preparación que debe hacerse **antes** de activar SII 2.0 en producción, para evitar que proveedores activos queden sin su equivalente en el nuevo sistema.

---

## P

### Proveedor (término unificado)
A partir de SII 2.0, el término oficial para referirse a la empresa que vende/exporta los equipos CAT. Reemplaza "Exportador" para eliminar la ambigüedad. Un proveedor se identifica por su **código D365 de 6 dígitos** y tiene información de contacto (NIT, nombre, país, dirección, teléfono) que puede gestionarse dentro del SII.

---

## S

### Sincronización unidireccional
Significa que los datos viajan en **un solo sentido**: de D365 hacia el SII. Si el analista modifica un dato del proveedor dentro del SII (ej: actualiza el teléfono), ese cambio **no regresa a D365**. D365 no se entera de las modificaciones que el SII haga internamente. Es como copiar un documento: puedes editar tu copia sin que el original cambie.

---

### Sistema fuente (D365)
El sistema que "manda" en el proceso de datos del proveedor. D365 es el sistema fuente porque es donde se crean y administran oficialmente los proveedores. El SII los recibe y puede enriquecerlos, pero no puede modificar lo que está en D365.

---

## T

### Tabla de exportadores (SII v1)
La pantalla/tabla del sistema antiguo (SII v1 / S400) donde se registraban manualmente los proveedores con su código de 3 dígitos y la equivalencia al código de D365. Con SII 2.0 esta tabla **desaparece**. Ya no es necesaria porque el SII usa directamente el código de 6 dígitos.

---

### Tabla de mapeo SII ↔ D365
Ver: **Tabla de exportadores**. Era la tabla que relacionaba el código de 3 dígitos del SII con el de 6 dígitos de D365. Requería mantenimiento manual cada vez que entraba un proveedor nuevo. **Obsoleta en SII 2.0.**

---

### Trazabilidad (de modificaciones al proveedor)
El registro automático de cada cambio que se hace a los datos de un proveedor en el SII 2.0: quién lo cambió, cuándo y por qué (motivo). Permite saber, por ejemplo, que el 5-Mar-2026 el usuario "mariap" cambió el teléfono del proveedor 221372 porque "actualizó datos del directorio CAT América 2026".

---

## V

### Vendor Account
Ver: **Código D365 / Vendor Account (6 dígitos)**.

---

## Relación entre los Términos Principales

```
[D365 – Tabla de Proveedores (Vendor Account)]
    │
    │  Sincronización unidireccional (API)
    ▼
[SII 2.0 – Catálogo de Proveedores]
    │
    ├── Proveedor YA existe → asociar factura
    │
    └── Proveedor NUEVO → crear automáticamente con datos mínimos
              │
              ├── Estado: "Datos incompletos"
              ├── Analista puede completar: NIT, dirección, teléfono
              └── Con trazabilidad: usuario + fecha + motivo

[Tabla de exportadores 3 dígitos] ─── OBSOLETA ──X
[Tabla de mapeo SII ↔ D365]       ─── OBSOLETA ──X
```

La creación automática de proveedores cierra el ciclo de la sincronización de facturas: si el proveedor no existe, se crea; si existe, se reutiliza. Sin pasos manuales en el camino crítico.
