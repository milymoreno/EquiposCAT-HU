# HU-IE-17 — Documento de Diferencias y Justificaciones de Ajuste

**HU:** HU-IE-17 – Asignación y Control de Registro y/o Licencia de Importación  
**HU Inicial:** `HU_Inicial/HU-IE-17 Asignación de Registro.md`  
**HU Final:** `HU_final/HU-IE-17.md`  
**Fecha de revisión:** 2026-03-05  

---

## Resumen de Ajustes

La HU inicial contenía una base sólida de reglas de negocio. En la versión final se aterrizaron las necesidades específicas del proceso de Equipos CAT según la sesión de levantamiento.

### 1. Definición de la Llave de Acceso
- **Cambio:** Se especificó que el ingreso al módulo se realiza mediante **Guía + Dealer**.
- **Justificación:** Es la forma en que el sistema identifica la carga específica de equipos (Angie, línea 765).

### 2. Enfoque en Remanufacturados
- **Cambio:** Se elevó la importancia del control para equipos marcados como remanufacturados.
- **Justificación:** En la sesión se aclaró que estos equipos son los que disparan la obligatoriedad crítica de la licencia (Fabiani/Óscar, línea 703).

### 3. Ruta de Navegación
- **Cambio:** Se incluyó el menú exacto del sistema actual a replicar/mejorar.
- **Justificación:** Facilita la transición de los usuarios al nuevo sistema manteniendo la lógica de "Módulo Declaraciones".

### 4. Automatización de Alertas
- **Cambio:** Se formalizaron las alertas de saldo (10%) y vencimiento (30 días) como requisitos funcionales.
- **Justificación:** Para eliminar el control manual externo (Excel) que se realiza actualmente.
