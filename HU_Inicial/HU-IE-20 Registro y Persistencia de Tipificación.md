# HU-IE-20-01: Registro y Persistencia de Tipificación Activo Fijo (S/N)

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** INGRESO DE DATOS COMPLEMENTARIOS DE DECLARACIÓN  
**Requerimiento Original:** 20 - Registrar en el sistema la tipificación de activo fijo S/N.

---

### Como:
Analista de Comercio Exterior  

### Quiero:
Indicar si un equipo corresponde a Activo Fijo (S/N)  

### Para:
Determinar correctamente el tratamiento contable, fiscal y de consolidación hacia D365.

---

## Contexto Detectado en Sesión

Actualmente:
- La decisión de Activo Fijo impacta el cálculo.
- No queda persistida explícitamente.
- Solo impacta indirectamente los códigos enviados a Dynamics.

El nuevo sistema debe:

- Persistir explícitamente la decisión.
- Asociarla a guía, declaración y equipo.
- Permitir trazabilidad histórica.

---

## Ubicación Funcional

La tipificación debe registrarse en:

Funcionalidad de:
Ingreso de datos complementarios de declaración.

Debe ser obligatoria antes de consolidar.

---

## Reglas de Negocio

### RN-01: Obligatoriedad
No permitir avanzar a consolidación si no se ha definido Activo Fijo S/N.

---

### RN-02: Persistencia
Debe almacenarse en base de datos como campo explícito:

- Activo_Fijo (S/N)
- Usuario que define
- Fecha y hora

---

### RN-03: Impacto Contable
Si Activo Fijo = S:

- Aplicar código contable específico.
- Aplicar estructura contable de activo.
- Aplicar configuración fiscal correspondiente.

Si Activo Fijo = N:

- Aplicar código contable distinto.

---

### RN-04: Impacto en IVA
Debe permitir configuración diferenciada de IVA según tipificación.

---

### RN-05: Bloqueo Posterior
No permitir modificar Activo Fijo si:

- Ya existe consolidación.
- Ya se envió información a D365.
- Ya existe levante confirmado.

---

### RN-06: Control de Concurrencia
Si dos usuarios modifican simultáneamente:

- Aplicar control de versión.
- Advertir conflicto.

---

## Monitoreo

Debe permitir consultar:

- Guías con Activo Fijo S
- Guías con Activo Fijo N
- Guías pendientes de definir

---

## Auditoría

Debe registrar:

- Usuario
- Fecha
- Valor anterior
- Valor nuevo
- Motivo de cambio

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Registro obligatorio
Dado que el usuario intenta consolidar  
Cuando no ha definido Activo Fijo  
Entonces debe bloquear la operación.

---

### Escenario 2 – Persistencia correcta
Dado que el usuario define Activo Fijo  
Cuando consulte posteriormente  
Entonces debe visualizarse el valor persistido.

---

### Escenario 3 – Intento posterior a consolidación
Dado que la guía ya fue consolidada  
Cuando se intente modificar  
Entonces debe bloquear.