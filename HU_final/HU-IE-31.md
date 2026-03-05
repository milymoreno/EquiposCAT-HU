# HU-IE-31: Parcialización de Documento de Transporte (Guía / HBL)

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** GESTIÓN DE EMBARQUES  
**Requerimiento Relacionado:** REQ-31 (Funcionalidad compartida con CrossDocking)  
**Versión:** 1.0  
**Fecha de creación:** 2026-03-05  
**Estado:** Nueva.

> [!NOTE]
> **Contexto de Proceso Compartido**: Aunque este requerimiento surge originalmente del flujo de *CrossDocking*, su funcionalidad de parcialización es requerida y aplicada al proceso de **Importación de Equipos CAT**, siguiendo la misma lógica de negocio y pantallas (`FORM401`/`FORMA03`).

---

## Historia de Usuario

### Como:
Analista de Comercio Exterior / Logística

### Quiero:
Tener la capacidad de generar documentos de transporte (Guías/HBL) parciales a partir de un BL o conjunto de facturas inicial.

### Para:
Gestionar embarques que llegan en diferentes momentos o que requieren trámites de nacionalización independientes, permitiendo dividir la carga por factura, por referencia o por una cantidad específica de unidades de una referencia.

---

## Proceso Técnico: Generación de Guías Hijas (Pantalla FORMA03)

**Responsable:** Deisy Rincón

Para el control de las nacionalizaciones parciales, el sistema debe implementar una jerarquía de documentos:

1.  **Nomenclatura**: Las guías resultantes de una parcialización deben adoptar un sufijo numérico secuencial.
    *   *Ejemplo real*: Guía Madre `I478183` -> Guía Hija `I478183-001` (Dealer Code: `R46E`).
2.  **Consolidación de Totales**: La pantalla `FORMA03` debe mostrar el resumen técnico de la guía hija generada:
    *   **Número de líneas**: Total de ítems únicos seleccionados.
    *   **Total cantidades**: Sumatoria de unidades físicas (Ej: 1,495 según caso de prueba).
    *   **Valor guía**: Valor FOB/CFR consolidado de la porción parcializada (Ej: 63,486.21 USD).

---

## Reglas de Negocio

| ID | Regla |
| :--- | :--- |
| **RN-01** | **Gestión de Saldos**: El sistema debe calcular automáticamente el `Saldo por Nacionalizar` restando las cantidades ya parcializadas de la `Cantidad Factura` original. |
| **RN-02** | **Trazabilidad de Origen**: La nueva guía parcializada debe mantener el vínculo con el BL y las facturas originales de D365. |
| **RN-03** | **Validación de Cantidad**: No se permite ingresar una `Cantidad a Nacionalizar` superior al `Saldo por Nacionalizar` actual. |
| **RN-04** | **Nomenclatura Serial**: Las guías hijas deben seguir el patrón `[Número_Original]-[Secuencial(001, 002...)]`. |

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Generación de Guía Hija
```gherkin
Dado que el analista Deisy Rincón parcializa la guía 'I478183'
Cuando confirma la selección en la pantalla FORMA03
Entonces el sistema debe generar el registro 'I478183-001'
  Y mostrar el total de 209 líneas y 1,495 unidades
  Y registrar el Valor Guía de 63,486.21.
```

---

## Notas Técnicas
- **Interfaz UI**: Implementar visor de totales por guía hija similar a `FORMA03`.
- **Persistencia**: El campo `guia_numero` en `sip_guias_hbl` debe ser alfanumérico para soportar el sufijo `-001`.
