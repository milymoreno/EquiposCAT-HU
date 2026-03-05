# HU-IE-19: Ingreso, Validación y Distribución de Costos de Nacionalización para Equipos CAT

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** INGRESO DE COSTOS PARA NACIONALIZACIÓN  
**Requerimiento Original:** 19 - Permite agregar gastos de importación según término de negociación INCOTERM.

---

### Como:
Analista de Comercio Exterior  

### Quiero:
Visualizar, validar y distribuir los costos asociados a la factura y al embarque  

### Para:
Calcular correctamente la base imponible de la declaración y preparar la consolidación contable hacia D365.

---

## Origen de Información

Los costos provienen del registro de facturas en D365 e incluyen:

- Valor equipo (unitario y total)
- Fletes
- Seguros
- INLAND
- Otros cargos
- Ajustes adicionales

La información se sincroniza mediante servicios (según HU-IE-15-01).

---

## Arquitectura

- No se permitirá modificación directa sobre datos originales sincronizados.
- La distribución se realizará sobre capa lógica interna.
- Debe soportar recalculo automático.
- Debe mantener integridad transaccional.

---

## Reglas de Negocio

### RN-01: Validación INCOTERM

El sistema debe validar coherencia entre costos y término de negociación:

Ejemplo:

- FOB → Permitir agregar flete.
- CIF → No permitir duplicar flete si ya viene incluido.
- DPU/DAP → Validar estructura correspondiente.

Si existe incoherencia:
- Generar advertencia.
- Permitir continuar solo con confirmación explícita.

---

### RN-02: No Duplicidad

No permitir registrar costos que:

- Ya existan en factura sincronizada.
- Ya estén incluidos en cálculo previo.
- Ya estén consolidados.

---

### RN-03: Distribución de Costos

El sistema debe permitir prorratear costos por:

- Valor FOB
- Cantidad
- Peso
- Criterio configurable

Debe permitir recalcular automáticamente si:

- Se elimina una factura.
- Se modifica Activo Fijo.
- Se cambia configuración IVA.

---

### RN-04: Integración con Activo Fijo (Dependencia RQ 20)

Si Activo Fijo = S:

- Aplicar código contable específico.
- Aplicar categoría IVA correspondiente.
- Aplicar distribución diferenciada si aplica.

Si Activo Fijo = N:

- Aplicar estructura contable distinta.

---

### RN-05: Categorías de IVA

Debe permitir parametrización de:

- 0%
- 5%
- 19%
- Otros configurables

El cálculo debe ser:

- Automático.
- Recalculable.
- Persistido en historial.

---

### RN-06: Bloqueo Posterior

No permitir modificar costos si:

- Existe declaración generada.
- Existe sticker asignado.
- Existe levante.
- Existe consolidación.
- Información ya fue enviada a D365.

---

### RN-07: Control de Concurrencia

Si dos usuarios editan costos simultáneamente:

- Debe aplicar control de versión.
- Debe advertir conflicto.
- No debe sobrescribir silenciosamente.

---

### RN-08: Integridad Transaccional

Si falla el proceso de prorrateo:

- No debe persistirse cálculo parcial.
- Debe revertirse completamente.

---

## Integración Técnica

Debe impactar las siguientes tablas:

- SIPIDYNL1
- SIPIDYNL2
- SIPOVLR3
- SIPDYNIF
- SIPDYNIF1

Debe registrar:

- Base imponible.
- IVA calculado.
- Total arancel.
- Códigos contables asociados.
- Indicador Activo Fijo.

---

## Estados del Cálculo

- Pendiente
- Calculado
- Validado
- Confirmado
- Bloqueado
- Consolidado

---

## Monitoreo

Debe permitir visualizar:

- Embarques con costos pendientes.
- Embarques con inconsistencias.
- Embarques recalculados.
- Historial de modificaciones.

---

## Auditoría Financiera

Debe registrar:

- Usuario que modifica.
- Fecha y hora.
- Valor antes.
- Valor después.
- Tipo de costo modificado.
- Justificación obligatoria.

---

## Registro de Logs Técnicos

Cada recalculo debe registrar:

- ID de proceso
- Timestamp
- Usuario
- Tipo de recalculo (Manual / Automático)
- Resultado
- Error técnico si aplica

---

## Escenarios Críticos Detectados en Sesión

- La decisión de Activo Fijo impacta el cálculo.
- Existen múltiples tablas técnicas involucradas.
- El sistema actual no guarda explícitamente flag persistente.
- El nuevo sistema debe persistir esa decisión.
- Consolidación depende de este cálculo.

---

## Validaciones Técnicas

- No permitir valores negativos.
- Validar precisión decimal.
- Validar consistencia moneda.
- Validar que suma de distribución coincida con total.
- Validar redondeo configurable.

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Cálculo correcto
Dado costos válidos  
Y Activo Fijo definido  
Cuando se confirme cálculo  
Entonces debe distribuir correctamente y guardar resultado.

---

### Escenario 2 – Intento posterior a declaración
Dado que ya existe declaración  
Cuando se intente modificar costos  
Entonces debe bloquear la operación.

---

### Escenario 3 – Concurrencia
Dado dos usuarios editando simultáneamente  
Cuando uno confirme  
Entonces el segundo debe recibir advertencia de conflicto.

---

### Escenario 4 – Recalculo automático
Dado que se modifica Activo Fijo  
Cuando el sistema detecte cambio  
Entonces debe recalcular automáticamente la distribución.

---

### Escenario 5 – Error de cálculo
Dado que falle el proceso de prorrateo  
Cuando se consulte el embarque  
Entonces debe permanecer en estado Pendiente y registrar error técnico.