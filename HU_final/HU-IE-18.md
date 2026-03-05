# HU-IE-18: Generación de Documento de Transporte (Guía / HBL)

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** GENERACIÓN DOCUMENTO DE TRANSPORTE  
**Requerimiento Original:** REQ-18 — Permite crear un embarque (documento de transporte) asociando facturas y BL.  
**Versión:** 3.0  
**Fecha de revisión:** 2026-03-05  
**Estado:** Actualizada con detalles de interfaz visual (Notas de Reunión).

---

## Historia de Usuario

### Como:
Analista de Comercio Exterior

### Quiero:
Generar un documento de transporte (Guía/HBL) en el SII 2.0, validando explícitamente las cantidades de facturas Z95 e INV antes de la confirmación final.

### Para:
Garantizar que el embarque físico coincida con la documentación contable y logística, evitando descuadres en los totales de la nacionalización.

---

## Proceso de Generación (Detalle Visual)

1. **Pantalla de Confirmación de Insumos**: Antes de generar la guía, el sistema presenta un modal/ventana de validación de cantidades acumuladas:
   - **Cantidades Z95**: Sumatoria de unidades en facturas origen (Ej: 6 unidades).
   - **Cantidades INV**: Sumatoria de unidades en facturas de venta PSC (Ej: 6 unidades).
   - El usuario debe confirmar estar seguro de generar la guía (S/N).
2. **Resumen de Valores Totales**: Una vez confirmada, se visualiza el resumen de la guía generada:
   - **Número de la Guía**: Identificador HBL (Ej: H559855).
   - **Dealer Code**: Código asignado (Ej: R48E).
   - **Número de líneas**: Total de ítems únicos (Ej: 155).
   - **Total cantidades**: Volumen total de piezas (Ej: 925).
   - **Valor guía**: Valor monetario total (Ej: 45,381.53).
3. **Cierre**: El usuario termina el proceso (F3/Terminar).

---

## Reglas de Negocio

| ID | Regla |
| :--- | :--- |
| **RN-01** | **Validación de Cantidades**: No se permite generar la guía si las cantidades totales de Z95 e INV presentan discrepancias insalvables según parametrización. |
| **RN-02** | **Confirmación Explícita**: El sistema debe requerir una confirmación antes de la persistencia final del HBL. |
| **RN-03** | **Visualización de Resumen**: Es obligatorio mostrar el valor total de la guía y el conteo de líneas antes de finalizar. |

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Confirmación de Cantidades
```gherkin
Dado que el analista tiene 6 unidades en Z95 y 6 en INV
Cuando presione "F10: Confirmar" en la ventana de validación
Entonces el sistema debe proceder a generar el documento H559855.
```

---

## Notas Técnicas
- **Interfaz**: Reflejar el diseño mostrado en las capturas de pantalla (Sistema de Importaciones - Forma 03).
- **Tablas**: SIP_GUIAS_HBL y SIP_GUIA_FACTURAS.
