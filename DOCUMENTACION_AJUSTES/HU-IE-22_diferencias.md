# HU-IE-22 — Documento de Diferencias y Justificaciones de Ajuste

**HU:** HU-IE-22 – Consolidación Final de Costos y Envío a D365  
**HU Inicial:** `HU_Inicial/HU-IE-22 Consolidación Final de Costos y Envío.md`  
**HU Final:** `HU_final/HU-IE-22.md`  
**Fecha de revisión:** 2026-03-05  

---

## Resumen de Ajustes

La HU final de consolidación se optimizó para garantizar que el cierre administrativo sea coherente con la realidad técnica del ERP Dynamics 365.

### 1. Enfoque en Landed Cost
- **Cambio:** Se especificó que la salida hacia D365 alimenta el concepto de "Landed Cost".
- **Justificación:** Se identificó en las sesiones que Dynamics maneja una estructura específica de costos logísticos para equipos pesados, por lo que el SII debe "hablar" el mismo lenguaje técnico.

### 2. Robustez de la Interfaz
- **Cambio:** Se agregaron reglas de Idempotencia y Reintento Controlado.
- **Justificación:** Dado que es un envío a través de servicios web, es común que existan micro-cortes. El sistema debe ser capaz de reintentar sin duplicar la información contable.

### 3. Fortalecimiento de Prerrequisitos
- **Cambio:** Se hizo explícita la dependencia de todos los pasos anteriores (Guía, Licencia, Tipificación).
- **Justificación:** Para evitar "consolidaciones parciales" que dejarían el inventario en D365 con costos incompletos u orquestados erróneamente.

### 4. Bloqueo de Negocio
- **Cambio:** Se ratificó que la consolidación es el hito final e irreversible para el analista.
- **Justificación:** Evitar manipulaciones de datos una vez la contabilidad ha recibido la información oficial (Integridad Contable).
