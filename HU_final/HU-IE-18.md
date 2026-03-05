# HU-IE-18: Generación de Documento de Transporte (Guía / HBL)

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** GENERACIÓN DOCUMENTO DE TRANSPORTE  
**Requerimiento Original:** REQ-18 — Permite crear un embarque (documento de transporte) asociando facturas y BL.  
**Versión:** 2.0  
**Fecha de revisión:** 2026-03-05  
**Estado:** Revisada con base en sesión de levantamiento (02-Mar-2026)

---

## Historia de Usuario

### Como:
Analista de Comercio Exterior

### Quiero:
Generar un documento de transporte (Guía/HBL) en el SII 2.0, asociando el número de BL (recibido de Logística) con las facturas (sincronizadas de D365).

### Para:
Formalizar el embarque en el sistema, consolidar los pesos y unidades, y habilitar los pasos posteriores de asignación de licencias y generación de la Declaración de Importación (DI).

---

## Proceso de Generación

1. **Selección de Insumos**: El usuario selecciona el **Número de BL + Dealer** (llave de integración).
2. **Asociación de Facturas**: Se listan las facturas sincronizadas asociadas a ese proveedor y BL. El usuario confirma cuáles pertenecen a esta guía específica.
3. **Consolidación de Datos**:
   - El sistema suma automáticamente: Total FOB, Total Unidades y Peso Bruto.
   - Estos datos deben coincidir con la información reportada por Logística Internacional.
4. **Asignación de Estado**: La guía se crea inicialmente en estado **Borrador**.

---

## Reglas de Negocio

| ID | Regla |
| :--- | :--- |
| **RN-01** | **Unicidad**: La combinación de Número de Guía + Compañía es única. |
| **RN-02** | **Integridad del BL**: No se puede generar una guía sin un BL válido previamente registrado/recibido (REQ-16). |
| **RN-03** | **Exclusividad de Facturas**: Una factura solo puede estar asociada a una guía activa a la vez. |
| **RN-04** | **Restricción de Edición**: Una vez la guía cambia a estado "Confirmada" o tiene una "Declaración Generada", no permite eliminar o agregar facturas. |
| **RN-05** | **Validación de Dealer**: El Dealer debe corresponder a la compañía y al puerto de llegada identificado en el BL. |

---

## Flujo de Estados de la Guía

El sistema debe controlar el ciclo de vida de la guía mediante los siguientes estados:

1. **Borrador**: Creación inicial y asociación de facturas.
2. **Confirmada**: Datos verificados, lista para asignación de licencia.
3. **Licencia Asignada**: (Si aplica) Se ha vinculado el Registro/Licencia (REQ-17).
4. **Declarada**: Se ha generado la DI y se tiene número de aceptación.
5. **Consolidada**: Los costos de nacionalización han sido aplicados (REQ-22).
6. **Cerrada**: Proceso finalizado.

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Asociación Exitosa
```gherkin
Dado que el analista selecciona el BL 'XYZ123' y el Dealer 'R490'
Cuando asocie las facturas 'F-001' y 'F-002'
Entonces el sistema debe calcular el Peso Bruto Total
  Y crear la guía en estado Borrador.
```

### Escenario 2 – Bloqueo por Factura Duplicada
```gherkin
Dado que la factura 'F-001' ya está asociada a la Guía 'G-008'
Cuando el analista intente asociarla a una nueva Guía
Entonces el sistema debe mostrar una alerta: "Factura ya asociada a la Guía G-008" 
  Y bloquear la acción.
```

---

## Notas Técnicas
- **Interfaz**: Debe utilizar los componentes de búsqueda transversal de facturas desarrollados en el REQ-15.
- **Persistencia**: Impacta tablas SIPIDYNL1, SIPIDYNL2 y SIPOVLR3 (específicas de Equipos).
