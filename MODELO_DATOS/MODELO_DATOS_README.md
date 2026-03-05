# Modelo de Datos PostgreSQL — CrossDocking SII 2.0

**Versión:** 1.0 | **Fecha:** 2026-03-04 | **Basado en:** HU-CD-26 a HU-CD-41

---

## MER — Diagrama Entidad-Relación

![MER CrossDocking — 22 tablas, 12 módulos](./MER_crossdocking.png)

> Imagen generada desde el modelo de datos. Para versión interactiva: importar `modelo_crossdocking.sql` en [dbdiagram.io](https://dbdiagram.io) → `Import → PostgreSQL`.

---

### Versión código (Mermaid — para GitHub/mermaid.live)

```mermaid
erDiagram

    cat_compania {
        int id PK
        varchar codigo
        varchar nombre
    }
    cat_dealer {
        int id PK
        varchar codigo
        int compania_id FK
    }
    cat_referencia {
        int id PK
        varchar codigo_referencia
        smallint reman_indicator
        boolean requiere_licencia
    }
    cat_trm {
        int id PK
        date fecha_vigencia
        numeric valor_cop
    }

    fac_z95 {
        int id PK
        varchar numero
        smallint anio_factura
        int compania_id FK
        int dealer_id FK
        varchar estado
    }
    fac_z95_linea {
        int id PK
        int z95_id FK
        int referencia_id FK
        numeric cantidad
        numeric valor_fob_usd
        smallint reman_indicator
    }

    fac_inv {
        int id PK
        varchar numero
        int compania_id FK
        int dealer_id FK
        varchar estado
    }
    fac_inv_linea {
        int id PK
        int inv_id FK
        int referencia_id FK
        int z95_linea_id FK
        numeric cantidad
        numeric valor_fob_usd
    }

    oc_orden_compra {
        int id PK
        varchar numero_oc
        int compania_id FK
    }

    discrepancia {
        int id PK
        int z95_id FK
        int inv_id FK
        varchar tipo_discrepancia
        varchar estado
    }

    licencia_importacion {
        int id PK
        varchar numero
        varchar tipo
        int compania_id FK
        date fecha_vencimiento
        numeric saldo_disponible
        varchar estado
    }
    licencia_asignacion {
        int id PK
        int licencia_id FK
        int referencia_id FK
        numeric cantidad_asignada
        int dim_id FK
    }

    guia {
        int id PK
        varchar numero_guia
        int compania_id FK
        int dealer_id FK
        varchar tipo_mercancia
        varchar estado
        boolean es_parcial
    }
    guia_z95 {
        int id PK
        int guia_id FK
        int z95_id FK
    }
    guia_linea {
        int id PK
        int guia_id FK
        int referencia_id FK
        numeric cantidad_guia
        numeric valor_fob_usd
        smallint reman_indicator
    }

    do_documento {
        int id PK
        varchar numero_do
        int guia_id FK
        varchar estado
        boolean btn_clasificado
        boolean vobo_recibido
    }

    dim_declaracion {
        int id PK
        varchar numero_dim
        int version
        int do_id FK
        int guia_id FK
        int compania_id FK
        int trm_id FK
        varchar estado
        varchar nro_aceptacion
        varchar nro_autoadhesivo
        timestamptz fecha_levante
        int reemplazada_por FK
    }
    dim_linea {
        int id PK
        int dim_id FK
        int referencia_id FK
        int licencia_id FK
        varchar btn
        numeric valor_fob_usd
    }

    costeo_embarque {
        int id PK
        int dim_id FK
        int guia_id FK
        varchar estado
        numeric costo_estimado_pct
        varchar nro_drs
    }
    costeo_linea {
        int id PK
        int costeo_id FK
        int referencia_id FK
        numeric costo_total_usd
    }

    alerta_reman {
        int id PK
        int guia_id FK
        int referencia_id FK
        varchar tipo_error
        varchar estado
    }

    audit_dim_estado {
        int id PK
        int dim_id FK
        varchar estado_nuevo
        timestamptz fecha
    }

    log_sincronizacion {
        int id PK
        varchar tipo_interfaz
        varchar estado
        int registros_rechazados
    }

    %% Relaciones
    cat_compania ||--o{ cat_dealer : "tiene"
    cat_compania ||--o{ fac_z95 : "emite"
    cat_compania ||--o{ fac_inv : "recibe"
    cat_compania ||--o{ guia : "opera"
    cat_compania ||--o{ dim_declaracion : "declara"
    cat_compania ||--o{ licencia_importacion : "posee"

    cat_dealer ||--o{ fac_z95 : "destino"
    cat_dealer ||--o{ fac_inv : "destino"
    cat_dealer ||--o{ guia : "destino"

    cat_referencia ||--o{ fac_z95_linea : "en"
    cat_referencia ||--o{ fac_inv_linea : "en"
    cat_referencia ||--o{ guia_linea : "en"
    cat_referencia ||--o{ dim_linea : "en"
    cat_referencia ||--o{ costeo_linea : "en"
    cat_referencia ||--o{ licencia_asignacion : "cubre"
    cat_referencia ||--o{ alerta_reman : "genera"

    cat_trm ||--o{ dim_declaracion : "aplica a"

    fac_z95 ||--o{ fac_z95_linea : "tiene"
    fac_z95 ||--o{ guia_z95 : "incluida en"
    fac_z95 ||--o{ discrepancia : "origen"

    fac_inv ||--o{ fac_inv_linea : "tiene"
    fac_inv ||--o{ discrepancia : "comparada"

    fac_z95_linea ||--o{ fac_inv_linea : "relaciona"
    fac_z95_linea ||--o{ guia_linea : "parcializa"

    licencia_importacion ||--o{ licencia_asignacion : "asignada a"
    licencia_asignacion }o--|| dim_declaracion : "consume en"

    guia ||--o{ guia_z95 : "agrupa"
    guia ||--o{ guia_linea : "detalle"
    guia ||--|| do_documento : "genera"
    guia ||--o{ dim_declaracion : "base de"
    guia ||--o{ alerta_reman : "registra"

    do_documento ||--o{ dim_declaracion : "sustenta"

    dim_declaracion ||--o{ dim_linea : "detalle"
    dim_declaracion ||--o{ audit_dim_estado : "historial"
    dim_declaracion ||--o| costeo_embarque : "cierra en"
    dim_declaracion |o--o| dim_declaracion : "reemplaza"

    costeo_embarque ||--o{ costeo_linea : "distribuye"
```

---

## Cómo visualizar este MER

| Opción | Herramienta | Cómo |
|--------|------------|------|
| **Gratis online** | [dbdiagram.io](https://dbdiagram.io) | Pegar el SQL con `Import → PostgreSQL` |
| **Gratis online** | [drawdb.vercel.app](https://drawdb.vercel.app) | Importar el `.sql` directamente |
| **Desktop local** | [DBeaver](https://dbeaver.io) | Conectar a PostgreSQL → clic derecho en esquema → *ER Diagram* |
| **Desktop local** | pgAdmin 4 | Menú *Tools → ERD Tool* |
| **VS Code** | Extension *ERD Editor* | Abrir el `.sql` y generar diagrama |
| **Mermaid online** | [mermaid.live](https://mermaid.live) | Pegar el bloque `erDiagram` de arriba |

---

## Archivo principal

[`modelo_crossdocking.sql`](./modelo_crossdocking.sql) — Script DDL completo para PostgreSQL.

---

## Módulos y Tablas

| Módulo | Tablas | HU de referencia |
|--------|--------|-----------------|
| **0 – Catálogos** | `cat_compania`, `cat_dealer`, `cat_transportadora`, `cat_via_transporte`, `cat_modalidad_dim`, `cat_tipo_dim`, `cat_aduana`, `cat_tipo_embalaje`, `cat_referencia`, `cat_trm` | HU-CD-26, 33, 35, 39 |
| **1 – Facturas Z95** | `fac_z95`, `fac_z95_linea` | HU-CD-26, 27, 29, 30 |
| **2 – Facturas INV** | `fac_inv`, `fac_inv_linea` | HU-CD-26, 27, 29 |
| **3 – OC** | `oc_orden_compra` | HU-CD-26, 29 |
| **4 – Consolidado DHL** | `consolidado_dhl`, `consolidado_dhl_linea` | HU-CD-26 |
| **5 – Discrepancias** | `discrepancia` | HU-CD-28 |
| **6 – Licencias** | `licencia_importacion`, `licencia_asignacion` | HU-CD-32, 34 |
| **7 – Guías** | `guia`, `guia_z95`, `guia_linea` | HU-CD-31, 33, 35, 36 |
| **8 – DO** | `do_documento` | HU-CD-37 |
| **9 – DIM** | `dim_declaracion`, `dim_linea` | HU-CD-39, 40 |
| **10 – Costeo** | `costeo_embarque`, `costeo_linea` | HU-CD-41 |
| **11 – Alertas Reman** | `alerta_reman` | HU-CD-34 |
| **12 – Auditoría** | `log_sincronizacion`, `audit_dim_estado` | HU-CD-29, 40 |

---

## Decisiones de Diseño Clave

| # | Decisión | Justificación |
|---|----------|---------------|
| 1 | **Clave compuesta Z95** (numero + anio + compania) | CAT reutiliza consecutivos cada ~2 años (HU-CD-30) |
| 2 | **Reman Indicator** en z95_linea, inv_linea y guia_linea | El tipo de mercancía es por línea, no por factura |
| 3 | **Control de versiones** en DIM (`version` + `reemplazada_por`) | Una DIM nunca se modifica — se crea nueva versión (HU-CD-39) |
| 4 | **Estados secuenciales** con CHECK | Impide saltos de estado (HU-CD-40) |
| 5 | **`costo_estimado_pct` parametrizable** | El 2% puede cambiar — no hardcodeado (HU-CD-41) |
| 6 | **`saldo_disponible`** en licencia | Se descuenta al transmitir DIM, no al crear borrador (HU-CD-32) |
| 7 | **`es_parcial`** en guía | Permite parcialización de embarques (HU-CD-31) |
| 8 | **`audit_dim_estado`** inmutable | Historial de cambios de estado (HU-CD-40 RN-04) |

---

## Pendientes Pre-Desarrollo

> [!IMPORTANT]
> Resolver antes de finalizar el modelo:
> 1. **Tabla 1 de Dealers** — Commex debe entregar el catálogo oficial.
> 2. **Costo estimado** — Costos debe confirmar % y base de cálculo.
> 3. **BTN en REQ-34** — ¿Viene de Dynamics o se parametriza en SII?
> 4. **Fuente de TRM** — ¿API Banco de la República o carga manual?
> 5. **Interfaz FileZilla** — Formato exacto del archivo enviado a SIACO.
