# HU-IE-16: Integración con Logística Internacional para Recepción de BL

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** INTEGRACIÓN LOGÍSTICA INTERNACIONAL  
**Requerimiento Original:** REQ-16 — El sistema se integra con Logística Internacional para obtener información del BL.  
**Versión:** 2.0  
**Fecha de revisión:** 2026-03-05  
**Estado:** Revisada con base en sesión de levantamiento (02-Mar-2026)

---

## Historia de Usuario

### Como:
Sistema SII 2.0 / Analista de Comercio Exterior

### Quiero:
Recibir automáticamente la información del BL (Bill of Lading) desde el sistema de Logística Internacional, vinculándola mediante la "llave" compuesta por el **Número de Guía + Dealer**.

### Para:
Garantizar que la información del transporte internacional esté disponible en el SII de forma oportuna, permitiendo la consolidación de facturas y la posterior generación de los procesos de nacionalización sin errores de digitación manual.

---

## Contexto del Proceso (As-Is)

1. La información del transporte (BL/Guía) nace en el sistema de Logística Internacional.
2. Esta información es fundamental para los procesos posteriores de **Asignación de Registro (REQ-17)** y **Generación de Documentos de Transporte (REQ-18)**.
3. El **Dealer** es un código que identifica el destino o puerto de llegada (Ej: R490 = Puerto de Buenaventura).
4. La integración debe asegurar que las facturas sincronizadas en el **REQ-15** puedan "colgarse" o asociarse correctamente a este BL.

---

## Descripción Funcional

El sistema debe:

1. **Consumir la información del BL** proveniente de Logística Internacional mediante integración (API/Web Service).
2. **Validar la llave de integración**: Número de Guía + Dealer.
3. **Mapear el Dealer con el Puerto correspondiente**:
   - R490 -> Puerto de Buenaventura.
   - (Otros dealers según tabla maestra).
4. **Permitir la asociación de facturas**: Una vez recibido el BL, el sistema debe permitir que las facturas (sincronizadas de D365) se vinculen a este BL basado en la coincidencia de datos de origen/proveedor.
5. **Estado de la Integración**: El sistema debe reflejar si la información del BL fue recibida exitosamente o si hubo fallos en la comunicación.

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Recepción Exitosa de BL
```gherkin
Dado que el sistema de Logística Internacional genera un nuevo BL
Cuando el SII 2.0 consuma la información mediante la llave Guía + Dealer
Entonces el sistema debe crear el registro del BL en el SII
  Y debe asignar el puerto correspondiente basado en el código del Dealer (ej: R490).
```

### Escenario 2 – Asociación de Facturas al BL
```gherkin
Dado que un BL ha sido recibido exitosamente en el SII
Cuando el analista consulte las facturas sincronizadas de D365
Entonces el sistema debe permitir filtrar y asociar las facturas que corresponden a dicho BL
  Y debe validar que el proveedor e Incoterm coincidan para la consolidación.
```

### Escenario 3 – Error en la llave Guía + Dealer
```gherkin
Dado que llega información de logística con un Dealer inexistente o Guía inválida
Cuando el sistema intente procesar la integración
Entonces no debe crear el registro
  Y debe reportar el error en el log de integración para revisión técnica.
```

---

## Reglas de Negocio Clave

| ID | Regla |
| :--- | :--- |
| **RN-01** | La llave de integración es obligatoriamente **Número de Guía + Dealer**. |
| **RN-02** | El Dealers **R (Repuestos)** y **E (Equipos)** deben estar correctamente diferenciados para evitar cruces de información (Angie, línea 905). |
| **RN-03** | No se puede generar un embarque si el BL no ha sido integrado o registrado previamente. |
| **RN-04** | El Dealer determina automáticamente el puerto de llegada en el SII. |

---

## Pendientes Identificados

1. Definir la tabla maestra completa de Dealers vs Puertos.
2. Confirmar la frecuencia de actualización de la información desde Logística Internacional.

---

## Notas Técnicas
- Integración vía API REST con Logística Internacional.
- Uso de el código de 6 dígitos del proveedor para la validación cruzada entre factura y BL.
