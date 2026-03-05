# HU-IE-17: Asignación y Control de Registro y/o Licencia de Importación para Equipos CAT (Unificada)

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** ASIGNACIÓN DE REGISTRO Y/O LICENCIA  
**Requerimiento Original:** 17 - Permitir la asignación de un número de licencia con el fin de controlar saldos y vencimientos.  

**Dependencia Obligatoria:**  
- RQ 55 – REGISTROS Y/O LICENCIAS DE IMPORTACIÓN  
- RQ 56 – REGISTROS Y/O LICENCIAS CAT  

---

### Como:
Analista de Comercio Exterior  

### Quiero:
Asignar un número de registro o licencia de importación a una guía de equipos  

### Para:
Controlar saldos, vencimientos y garantizar cumplimiento normativo antes de la generación de la declaración.

---

## Unificación Funcional

Esta funcionalidad NO debe desarrollarse de forma aislada.

Debe integrarse completamente con el módulo transversal de Registros y Licencias definido en:

- RQ 55
- RQ 56
- CrossDocking
- Marcas Aliadas

Responsable de unificación funcional: Fabian Barragán.

La estructura de una licencia es única sin importar el proceso (según lo indicado en sesión).

---

## Momento en el Flujo

La asignación debe realizarse:

1. Después de generar la guía.
2. Antes de generar la declaración de importación.
3. Antes de enviar información a SIACO.
4. Antes de consolidación final.

No se permitirá avanzar en el flujo si la licencia es obligatoria y no ha sido asignada.

---

## Información Obligatoria de la Licencia

- Número de licencia / registro
- Tipo (R / L)
- Fecha radicación
- Fecha aprobación
- Fecha vencimiento
- Cantidad autorizada
- Saldo disponible
- Subpartida asociada
- Compañía
- Estado

---

## Reglas de Negocio

### RN-01: Identificador Único
Número Licencia + Compañía = identificador único.

---

### RN-02: Control de Vencimiento
No permitir asignar licencia si:
- Fecha vencimiento < Fecha actual.

---

### RN-03: Control de Saldos
No permitir asignar si:
- Cantidad solicitada > Saldo disponible.

Debe permitir:
- Consumo parcial.
- Actualización automática del saldo.

---

### RN-04: Consumo Atómico
El descuento de saldo debe ser transaccional.
Si falla el proceso, no debe descontarse parcialmente.

---

### RN-05: Control de Concurrencia
Si dos usuarios intentan consumir saldo simultáneamente:
- Solo debe aprobarse una transacción.
- La segunda debe recalcular saldo actualizado.

---

### RN-06: Bloqueo Posterior
No permitir modificar o eliminar licencia si:

- Ya existe declaración generada.
- Ya fue transmitida a SIACO.
- Ya existe consolidación.
- Ya fue enviada información a D365.

---

### RN-07: Reasignación
Permitir reasignar licencia únicamente si:

- Guía está en estado Borrador.
- No existe declaración generada.
- No existe consumo definitivo.

---

### RN-08: Obligatoriedad
Si la subpartida requiere licencia:
- No permitir avanzar sin asignación válida.

---

## Persistencia y Control

A diferencia del sistema actual (que solo guarda número), el nuevo sistema debe:

- Persistir datos completos de licencia.
- Registrar consumo histórico.
- Permitir consulta por:
  - Número licencia
  - Guía
  - Subpartida
  - Rango de fechas
  - Estado

---

## Integración Técnica

Debe impactar las siguientes tablas:

- SIPIDYNL1 (Equipos)
- SIPIDYNL2 (Equipos)
- SIPOVLR3 (Equipos)
- SIPDYNIF (Equipos y Repuestos)
- SIPDYNIF1 (Equipos y Repuestos)

Debe registrarse referencia cruzada entre:

- Guía
- Licencia
- Declaración
- Equipo (ID)

---

## Monitoreo

El sistema debe permitir visualizar:

- Licencias activas
- Licencias próximas a vencer (alerta configurable)
- Licencias agotadas
- Licencias parcialmente consumidas

---

## Alertas

Debe generar alertas cuando:

- Saldo ≤ 10% restante
- Faltan 30 días para vencimiento
- Intento de consumo sin saldo suficiente

---

## Auditoría

Debe registrar:

- Usuario que asigna
- Fecha y hora
- Cantidad consumida
- Saldo antes
- Saldo después
- Guía asociada
- IP / Identificador de sesión

---

## Registro de Logs Técnicos

Cada intento de asignación debe registrar:

- Resultado (Éxito / Rechazo)
- Motivo del rechazo
- Payload procesado
- Timestamp

---

## Escenarios Especiales Detectados en Sesión

- La licencia hoy se administra parcialmente fuera del sistema.
- El nuevo sistema debe centralizar control.
- Debe permitir futura integración masiva (si aplica).
- Debe soportar estructura común para todos los procesos.

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Asignación exitosa
Dado que la licencia está vigente  
Y tiene saldo suficiente  
Cuando el usuario la asigne a la guía  
Entonces debe descontar saldo correctamente  
Y registrar auditoría.

---

### Escenario 2 – Licencia vencida
Dado que la licencia está vencida  
Cuando se intente asignar  
Entonces debe bloquear la operación.

---

### Escenario 3 – Saldo insuficiente
Dado que la cantidad supera el saldo  
Cuando se intente asignar  
Entonces debe rechazar con mensaje claro.

---

### Escenario 4 – Concurrencia
Dado que dos usuarios consumen simultáneamente  
Cuando el segundo confirme  
Entonces debe recalcular saldo y validar nuevamente.

---

### Escenario 5 – Intento posterior a declaración
Dado que la declaración ya fue generada  
Cuando se intente modificar licencia  
Entonces debe bloquear la operación.