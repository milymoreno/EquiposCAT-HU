# GLOSARIO UNIFICADO — Proceso Importación de Equipos CAT

> **Propósito:** Este documento consolida todos los términos de negocio y técnicos definidos a lo largo de las historias de usuario del proceso **Importación de Equipos CAT (REQ 15 a 22)**. Se actualiza progresivamente con cada HU revisada.  
> **Nivel:** Lenguaje accesible (estilo dummies) para toda la organización.

---

## Estado del Glosario

| HU | Proceso | Términos aportados | Estado |
|----|---------|-------------------|--------|
| HU-IE-15-01 | Sincronización Automática de Facturas | A, B, C, D, E, G, I, J, L, M, N, O, P, S, T, V | ✅ Completada |
| HU-IE-15-02 | Consulta y Validación de Facturas | A, B, C, E, f, G, I, M, P, R, S | ✅ Completada |
| HU-IE-15-03 | Creación Automática de Proveedores | C, D, E, M, P, S, T, V | ✅ Completada |
| HU-IE-16 | Integración con Logística Internacional | A, B, E, I, P, V | ✅ Completada |
| HU-IE-17 | Asignación de Registro/Licencia de Importación | — | 🔜 Pendiente |
| HU-IE-18 | Generación de Documento de Transporte | — | 🔜 Pendiente |
| HU-IE-19 | Ingreso de Costos de Nacionalización | — | 🔜 Pendiente |
| HU-IE-20 | Registro y Persistencia de Tipificación (DI/DAV) | — | 🔜 Pendiente |
| HU-IE-22 | Consolidación Final de Costos y Envío a D365 | — | 🔜 Pendiente |

---

## A

### API (Application Programming Interface)
Es el "canal oficial" por el que dos sistemas se comunican entre sí. En este proceso, D365 y el SII se comunican a través de una API: D365 expone sus datos y el SII los consulta de forma controlada. No es una conexión directa a la base de datos (prohibida), sino como una ventanilla donde uno pide la información y el otro la entrega con reglas definidas.  
📌 *Aplica a: HU-IE-15-01*

---

## B

### BL (Bill of Lading) — Conocimiento de Embarque
Documento que emite la naviera certificando que la mercancía fue embarcada en el barco. Es como la "partida de nacimiento" del embarque marítimo: identifica qué viene, cuánto pesa, quién lo envía y quién lo recibe. Es la llave principal para iniciar los procesos de nacionalización.  
📌 *Aplica a: HU-IE-15-01, HU-IE-16, HU-IE-18*

---

## C

### Cargos (en D365)
Costos adicionales que se asignan a una factura en D365 al momento de registrarla: fletes, seguros, transporte terrestre (INLAND), entre otros. Dependen del INCOTERM pactado con el proveedor. Se sincronizan junto con la factura al SII para calcular el costo total de importación del equipo.  
📌 *Aplica a: HU-IE-15-01, HU-IE-19*

---

### Código Proveedor D365 / Vendor Account (6 dígitos)
Código que usa D365 para identificar a un proveedor. Ejemplo: Caterpillar Inc. = `221372`. En el nuevo SII 2.0, es el **identificador oficial**. Este código también aparece en la declaración de importación presentada ante la DIAN. Es bidireccional: entra al SII y sale hacia la DI.  
📌 *Aplica a: HU-IE-15-01, HU-IE-15-03*

---

### Código Proveedor SII Legado (3 dígitos)
Código interno del SII antiguo para identificar proveedores. Ejemplo: Caterpillar = `021`. **Queda obsoleto** en el nuevo SII 2.0. Ya no se usará para registros nuevos.  
📌 *Aplica a: HU-IE-15-01, HU-IE-15-03*

---

### Compañía (en D365)
Código que identifica a cada empresa del grupo en D365. Ejemplo: GColza = `001`. El proceso de importación opera para **todas las compañías**, no solo una.  
📌 *Aplica a: HU-IE-15-01*

---

## D

### D365 / Dynamics 365
Sistema ERP (Enterprise Resource Planning) de Microsoft que usa la empresa para gestionar facturas, proveedores, órdenes de compra y toda la información financiera y de compras. Es el sistema fuente del que el SII recibe información. Cuando se dice "viene de D365", el dato fue creado o procesado allí.  
📌 *Aplica a: todas las HUs*

---

### Declaración de Importación (DI)
Documento oficial que se presenta ante la aduana colombiana (DIAN) para legalizar la entrada de mercancía al país. Sin una DI aprobada y con selectividad, la mercancía no puede salir de la zona aduanera. El código de proveedor D365 (6 dígitos) aparece en este documento.  
📌 *Aplica a: HU-IE-15-01, HU-IE-20*

---

### DIAN
Dirección de Impuestos y Aduanas Nacionales. Es la entidad del gobierno colombiano que controla el ingreso de mercancías al país. A través de sistemas como Open Comex, recibe las declaraciones de importación para otorgar selectividad.  
📌 *Aplica a: HU-IE-20*

---

### Duplicado (de factura)
Situación en que una factura llega dos veces con el mismo número **y** la misma fecha. El sistema debe rechazarla silenciosamente y registrar el evento en el log. No es un error del usuario: puede ocurrir por reprocesos automáticos en D365.  
📌 *Aplica a: HU-IE-15-01*

---

## E

### Embarque (Documento de Transporte / Guía)
Documento maestro que agrupa varias facturas bajo un mismo BL. Es la unidad de proceso para la nacionalización. Las facturas sincronizadas se asocian a un embarque para tramitar la importación ante la aduana.  
📌 *Aplica a: HU-IE-15-01, HU-IE-18*

---

## G

### GColza / Gecolsa
Compañía del grupo que distribuye los equipos CAT en Colombia. Opera con el código de compañía `001` en D365. Es uno de los actores cuyos proveedores y facturas se sincronizan al SII.  
📌 *Aplica a: HU-IE-15-01*

---

## I

### ID Equipo
Código único que identifica a cada equipo CAT específico (máquina, vehículo, etc.) dentro del pedido. Permite saber exactamente a qué máquina corresponde cada factura y cada costo de importación.  
📌 *Aplica a: HU-IE-15-01, HU-IE-17*

---

### INLAND
Costo del transporte terrestre desde el puerto de llegada (Buenaventura, Cartagena...) hasta el almacén del cliente en Colombia. Si el barco llega a Buenaventura, el INLAND es lo que cuesta llevarlo en camión hasta Bogotá o la ciudad de destino. Es uno de los "Cargos" registrados en D365.  
📌 *Aplica a: HU-IE-15-01, HU-IE-19*

---

### INCOTERM
Regla internacional que define **quién paga qué** en el transporte de mercancía y hasta dónde llega la responsabilidad del vendedor. Ejemplos:
- **DPU** – Delivered at Place Unloaded: vendedor entrega descargado en destino.
- **CFR** – Cost and Freight: vendedor paga el flete hasta el puerto destino.
- **CIF** – Cost, Insurance and Freight: como CFR pero el vendedor también paga el seguro.
- **FOB** – Free on Board: vendedor entrega en puerto origen; comprador paga el flete.

El INCOTERM determina qué Cargos se agregan al costo del equipo.  
📌 *Aplica a: HU-IE-15-01, HU-IE-19*

---

## J

### Job / Scheduler (sincronización)
Tarea automática programada que el sistema ejecuta periódicamente sin que nadie la active manualmente. El job de sincronización "va a D365", trae las facturas nuevas y las registra en el SII. Es como un mensajero que sale a buscar información a horarios definidos.  
📌 *Aplica a: HU-IE-15-01*

---

## L

### Log de Sincronización
Registro automático que guarda todo lo ocurrido durante cada ejecución del proceso de sincronización: cuántas facturas llegaron, cuántas se insertaron, cuántas se rechazaron y por qué. Sirve para auditoría, detección de problemas y trazabilidad operativa.  
📌 *Aplica a: HU-IE-15-01*

---

## M

### Monitoreo de Sincronización
Pantalla o reporte dentro del SII que muestra el estado de la última sincronización: Exitosa / Parcial / Fallida. Permite al equipo detectar problemas sin revisar logs técnicos.  
📌 *Aplica a: HU-IE-15-01*

---

## N

### Nacionalización
Proceso de pasar la mercancía importada por la aduana colombiana (DIAN), presentando la declaración de importación y pagando aranceles e impuestos. Después de la nacionalización, la mercancía puede circular libremente en Colombia.  
📌 *Aplica a: HU-IE-15-01, HU-IE-19, HU-IE-20*

---

## O

### OC (Orden de Compra)
Documento que genera la empresa compradora para solicitar los equipos CAT al proveedor. Tiene un número único que identifica la compra. **Importante:** el número de OC puede contener caracteres especiales, mayúsculas, minúsculas y longitudes variables. El sistema NO debe limitarlos ni truncarlos.  
📌 *Aplica a: HU-IE-15-01*

---

### Open Comex
Sistema externo (de la agencia de aduanas) al que el SII transmite las declaraciones de importación para solicitar selectividad a la DIAN. Es la interfaz entre el proceso interno de importación y el trámite oficial ante la aduana colombiana.  
📌 *Aplica a: HU-IE-20*

---

## P

### Proveedor / Exportador
Empresa que vende y exporta los equipos CAT. En este proceso, el proveedor principal es Caterpillar Inc. y sus subsidiarias. Se identifica por su código D365 (6 dígitos). El término "exportador" también se usa para referirse al proveedor en el contexto del embarque.  
📌 *Aplica a: HU-IE-15-01, HU-IE-15-03*

---

## S

### SII / SII 2.0
Sistema de Información de Importaciones. Sistema propio que gestiona los procesos de comercio exterior: embarques, declaraciones de importación, registro de licencias, consulta de facturas, etc. Recibe la información de D365 y la usa para gestionar los trámites de importación de equipos CAT.  
**Versión anterior:** S400 / SII v1 (sistema legado en reemplazo).  
📌 *Aplica a: todas las HUs*

---

### Sincronización (automática de facturas)
Proceso automático mediante el cual el SII trae las facturas registradas en D365 sin intervención manual. Ocurre periódicamente (job programado). Es el punto de partida del proceso de importación de equipos CAT en el nuevo SII 2.0.  
📌 *Aplica a: HU-IE-15-01*

---

### Sistema Legado / S400 / SII v1
Sistema anterior que el SII 2.0 viene a reemplazar. Usaba el código de proveedor de 3 dígitos y la tabla de mapeo SII-D365. Sus procesos y restricciones deben tenerse en cuenta durante la migración de datos históricos.  
📌 *Aplica a: HU-IE-15-01, HU-IE-15-03*

---

## T

### Tabla de Mapeo SII-D365
Tabla intermedia que relacionaba el código SII antiguo (3 dígitos) con el código D365 (6 dígitos). Ejemplo: SII `021` ↔ D365 `221372` = Caterpillar. **Se elimina en SII 2.0**; ya no es necesaria porque el nuevo sistema usa directamente el código D365.  
📌 *Aplica a: HU-IE-15-01, HU-IE-15-03*

---

### Truncamiento
Quando un sistema corta un texto por tener límite de caracteres. Ejemplo: OC "ABC-2025/ESPECIAL-001" guardada como "ABC-2025/ESPECI". El SII 2.0 **no debe truncar** ningún campo de referencia: debe almacenar el dato completo tal como viene de D365.  
📌 *Aplica a: HU-IE-15-01*

---

## V

### Vendor Account
Ver: **Código Proveedor D365 / Vendor Account (6 dígitos)**.  
📌 *Aplica a: HU-IE-15-01, HU-IE-15-03*

---

## Diagrama General del Proceso

```
[D365 – Dynamics 365]
    │
    │  API (sincronización automática periódica)
    ▼
[SII 2.0]
    │
    ├── REQ-15: Valida y almacena Facturas → HU-IE-15-01, 15-02, 15-03
    ├── REQ-16: Integración con Logística → BL → HU-IE-16
    ├── REQ-17: Asigna Licencia/Registro de Importación → HU-IE-17
    ├── REQ-18: Genera Documento de Transporte (Embarque) → HU-IE-18
    ├── REQ-19: Agrega Costos de Nacionalización → HU-IE-19
    ├── REQ-20: Genera Declaración de Importación (DI) → HU-IE-20
    └── REQ-22: Consolida y envía costos a D365 → HU-IE-22
                                │
                                ▼
                    [DIAN / Open Comex]
                    (Selectividad y aprobación)
                                │
                                ▼
                    [Mercancía Nacionalizada]
```

---

*Última actualización: 2026-03-05 | HU procesadas: HU-IE-15-01, HU-IE-15-02, HU-IE-15-03, HU-IE-16 | Total términos: 46*
