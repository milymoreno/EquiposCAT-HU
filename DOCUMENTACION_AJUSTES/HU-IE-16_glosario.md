# HU-IE-16 — Glosario de Términos de Negocio (Estilo Dummies)

**Aplica a:** HU-IE-16 – Integración con Logística Internacional para Recepción de BL  
**Fecha:** 2026-03-05

---

## A

### API REST
Imagínalo como un "mesero" que lleva pedidos de un restaurante (sistema de Logística) a la cocina (nuestro sistema SII 2.0). Es la forma moderna y segura de pasar información de un sistema a otro sin que se mezclen sus ingredientes (bases de datos).  
📌 *Contexto:* Usado para recibir la información del BL.

### Asociación de Facturas
Es el proceso de "vincular" o "pegar" las facturas que llegaron de D365 (HU-IE-15-01) al documento de transporte (BL). Si el BL dice que trae 10 cajas, la asociación garantiza que dentro del sistema esas 10 cajas correspondan a las facturas correctas.

### Auditoría (de Payload)
Es guardar una "foto" exacta de cómo llegó la información desde el sistema de Logística. Si mañana alguien dice "yo no envié ese peso", podemos revisar la foto original (el payload) y confirmar qué fue lo que realmente recibimos.

---

## B

### BL (Bill of Lading / Conocimiento de Embarque)
Es el "tiquete de equipaje" de un barco o avión, pero para mercancía gigante. Contiene quién manda, quién recibe, qué puerto toca y cuántas bultos/peso trae. Es el documento más importante de la logística internacional.

### Bultos
Es la cantidad de paquetes, cajas o unidades físicas que trae el embarque. No importa si es gigante o pequeño, cada unidad se cuenta como un bulto.

---

## E

### Estado Logístico (del BL)
Es el "semáforo" que nos dice en qué parte del proceso va el documento:
- **Recibido:** Acaba de llegar de la transportadora.
- **Validado:** Ya confirmamos que los datos están bien y las facturas existen.
- **Disponible para Guía:** Listo para que el analista cree el documento de nacionalización.
- **Cerrado:** El proceso terminó con éxito.

---

## I

### Idempotencia (Control de Duplicados)
Es el nombre elegante para decir "no hagas dos veces lo mismo". Si el sistema de Logística nos manda el mismo BL cinco veces por error, el SII 2.0 solo lo registra una vez e ignora las otras cuatro.

### Integración Logística Internacional
Es la conexión automática entre nuestra empresa y las agencias de transporte o navieras que mueven los equipos CAT por el mundo. Sirve para que no tengamos que estar digitando a mano los datos del BL.

---

## P

### Payload
Es el "paquete" de datos que viaja por el API. Contiene toda la información del BL organizada de una forma que las computadoras entienden (usualmente en formato JSON).

### Peso Bruto
Es el peso total de la mercancía incluyendo sus cajas, estibas y embalajes. Es un dato crítico porque sobre este peso se calculan muchos impuestos y costos de transporte.

### Puerto de Destino
Lugar donde el barco o avión termina su viaje y descarga la mercancía para iniciar la nacionalización en Colombia. Ejemplos: Puerto de Buenaventura, Puerto de Cartagena.

---

## V

### Validación Cruzada
Es cuando el sistema hace de "detective": toma el BL que llegó de Logística y revisa si las facturas que menciona ya existen en el sistema (las que llegaron de D365). Si el BL menciona una factura que no conocemos, se levanta una alerta.
