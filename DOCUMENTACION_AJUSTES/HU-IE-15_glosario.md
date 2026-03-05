# HU-IE-15-01 — Glosario de Términos de Negocio (Estilo Dummies)

**Aplica a:** HU-IE-15-01 – Sincronización Automática de Facturas desde D365  
**Fecha:** 2026-03-05

> Este glosario explica cada término de negocio en lenguaje sencillo para que cualquier persona (sin importar su área) pueda entender de qué se habla en la historia de usuario.

---

## A

**API (Application Programming Interface)**  
Es el "canal oficial" por el que dos sistemas se comunican entre sí. En este proceso, D365 y el SII se hablan a través de una API: D365 expone sus datos y el SII los consulta de forma controlada. No es una conexión directa a la base de datos (eso está prohibido), sino como una ventanilla donde uno pide la información y el otro la entrega con reglas.

---

## B

**BL (Bill of Lading)**  
En español: **conocimiento de embarque**. Es el documento que emite la naviera y certifica que la mercancía fue embarcada en el barco. Es como la "partida de nacimiento" del embarque marítimo. El BL identifica qué viene, cuánto pesa, quién lo envía y quién lo recibe.

---

## C

**Cargos (en D365)**  
Son los costos adicionales que se asignan a la factura en D365 al momento de registrarla: fletes, seguros, transporte terrestre (INLAND), entre otros. Dependen del INCOTERM pactado con el proveedor. Se sincronizan junto con la factura al SII para calcular el costo total de importación del equipo.

---

**Código Proveedor D365 / Vendor Account (6 dígitos)**  
El código que usa D365 para identificar al proveedor. Ejemplo: Caterpillar Inc. = `221372`. En el nuevo SII 2.0, este será el **identificador oficial**. Es de 6 dígitos porque D365 usa un sistema de numeración más amplio que el SII antiguo. Este código también se usa en la declaración de importación que se presenta ante la DIAN.

---

**Código Proveedor SII Legado (3 dígitos)**  
El código interno que el SII antiguo usaba para identificar al proveedor. Ejemplo: Caterpillar = `021`. Este código **queda obsoleto** en el nuevo SII 2.0. Ya no se usará para registros nuevos.

---

**Compañía (en D365)**  
Cada empresa del grupo tiene un código en D365 que la identifica. Ejemplo: GColza = `001`, otra compañía = `021`. El proceso de sincronización debe funcionar para **todas las compañías**, no solo para la 001.

---

## D

**D365 / Dynamics 365**  
El sistema ERP (sistema de gestión empresarial) de Microsoft que usa la empresa para registrar facturas, proveedores, órdenes de compra y toda la información financiera y de compras. Es el sistema "mayor" del que el SII recibe información. Cuando se dice "viene de D365", el dato fue creado o procesado allí.

---

**Declaración de Importación (DI)**  
El documento oficial que se presenta ante la aduana colombiana (DIAN) para legalizar la entrada de la mercancía al país. Sin una DI aprobada y con selectividad, la mercancía no puede salir de la zona aduanera. El código de proveedor D365 (6 dígitos) aparece en este documento.

---

**Duplicado (de factura)**  
Cuando una factura llega dos veces con el mismo número **y** la misma fecha. El sistema la debe rechazar silenciosamente (no cargarla) y registrar el evento en el log. No es un error del usuario: puede ocurrir por reprocesos automáticos en D365.

---

## G

**GColza / Gecolsa**  
Una de las compañías del grupo que distribuye los equipos CAT en Colombia. Opera con el código de compañía 001 en D365. Es uno de los actores cuyos proveedores y facturas se sincronizan al SII.

---

## I

**ID Equipo**  
El código único que identifica a cada equipo CAT específico (máquina, vehículo, etc.) dentro del pedido. Permite saber exactamente a qué máquina corresponde cada factura y cada costo de importación.

---

**INLAND**  
El costo del transporte terrestre desde el puerto de llegada (Buenaventura, Cartagena, etc.) hasta el almacén del cliente en Colombia. Si importas desde EE.UU. y el barco llega a Buenaventura, el INLAND es lo que cuesta llevarlo en camión hasta Bogotá o la ciudad de destino. Es uno de los "Cargos" que se registra en D365.

---

**INCOTERM**  
Regla internacional que define **quién paga qué** en el transporte de la mercancía y hasta dónde llega la responsabilidad del vendedor. Ejemplos:
- **DPU** (Delivered at Place Unloaded): el vendedor entrega ya descargado en el destino.
- **CFR** (Cost and Freight): el vendedor paga el flete hasta el puerto de destino.
- **CIF** (Cost, Insurance and Freight): como CFR pero el vendedor también paga el seguro.
- **FOB** (Free on Board): el vendedor entrega en el puerto de origen; el comprador paga el flete.

El INCOTERM determina qué "Cargos" se deben agregar al costo del equipo.

---

## J

**Job / Scheduler (sincronización)**  
Es una tarea automática programada que el sistema ejecuta periódicamente (cada cierto tiempo) sin que nadie lo active manualmente. En este proceso, el job de sincronización "va a D365", trae las facturas nuevas y las registra en el SII. Es como un mensajero que sale a buscar la información a horarios definidos.

---

## L

**Log de Sincronización**  
Un registro automático que guarda todo lo que pasó durante cada ejecución del proceso de sincronización: cuántas facturas llegaron, cuántas se insertaron, cuántas se rechazaron y por qué. Sirve para auditoría, detección de problemas y trazabilidad operativa.

---

## M

**Monitoreo de Sincronización**  
Una pantalla o reporte dentro del SII que muestra el estado de la última (o anteriores) sincronización: si fue exitosa, parcial o falló. Permite al equipo detectar problemas sin tener que revisar los logs técnicos.

---

## N

**Nacionalización**  
El proceso de pasar la mercancía importada por la aduana colombiana (DIAN), presentando la declaración de importación, pagando aranceles e impuestos. Después de la nacionalización, la mercancía puede circular libremente en Colombia y ser entregada al cliente.

---

## O

**OC (Orden de Compra)**  
El documento que genera la empresa compradora para solicitar los equipos CAT al proveedor. Tiene un número único que identifica la compra. **Importante para esta HU:** el número de OC puede contener caracteres especiales, mayúsculas, minúsculas y longitudes variables. El sistema NO debe limitarlos ni truncarlos.

---

## P

**Proveedor / Exportador**  
La empresa que vende y exporta los equipos CAT. En este proceso, el proveedor principal es Caterpillar Inc. y sus subsidiarias. En el sistema, el proveedor se identifica por su código D365 (6 dígitos). El término "exportador" también se usa para referirse al proveedor en el contexto del embarque.

---

## S

**SII / SII 2.0**  
El Sistema de Información de Importaciones. Es el sistema propio que gestiona los procesos de comercio exterior: embarques, declaraciones de importación, registro de licencias, consulta de facturas, etc. Recibe la información de D365 y la usa para gestionar los trámites de importación de equipos CAT.

**Versión anterior:** S400 / SII v1 (sistema legado que se está reemplazando).

---

**Sincronización**  
El proceso automático mediante el cual el SII "va a buscar" las facturas registradas en D365 y las trae al SII sin intervención manual. Ocurre periódicamente (job programado). Es el punto de partida del proceso de importación de equipos CAT en el nuevo SII 2.0.

---

**Sistema Legado / S400**  
El sistema anterior que el SII 2.0 viene a reemplazar. Usaba el código de proveedor de 3 dígitos y la tabla de mapeo SII-D365. Sus procesos y restricciones deben tenerse en cuenta durante la migración de datos históricos.

---

## T

**Tabla de Mapeo SII-D365**  
Una tabla intermedia que relacionaba el código SII antiguo (3 dígitos) con el código D365 (6 dígitos) para que los dos sistemas se entendieran. Ejemplo: SII `021` ↔ D365 `221372` = Caterpillar. **Se elimina en SII 2.0;** ya no será necesaria porque el nuevo sistema usa directamente el código D365.

---

**Truncamiento**  
Cuando un sistema corta (trunca) un texto porque tiene un límite de caracteres. Ejemplo: si la OC es "ABC-2025/ESPECIAL-EQUIPOS-001" pero el campo solo admite 15 caracteres, el sistema la guardaría como "ABC-2025/ESPECI" (cortada). El SII 2.0 **no debe truncar** ningún campo de referencia.

---

## V

**Vendor Account**  
Ver: **Código Proveedor D365 / Vendor Account (6 dígitos)**.

---

## Relación entre los Términos Principales

```
[D365 (Dynamics 365)]
    │
    │  (API – job periódico)
    ▼
[SII 2.0 – Sincronización]
    │
    ├──> Valida clave de unicidad (Factura + Fecha)
    ├──> Si proveedor no existe → crea automáticamente
    ├──> Almacena código proveedor D365 (6 dígitos)
    ├──> Registra en log (insertados / rechazados / duplicados)
    │
    ▼
[Facturas disponibles en SII]
    │
    ▼
[Proceso de Embarque y Nacionalización → DI → DIAN]
```

El SII 2.0 recibe las facturas de D365 y las pone a disposición del proceso de importación. El **código D365 del proveedor** circula desde D365 → SII → Declaración de Importación → DIAN, sin necesidad de traducción ni tabla intermedia.
