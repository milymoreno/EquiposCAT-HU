# HU-IE-32: Asignación de Registro y/o Licencia de Importación

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** GESTIÓN DE VUCE / LICENCIAS  
**Requerimiento Relacionado:** REQ-32 (Funcionalidad compartida con CrossDocking)  
**Responsable:** Deisy Rincón  
**Versión:** 1.0  
**Fecha de creación:** 2026-03-05  
**Estado:** Nueva.

> [!NOTE]
> **Contexto de Proceso Compartido**: Este requerimiento de gestión de licencias y saldos se adopta del modelo de *CrossDocking* para ser implementado en **Importación de Equipos CAT**, compartiendo el motor de control de cupos y vencimientos.

---

## Historia de Usuario

### Como:
Analista de Comercio Exterior (VUCE)

### Quiero:
Asignar el número de registro o licencia de importación a cada modelo y tipo de equipo de forma masiva o individual.

### Para:
Controlar los saldos y vencimientos de las licencias autorizadas, asegurando que cada nacionalización cuente con el respaldo legal correspondiente ante la DIAN/VUCE.

---

## Funcionalidades Clave

1.  **Asignación por Modelo/Tipo**: El sistema debe permitir cruzar las licencias cargadas con los modelos de equipos (Ej: Excavadora, Motor) y tipos específicos.
2.  **Control de Saldos**:
    *   **Cupo Autorizado**: Cantidad total permitida por la licencia.
    *   **Cupo Utilizado**: Cantidad ya nacionalizada o asignada a una DI.
    *   **Cupo Disponible**: Saldo restante que alerta si es insuficiente para una nueva guía.
3.  **Gestión de Vencimientos**: Alerta proactiva cuando una licencia está próxima a expirar (Ej: 30 días antes).

---

## Reglas de Negocio

| ID    | Regla |
|-------|-------|
| **RN-01** | **Prioridad de Consumo**: El sistema debe sugerir licencias por orden de vencimiento (PEPS) para evitar que expiren cupos. |
| **RN-02** | **Validación de Cupo**: No se puede asociar una guía a una licencia si la cantidad de la guía supera el saldo disponible del ítem de la licencia. |
| **RN-03** | **Bloqueo de Nacionalización**: Los equipos sin licencia asignada (en casos que aplique) no pueden avanzar al proceso de registro de DI (REQ-20). |

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Asignación de Licencia con Éxito
```gherkin
Dado que tengo una licencia 'L-500' con cupo de 10 unidades de 'GENERADORES'
  Y una nueva guía parcializada con 2 unidades de 'GENERADORES'
Cuando el analista Deisy Rincón asocia la guía a la licencia
Entonces el Cupo Utilizado de la licencia pasa a 2
  Y el Saldo Disponible queda en 8.
```

---

## Notas Técnicas
- **Integración**: Los datos de equipos deben venir del catálogo jalar del ERP (REQ-15-01).
- **Tablas**: Impacto en `sip_licencias`, `sip_licencia_detalles` y `sip_guia_licencias`.
- **Notificaciones**: Interfaz de alertas manuales (Ej: "Sin Licencia") detallada en HU-IE-15-04.
