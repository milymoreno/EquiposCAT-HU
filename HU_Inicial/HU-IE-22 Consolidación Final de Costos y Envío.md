# HU-IE-22-01: Consolidación Final de Costos y Envío de Información a D365

**Proceso:** IMPORTACIÓN DE EQUIPOS CAT  
**Subproceso:** CONSOLIDACIÓN DE COSTOS Y ENVÍO A D365  
**Requerimiento Original:** 22 - Consolidación de costos y envío a Dynamics 365.

---

### Como:
Analista de Comercio Exterior  

### Quiero:
Consolidar definitivamente los costos de la declaración  

### Para:
Enviar la información contable y fiscal final a D365.

---

## Prerrequisitos

Antes de consolidar deben cumplirse:

- Guía confirmada.
- Licencia asignada (si aplica).
- Costos validados.
- Activo Fijo definido.
- Declaración generada.
- Sticker asignado.
- Levante confirmado.

---

## Reglas de Negocio

### RN-01: Confirmación Explícita
Antes de consolidar el sistema debe mostrar:

"¿Confirma que la información de costos y tipificación es correcta?"

Solo tras confirmación explícita debe continuar.

---

### RN-02: Cálculo Final

Debe recalcular:

- Base imponible
- IVA
- Arancel
- Total nacionalización
- Distribución por equipo

---

### RN-03: Integración con D365

Debe enviar información a D365 mediante servicio seguro.

Debe incluir:

- ID guía
- ID equipo
- Base imponible
- IVA
- Arancel
- Total
- Código contable
- Indicador Activo Fijo

---

### RN-04: Integridad Transaccional

Si falla el envío:

- No debe marcarse como consolidado.
- Debe registrarse error técnico.
- Debe permitir reintento controlado.

---

### RN-05: Bloqueo Definitivo

Una vez consolidado:

- No permitir modificar costos.
- No permitir modificar Activo Fijo.
- No permitir modificar licencia.
- No permitir eliminar facturas.

---

### RN-06: Estados

Debe manejar estados:

- Pendiente Consolidación
- Enviando a D365
- Enviado Exitoso
- Error Envío
- Consolidado Definitivo

---

### RN-07: Control de Reintento

Si envío falla:

- Permitir reintento manual.
- Registrar cada intento.
- No duplicar registros en D365.

---

## Integración Técnica

Debe impactar:

- SIPIDYNL1
- SIPIDYNL2
- SIPOVLR3
- SIPDYNIF
- SIPDYNIF1

Debe generar referencia cruzada entre:

- Guía
- Declaración
- Registro contable D365

---

## Monitoreo

Debe permitir visualizar:

- Guías consolidadas hoy
- Guías con error de envío
- Guías pendientes de consolidar
- Historial de reintentos

---

## Auditoría Financiera

Debe registrar:

- Usuario que consolida
- Fecha y hora
- Totales enviados
- Resultado de envío
- ID transacción D365

---

## Criterios de Aceptación (Gherkin)

### Escenario 1 – Consolidación exitosa
Dado que todos los prerrequisitos se cumplen  
Cuando el usuario confirme consolidación  
Entonces debe enviarse información a D365  
Y cambiar estado a Consolidado Definitivo.

---

### Escenario 2 – Error de envío
Dado que falle la comunicación con D365  
Cuando se intente consolidar  
Entonces debe quedar en estado Error Envío  
Y permitir reintento.

---

### Escenario 3 – Intento posterior a consolidación
Dado que la guía está consolidada  
Cuando se intente modificar  
Entonces debe bloquear la operación.