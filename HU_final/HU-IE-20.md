# HU-IE-20: Registro y Persistencia de Tipificación Activo Fijo (S/N)

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** INGRESO DE DATOS COMPLEMENTARIOS DE DECLARACIÓN  
**Requerimiento Original:** REQ-20 — Registrar en el sistema la tipificación de activo fijo S/N.  
**Versión:** 2.0  
**Fecha de revisión:** 2026-03-05  
**Estado:** Finalizada con base en requisitos de persistencia y trazabilidad.

---

## Historia de Usuario

### Como:
Analista de Comercio Exterior

### Quiero:
Registrar de manera explícita y persistente la tipificación de un equipo como Activo Fijo (S/N) en el sistema.

### Para:
Garantizar que el tratamiento contable y fiscal enviado a Dynamics 365 sea correcto y que el proceso de nacionalización cumpla con los requisitos legales de auditoría.

---

## Proceso de Registro de Tipificación

1. **Identificación del Equipo**: El sistema lista los equipos asociados a la Guía (REQ-18) seleccionada.
2. **Definición de Activo Fijo**: El analista selecciona para cada ítem si corresponde a un **Activo Fijo (S)** o no **(N)**.
3. **Validación Obligatoria**: Antes de permitir la consolidación del embarque, el sistema verifica que todos los equipos tengan esta tipificación definida.
4. **Persistencia de Datos**: La decisión se guarda en la base de datos junto con el usuario responsable y la marca de tiempo.
5. **Impacto en Flujo**:
   - Affecta la base imponible y el cálculo de IVA (REQ-19).
   - Determina la cuenta contable de destino para el envío de información a D365 (REQ-22).

---

## Reglas de Negocio

| ID | Regla |
| :--- | :--- |
| **RN-01** | **Persistencia Explícita**: El flag de Activo Fijo debe almacenarse físicamente en la base de datos (`AF_INDICATOR`), no ser calculado al vuelo. |
| **RN-02** | **Bloqueo por Omisión**: No se permite avanzar al estado "Consolidado" o "Enviado a D365" si existen ítems sin tipificación. |
| **RN-03** | **Trazabilidad de Cambios**: Cualquier modificación en la tipificación después del registro inicial debe generar un registro en el log de auditoría con la justificación. |
| **RN-04** | **Inmutabilidad por Estado**: Una vez el embarque está consolidado, la tipificación no puede ser modificada. |
| **RN-05** | **Integridad con DI/DAV**: El dato registrado en la tipificación debe ser el mismo que se utilice para la generación de la Declaración de Importación (DI) y Declaración Andina de Valor (DAV). |

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Validación de Registro Obligatorio
```gherkin
Dado que el analista intenta consolidar el embarque 'EMB-500'
Cuando existan equipos sin la marca de Activo Fijo definida
Entonces el sistema debe mostrar el error: "Debe tipificar todos los equipos como Activo Fijo (S/N) antes de continuar."
```

### Escenario 2 – Persistencia y Consulta
```gherkin
Dado un equipo 'EXC-001' marcado como Activo Fijo (S)
Cuando se consulte la guía asociada después de cerrar sesión
Entonces el sistema debe mostrar el equipo con el flag 'S' persistido.
```

---

## Notas Técnicas
- **Campo DB**: `SIPOVLR3.AF_INDICATOR` (o similar en tablas de detalle de Equipos).
- **Tablas Relacionadas**: `SIPDYNIF`, `SIPDYNIF1` (donde se prepara la información para el envío al ERP).
- **Interfaz**: Se recomienda una visualización tipo rejilla que permita la edición rápida de todos los ítems de la guía.
