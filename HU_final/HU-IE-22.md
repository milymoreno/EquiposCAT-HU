# HU-IE-22: Consolidación Final de Costos y Envío a D365

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** CONSOLIDACIÓN DE COSTOS Y ENVÍO A D365  
**Requerimiento Original:** REQ-22 — Consolidación de costos y envío a Dynamics 365.  
**Versión:** 2.0  
**Fecha de revisión:** 2026-03-05  
**Estado:** Finalizada con base en requisitos de integridad ERP.

---

## Historia de Usuario

### Como:
Analista de Comercio Exterior

### Quiero:
Ejecutar el proceso de consolidación definitiva de costos del embarque y enviar la información liquidada hacia Dynamics 365.

### Para:
Cerrar el ciclo administrativo de la importación, actualizar los costos en el inventario de la compañía y habilitar la facturación de venta con costos reales.

---

## Proceso de Consolidación y Envío

1. **Verificación de Prerrequisitos**: El sistema valida que el embarque cuente con:
   - Guía Confirmada (REQ-18).
   - Costos Prorrateados (REQ-19).
   - Tipificación AF Definida (REQ-20).
   - Levante Autorizado por la DIAN.
2. **Resumen de Liquidación**: Se muestra una pantalla con los totales por concepto (FOB, Flete, Seguro, Arancel, IVA) y el total a capitalizar por equipo.
3. **Confirmación de Cierre**: El usuario debe confirmar explícitamente que la información es correcta.
4. **Ejecución de Interfaz**:
   - El sistema invoca el servicio de integración con D365.
   - Envía los datos para la creación del **Landed Cost** (Costo en Tierra).
5. **Cierre de Ciclo**: Si la comunicación es exitosa, el embarque cambia a estado "Consolidado Definitivo" y se bloquea totalmente para edición.

---

## Reglas de Negocio

| ID | Regla |
| :--- | :--- |
| **RN-01** | **Bloqueo Post-Envío**: Una vez la información es recibida exitosamente por D365, el SII no permite ninguna modificación ni reversión manual. |
| **RN-02** | **Manejo de Errores de Servicio**: Si el servicio de D365 retorna un error, el embarque debe permanecer en estado "Error de Envío" y registrar el detalle técnico para el equipo de soporte. |
| **RN-03** | **Atomicidad de la Transacción**: El envío debe ser atómico (todo el embarque o nada) para evitar descuadres entre la guía en el SII y el Landed Cost en D365. |
| **RN-04** | **Consistencia Contable**: Los códigos de cuenta contable enviados a D365 deben derivarse directamente de la tipificación Activo Fijo (REQ-20) y la marca del equipo. |
| **RN-05** | **Idempotencia**: El sistema debe asegurar que un reintento de envío no genere duplicidad de registros en D365. |

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Consolidación y Envío Exitoso
```gherkin
Dado un embarque con todos los costos validados y tipificados
Cuando el analista confirme la consolidación definitiva
Entonces el sistema debe enviar los datos al servicio de D365
  Y recibir una confirmación de "Registro Exitoso"
  Y cambiar el estado del embarque a "Consolidado Definitivo".
```

### Escenario 2 – Reintentos por Falla Técnica
```gherkin
Dado que el servicio de D365 no está disponible
Cuando se intente consolidar
Entonces el sistema debe registrar el intento fallido
  Y mantener el embarque en estado "Error de Envío"
  Y habilitar el botón "Reintentar Envío".
```

---

## Notas Técnicas
- **Servicio Web**: Integración vía REST/OData hacia el módulo de *Landed Cost* de Dynamics 365 Finance & Operations.
- **Tablas de Interfaz**: `SIPDYNIF` (Cabecera) y `SIPDYNIF1` (Líneas de costo por equipo).
- **Log de Transacciones**: Se requiere una tabla de log para auditar cada interacción con el ERP (Request/Response).
