# HU-IE-19: Ingreso y Prorrateo de Costos de Nacionalización

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** INGRESO DE COSTOS PARA NACIONALIZACIÓN  
**Requerimiento Original:** REQ-19 — Permite agregar gastos de importación según término de negociación INCOTERM y distribuirlos.  
**Versión:** 2.0  
**Fecha de revisión:** 2026-03-05  
**Estado:** Finalizada con base en levantamiento técnico de prorrateo y consolidación.

---

## Historia de Usuario

### Como:
Analista de Comercio Exterior

### Quiero:
Ingresar y validar los costos adicionales de nacionalización (fletes, seguros, aranceles, IVA) y distribuirlos (prorrateo) entre los equipos del embarque.

### Para:
Establecer el costo final de los equipos en el inventario de D365 y asegurar que la liquidación de impuestos sea exacta según la normativa aduanera.

---

## Proceso de Gestión de Costos

1. **Sincronización de Cargos**: El sistema lee automáticamente los "Cargos" registrados en la factura original en D365 (FOB, Flete, Seguro, INLAND).
2. **Validación de Incoterms**: El sistema verifica que los costos ingresados sean coherentes con el término de negociación (ej. si es CIF, el seguro ya debe estar incluido).
3. **Prorrateo (Distribución)**:
   - El analista selecciona el método de distribución: **Valor FOB**, **Peso**, o **Unidades**.
   - El sistema calcula la proporción de costos adicionales para cada línea de equipo.
4. **Manejo de Activo Fijo (AF)**:
   - El sistema permite marcar ítems como **Activo Fijo (S/N)**.
   - Esta decisión altera la base de cálculo del IVA y la cuenta contable de destino en D365.
5. **Cierre por Consolidación**: Una vez validados, los costos se consolidan para evitar modificaciones posteriores.

---

## Reglas de Negocio

| ID | Regla |
| :--- | :--- |
| **RN-01** | **Fuente Única**: Los costos base deben provenir de la sincronización de D365. No se permite creación manual de cargos base sin referencia. |
| **RN-02** | **Bloqueo de Consolidación**: Una vez ejecutado el proceso de "Consolidación de Costos", no se permiten correcciones en el SII. Cualquier cambio requiere anulación en el ERP. |
| **RN-03** | **Exactitud de Prorrateo**: La suma de los valores prorrateados por ítem debe coincidir exactamente (al centavo) con el total del costo ingresado. |
| **RN-04** | **Regla de Activo Fijo**: Los equipos marcados como AF deben segregarse en los reportes de IVA para cumplir con la normativa de exclusión/descuento de IVA en bienes de capital. |
| **RN-05** | **Dependencia de Guía**: No se pueden ingresar costos a un embarque que no tenga asociada una Guía (REQ-18) confirmada. |

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Prorrateo por Valor FOB
```gherkin
Dado un embarque con 2 equipos (Equipo A: $70, Equipo B: $30)
Y un flete total de $10
Cuando se seleccione prorrateo por Valor FOB
Entonces el sistema debe asignar $7 al Equipo A
  Y $3 al Equipo B.
```

### Escenario 2 – Bloqueo por Consolidación
```gherkin
Dado que el embarque 'EMB-001' tiene estado 'Consolidado'
Cuando el analista intente modificar el valor del Seguro
Entonces el sistema debe mostrar el error: "Embarque consolidado. No se permiten modificaciones."
```

---

## Notas Técnicas
- **Impacto Tablas**: SIPIDYNL1, SIPIDYNL2, SIPOVLR3 (Cabecera y detalle de costos).
- **Flag AF**: Debe persistirse el campo `AF_INDICATOR` en la tabla de detalle para trazabilidad contable.
- **Validación Automática**: El sistema debe alertar si el Valor FOB + Flete + Seguro no coincide con la base imponible reportada en la declaración (REQ-20).
