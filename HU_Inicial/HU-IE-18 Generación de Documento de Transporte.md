# HU-IE-18: Generación de Documento de Transporte (Guía) para Equipos CAT

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** GENERACIÓN DOCUMENTO DE TRANSPORTE  
**Requerimiento Original:** 18 - Permite crear un embarque (documento de transporte) asociando facturas y BL.

**Unificación Funcional Obligatoria:**  
Debe reutilizar la lógica transversal definida en CrossDocking para generación de guías y flujo posterior de declaración.

---

### Como:
Analista de Comercio Exterior  

### Quiero:
Generar un documento de transporte (guía) asociando BL y facturas  

### Para:
Iniciar formalmente el proceso de nacionalización y habilitar el flujo posterior de declaración y consolidación.

---

## Dependencias Previas

Antes de generar la guía deben cumplirse:

- Facturas sincronizadas desde D365 (HU-IE-15-01).
- BL recibido y validado (HU-IE-16-01).
- Proveedor válido.
- Compañía activa.
- Dealer logístico válido.

---

## Información Obligatoria

Para crear la guía:

- Número de guía (generado automáticamente)
- Compañía
- Dealer logístico
- Número BL
- Fecha guía
- Tipo mercancía
- INCOTERM
- Moneda
- Total FOB
- Total unidades
- Peso bruto

---

## Reglas de Negocio

### RN-01: Unicidad de Guía
Número Guía + Compañía = identificador único.

---

### RN-02: Asociación BL obligatoria
No permitir generar guía sin BL válido.

---

### RN-03: Consistencia de BL
No permitir:
- Asociar facturas de distintos BL.
- Mezclar compañías.
- Mezclar dealers incompatibles.

---

### RN-04: Validación Dealer
Debe validar contra tabla oficial de dealers logísticos.

No permitir:
- Dealer inactivo.
- Dealer de otra compañía.

---

### RN-05: Facturas ya utilizadas
No permitir asociar facturas que:

- Ya estén en otra guía activa.
- Ya estén consolidadas.
- Ya estén declaradas.

---

### RN-06: Eliminación Condicionada
Permitir eliminar factura de guía solo si:

- Estado = Borrador.
- No existe licencia asignada.
- No existe declaración generada.

No permitir si:

- Estado ≥ Confirmada.
- Existe declaración.
- Existe consolidación.

---

### RN-07: Control de Estados

La guía debe manejar estados:

- Borrador
- Confirmada
- Licencia Asignada
- En Proceso Declaración
- Declarada
- Con Sticker y Levante
- Consolidada
- Cerrada
- Anulada

El sistema debe impedir transiciones inválidas.

---

### RN-08: Control de Concurrencia
Si dos usuarios editan simultáneamente:

- Solo debe persistirse la última versión válida.
- Debe advertirse conflicto de edición.

---

### RN-09: Generación Masiva (Si se habilita)
Si se implementa carga masiva:

- Debe validarse estructura del archivo.
- Debe permitir procesamiento parcial.
- Debe generar reporte de errores por línea.

---

## Integración con Flujo Transversal

Una vez confirmada la guía:

1. Se habilita asignación de licencia (HU-IE-17-01).
2. Se habilita ingreso y validación de costos (HU-IE-19-01).
3. Se habilita flujo de declaración (unificado con CrossDocking).
4. Se habilita recepción de aceptación y levante.
5. Se habilita consolidación (RQ 22).

La generación de DIM NO debe desarrollarse como lógica independiente en Equipos.
Debe reutilizar el módulo transversal.

---

## Monitoreo

El sistema debe permitir visualizar:

- Total guías por estado.
- Guías pendientes de licencia.
- Guías pendientes de declaración.
- Guías pendientes de consolidación.
- Guías con inconsistencias.

---

## Auditoría

Debe registrar:

- Usuario que crea.
- Usuario que confirma.
- Fecha y hora.
- Facturas asociadas.
- BL asociado.
- Dealer.
- Cambios realizados.
- Historial de estados.

---

## Registro de Logs Técnicos

Cada acción debe registrar:

- Tipo de operación (Crear / Editar / Eliminar / Confirmar).
- Resultado.
- Usuario.
- Timestamp.
- Datos modificados.

---

## Validaciones Técnicas

- No permitir caracteres truncados.
- Validar longitud máxima de referencias.
- Validar consistencia de moneda.
- Validar que facturas pertenezcan a la compañía.
- Validar que facturas estén en estado válido.

---

## Escenarios Críticos Detectados en Sesión

- El flujo posterior debe unificarse con CrossDocking.
- No debe duplicarse generación de archivos SIACO.
- El sistema actual tiene pasos manuales que deben centralizarse.
- La guía habilita el resto del flujo.

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Generación exitosa
Dado BL válido  
Y facturas válidas  
Cuando se genere guía  
Entonces debe crearse en estado Borrador.

---

### Escenario 2 – Confirmación
Dado guía válida  
Cuando el usuario confirme  
Entonces debe cambiar estado a Confirmada.

---

### Escenario 3 – Eliminación bloqueada
Dado guía en estado Confirmada  
Cuando se intente eliminar factura  
Entonces debe bloquear operación.

---

### Escenario 4 – Factura ya usada
Dado factura asociada a otra guía activa  
Cuando se intente asociar  
Entonces debe bloquear.

---

### Escenario 5 – Concurrencia
Dado dos usuarios editando simultáneamente  
Cuando uno confirme cambios  
Entonces el segundo debe recibir advertencia de conflicto.