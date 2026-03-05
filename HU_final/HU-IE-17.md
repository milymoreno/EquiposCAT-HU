# HU-IE-17: Asignación y Control de Registro y/o Licencia de Importación

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** ASIGNACIÓN DE REGISTRO Y/O LICENCIA  
**Requerimiento Original:** REQ-17 — Permitir la asignación de un número de licencia con el fin de controlar saldos y vencimientos.  
**Versión:** 2.0  
**Fecha de revisión:** 2026-03-05  
**Estado:** Revisada con base en sesión de levantamiento (02-Mar-2026)

---

## Historia de Usuario

### Como:
Analista de Comercio Exterior

### Quiero:
Asignar un número de registro o licencia de importación (VUCE) a una guía de equipos previamente generada, utilizando la llave **Guía + Dealer**.

### Para:
Controlar saldos y vencimientos de forma automática, garantizando que los equipos (especialmente los remanufacturados) cumplan con la normativa legal antes de generar la declaración de importación.

---

## Contexto del Proceso (As-Is)

1. Actualmente, el registro de licencias para equipos remanufacturados se hace después de generar el embarque.
2. La "llave" para ingresar al módulo es el **Número de Guía + Dealer** (Angie, línea 765).
3. Si el equipo es remanufacturado, el sistema exige obligatoriamente la carga de una licencia para poder continuar.
4. El proceso actual es manual y propenso a errores en el control de saldos remanentes en la VUCE.

---

## Descripción Funcional

El sistema debe permitir:

1. **Acceso al Módulo**: Ruta `Procesos generales -> Módulo Declaraciones -> Ingresar registro licencia equipos`.
2. **Validación de Llave**: Solicitar Número de Guía y Dealer para cargar la información de la guía.
3. **Carga y Asignación**:
   - Visualizar los equipos asociados a la guía.
   - Permitir la asignación de una licencia existente (RQ 55/56) o el registro de una nueva.
4. **Control de Obligatoriedad**: Si la subpartida arancelaria o el tipo de equipo (remanufacturado) lo requiere, el sistema no permitirá avanzar sin una licencia válida asignada.
5. **Consumo de Saldo**: Al asignar la licencia a la guía, el sistema debe descontar automáticamente la cantidad del saldo disponible de la licencia de forma transaccional.

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Asignación Exitosa para Remanufacturado
```gherkin
Dado que el equipo en la guía X con dealer Y está marcado como remanufacturado
Cuando el analista ingrese al módulo de asignación y vincule una licencia vigente con saldo
Entonces el sistema debe asociar la licencia al equipo
  Y debe descontar el saldo correspondiente de la licencia maestra.
```

### Escenario 2 – Bloqueo por Licencia Vencida
```gherkin
Dado que la licencia seleccionada tiene una fecha de vencimiento menor a la fecha actual
Cuando se intente realizar la asignación
Entonces el sistema debe mostrar un mensaje de error "Licencia Vencida" 
  Y bloquear la grabación del registro.
```

### Escenario 3 – Control de Concurrencia en Saldo
```gherkin
Dado que dos analistas intentan consumir el saldo de la misma licencia simultáneamente para guías diferentes
Cuando el sistema procese la segunda solicitud
Entonces debe validar el saldo remanente después del primer descuento y rechazar si es insuficiente.
```

---

## Reglas de Negocio Clave

| ID | Regla |
| :--- | :--- |
| **RN-01** | La llave de búsqueda y persistencia es **Número de Guía + Dealer**. |
| **RN-02** | No se permite la modificación de la licencia asignada si la declaración de importación ya fue generada o transmitida. |
| **RN-03** | El consumo de saldo es **atómico**: o se descuenta todo lo de la transacción o no se descuenta nada (evitar saldos inconsistentes). |
| **RN-04** | Alertas automáticas: El sistema debe notificar cuando una licencia esté al 10% de su saldo o a 30 días de vencer. |

---

## Pendientes Identificados

1. Integrar esta pantalla con el "Bot de Declaraciones" para que el dato de la licencia fluya automáticamente hacia la DIAN.
2. Validar las tablas técnicas de persistencia (SIPIDYNL1, SIPIDYNL2, SIPOVLR3, etc.).

---

## Notas Técnicas
- El Dealer determina el puerto, el cual es necesario para la validación de la jurisdicción de la licencia.
- Sincronización con el módulo transversal de licencias (RQ 55/56).
