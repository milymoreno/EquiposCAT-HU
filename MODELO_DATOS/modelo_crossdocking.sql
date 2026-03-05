-- =============================================================
-- MODELO DE DATOS POSTGRESQL — PROCESO CROSSDOCKING SII 2.0
-- Basado en HU-CD-26 a HU-CD-41
-- Versión: 1.0 | Fecha: 2026-03-04
-- =============================================================
-- CONVENCIONES:
--   - snake_case para tablas y columnas
--   - Prefijos por módulo: cat_, inv_, guia_, do_, dim_, costeo_
--   - Todas las tablas tienen: id SERIAL PK, created_at, updated_at
--   - audit_user_id para quién realizó la acción
--   - Estados controlados por ENUM o tabla de referencia
-- =============================================================

-- =====================
-- EXTENSIONES
-- =====================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================
-- MÓDULO 0: CATÁLOGOS / PARÁMETROS
-- =====================

-- Compañías (Gecolsa, Relianz, Panamerican, etc.)
CREATE TABLE cat_compania (
    id            SERIAL PRIMARY KEY,
    codigo        VARCHAR(10) NOT NULL UNIQUE,    -- Ej: 'GCL', 'RLZ', 'PSC'
    nombre        VARCHAR(100) NOT NULL,
    es_activa     BOOLEAN DEFAULT TRUE,
    created_at    TIMESTAMPTZ DEFAULT NOW(),
    updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla 1 de Dealers (HU-CD-35, ⚠️ pendiente entrega por Commex)
CREATE TABLE cat_dealer (
    id             SERIAL PRIMARY KEY,
    codigo         VARCHAR(20) NOT NULL UNIQUE,
    nombre         VARCHAR(150) NOT NULL,
    compania_id    INT NOT NULL REFERENCES cat_compania(id),  -- Exclusivo de una compañía
    ciudad         VARCHAR(100),
    es_activo      BOOLEAN DEFAULT TRUE,
    created_at     TIMESTAMPTZ DEFAULT NOW(),
    updated_at     TIMESTAMPTZ DEFAULT NOW()
);

-- Transportadoras (HU-CD-33)
CREATE TABLE cat_transportadora (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    es_activa   BOOLEAN DEFAULT TRUE,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Vías de transporte (Aérea, Marítima, Terrestre)
CREATE TABLE cat_via_transporte (
    id          SERIAL PRIMARY KEY,
    codigo      VARCHAR(10) NOT NULL UNIQUE,   -- 'A', 'M', 'T'
    descripcion VARCHAR(50) NOT NULL
);

-- Modalidades de importación DIM (HU-CD-39)
CREATE TABLE cat_modalidad_dim (
    id          SERIAL PRIMARY KEY,
    codigo      VARCHAR(20) NOT NULL UNIQUE,
    descripcion VARCHAR(100) NOT NULL,
    es_activa   BOOLEAN DEFAULT TRUE
);

-- Tipos de DIM
CREATE TABLE cat_tipo_dim (
    id          SERIAL PRIMARY KEY,
    codigo      VARCHAR(20) NOT NULL UNIQUE,
    descripcion VARCHAR(100) NOT NULL
);

-- Aduanas de ingreso (HU-CD-33)
CREATE TABLE cat_aduana (
    id          SERIAL PRIMARY KEY,
    codigo      VARCHAR(20) NOT NULL UNIQUE,
    nombre      VARCHAR(150) NOT NULL,
    ciudad      VARCHAR(100)
);

-- Tipos de embalaje (HU-CD-39)
CREATE TABLE cat_tipo_embalaje (
    id          SERIAL PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL UNIQUE
);

-- Referencias/Productos (catálogo de partes CAT)
CREATE TABLE cat_referencia (
    id                SERIAL PRIMARY KEY,
    codigo_referencia VARCHAR(50) NOT NULL UNIQUE,
    descripcion       VARCHAR(300),
    reman_indicator   SMALLINT NOT NULL DEFAULT 0  -- 0=Nueva, 1=Remanufacturada (HU-CD-34, HU-CD-35)
                      CHECK (reman_indicator IN (0,1)),
    btn               VARCHAR(20),                 -- Subpartida arancelaria (HU-CD-34, HU-CD-37)
    requiere_licencia BOOLEAN DEFAULT FALSE,        -- Parametrización normativa reman (HU-CD-34)
    created_at        TIMESTAMPTZ DEFAULT NOW(),
    updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- TRM por fecha (Tasa Representativa del Mercado) (HU-CD-39)
CREATE TABLE cat_trm (
    id              SERIAL PRIMARY KEY,
    fecha_vigencia  DATE NOT NULL UNIQUE,
    valor_cop       NUMERIC(15,4) NOT NULL,  -- COP por 1 USD
    fuente          VARCHAR(50) DEFAULT 'Banco de la República',
    created_at      TIMESTAMPTZ DEFAULT NOW()
);


-- =====================
-- MÓDULO 1: FACTURAS Z95 (CAT → Panamerican)
-- HU-CD-26, HU-CD-27, HU-CD-29, HU-CD-30
-- =====================

CREATE TABLE fac_z95 (
    id              SERIAL PRIMARY KEY,
    -- Clave compuesta: Número + Año + Compañía (HU-CD-30)
    numero          VARCHAR(30) NOT NULL,
    anio_factura    SMALLINT NOT NULL,
    compania_id     INT NOT NULL REFERENCES cat_compania(id),
    UNIQUE (numero, anio_factura, compania_id),         -- Clave única compuesta (HU-CD-30)

    fecha_factura   DATE NOT NULL,
    dealer_id       INT REFERENCES cat_dealer(id),
    valor_fob_usd   NUMERIC(18,2) NOT NULL,
    moneda          VARCHAR(5) DEFAULT 'USD',
    incoterm        VARCHAR(10),                        -- FOB, CIF, etc. (HU-CD-33)
    -- Estado de ciclo de vida (HU-CD-28)
    estado          VARCHAR(30) NOT NULL DEFAULT 'Sin guia'
                    CHECK (estado IN ('Sin guia','Con guia','Con declaracion','Con levante')),
    anio_proceso    SMALLINT,                            -- Año de proceso activo (HU-CD-30)
    creado_desde    VARCHAR(20) DEFAULT 'Interfaz',      -- 'Interfaz' | 'Manual'
    fuente_sistema  VARCHAR(20) DEFAULT 'D365',
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Líneas de detalle de la Z95
CREATE TABLE fac_z95_linea (
    id               SERIAL PRIMARY KEY,
    z95_id           INT NOT NULL REFERENCES fac_z95(id) ON DELETE CASCADE,
    referencia_id    INT NOT NULL REFERENCES cat_referencia(id),
    cantidad         NUMERIC(12,3) NOT NULL,
    valor_unitario   NUMERIC(14,4) NOT NULL,
    valor_fob_usd    NUMERIC(18,2) NOT NULL,
    reman_indicator  SMALLINT NOT NULL DEFAULT 0 CHECK (reman_indicator IN (0,1)),
    created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- MÓDULO 2: FACTURAS INV PSC (Panamerican → Gecolsa/Relianz)
-- HU-CD-26, HU-CD-27, HU-CD-29
-- =====================

CREATE TABLE fac_inv (
    id              SERIAL PRIMARY KEY,
    numero          VARCHAR(30) NOT NULL UNIQUE,
    compania_id     INT NOT NULL REFERENCES cat_compania(id),  -- Gecolsa o Relianz
    fecha_factura   DATE NOT NULL,
    dealer_id       INT REFERENCES cat_dealer(id),
    valor_fob_usd   NUMERIC(18,2) NOT NULL,
    moneda          VARCHAR(5) DEFAULT 'USD',
    estado          VARCHAR(30) NOT NULL DEFAULT 'Sin guia'
                    CHECK (estado IN ('Sin guia','Con guia','Con declaracion','Con levante')),
    fuente_sistema  VARCHAR(20) DEFAULT 'D365',
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Líneas de detalle INV
CREATE TABLE fac_inv_linea (
    id               SERIAL PRIMARY KEY,
    inv_id           INT NOT NULL REFERENCES fac_inv(id) ON DELETE CASCADE,
    referencia_id    INT NOT NULL REFERENCES cat_referencia(id),
    z95_linea_id     INT REFERENCES fac_z95_linea(id),      -- Relación con Z95 origen
    cantidad         NUMERIC(12,3) NOT NULL,
    valor_unitario   NUMERIC(14,4) NOT NULL,
    valor_fob_usd    NUMERIC(18,2) NOT NULL,
    reman_indicator  SMALLINT NOT NULL DEFAULT 0 CHECK (reman_indicator IN (0,1)),
    created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- MÓDULO 3: ÓRDENES DE COMPRA (D365)
-- HU-CD-26, HU-CD-29
-- =====================

CREATE TABLE oc_orden_compra (
    id              SERIAL PRIMARY KEY,
    numero_oc       VARCHAR(30) NOT NULL UNIQUE,
    compania_id     INT NOT NULL REFERENCES cat_compania(id),
    fecha_oc        DATE NOT NULL,
    proveedor       VARCHAR(100),
    fuente_sistema  VARCHAR(20) DEFAULT 'D365',
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- MÓDULO 4: CONSOLIDADO AGENTE DE CARGA (DHL)
-- HU-CD-26
-- =====================

CREATE TABLE consolidado_dhl (
    id              SERIAL PRIMARY KEY,
    fecha_recepcion TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fuente          VARCHAR(20) NOT NULL DEFAULT 'Bot DHL',  -- 'Bot DHL' | 'Manual'
    archivo_nombre  VARCHAR(200),
    estado          VARCHAR(20) NOT NULL DEFAULT 'Recibido'
                    CHECK (estado IN ('Recibido','Procesado','Con errores')),
    observaciones   TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Líneas del consolidado DHL
CREATE TABLE consolidado_dhl_linea (
    id                   SERIAL PRIMARY KEY,
    consolidado_id       INT NOT NULL REFERENCES consolidado_dhl(id),
    numero_guia_dhl      VARCHAR(50),
    z95_id               INT REFERENCES fac_z95(id),
    inv_id               INT REFERENCES fac_inv(id),
    dealer_id            INT REFERENCES cat_dealer(id),
    peso_bruto_kg        NUMERIC(10,3),
    bultos               INT,
    created_at           TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- MÓDULO 5: DISCREPANCIAS (HU-CD-28)
-- =====================

CREATE TABLE discrepancia (
    id                  SERIAL PRIMARY KEY,
    z95_id              INT NOT NULL REFERENCES fac_z95(id),
    inv_id              INT NOT NULL REFERENCES fac_inv(id),
    tipo_discrepancia   VARCHAR(50) NOT NULL,    -- 'Cantidad', 'Valor FOB', 'Referencia', etc.
    descripcion         TEXT,
    valor_z95           NUMERIC(18,4),
    valor_inv           NUMERIC(18,4),
    diferencia          NUMERIC(18,4),
    estado              VARCHAR(20) NOT NULL DEFAULT 'Activa'
                        CHECK (estado IN ('Activa','Resuelta','Cerrada')),
    resuelta_en         TIMESTAMPTZ,
    resuelta_por        VARCHAR(100),
    origen_correccion   VARCHAR(30),              -- 'Dynamics' | 'SII'
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- MÓDULO 6: LICENCIAS Y REGISTROS DE IMPORTACIÓN
-- HU-CD-32, HU-CD-34
-- =====================

CREATE TABLE licencia_importacion (
    id                  SERIAL PRIMARY KEY,
    numero              VARCHAR(30) NOT NULL UNIQUE,
    tipo                VARCHAR(1) NOT NULL CHECK (tipo IN ('L','R')),  -- L=Licencia, R=Registro
    compania_id         INT NOT NULL REFERENCES cat_compania(id),
    fecha_inicio        DATE NOT NULL,
    fecha_vencimiento   DATE NOT NULL,
    saldo_inicial       NUMERIC(14,3) NOT NULL,
    saldo_disponible    NUMERIC(14,3) NOT NULL,
    unidad_medida       VARCHAR(20) DEFAULT 'unidades',
    estado              VARCHAR(20) NOT NULL DEFAULT 'Activa'
                        CHECK (estado IN ('Activa','Agotada','Vencida','Cancelada')),
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- Asignación de licencia a referencia/línea (HU-CD-32)
CREATE TABLE licencia_asignacion (
    id                  SERIAL PRIMARY KEY,
    licencia_id         INT NOT NULL REFERENCES licencia_importacion(id),
    referencia_id       INT NOT NULL REFERENCES cat_referencia(id),
    cantidad_asignada   NUMERIC(12,3) NOT NULL,
    consumido           BOOLEAN DEFAULT FALSE,   -- Se marca TRUE al transmitir la DIM
    consumido_en        TIMESTAMPTZ,
    dim_id              INT,                     -- FK a dim_declaracion (se agrega después)
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- MÓDULO 7: GUÍAS DE EMBARQUE
-- HU-CD-31, HU-CD-33, HU-CD-35, HU-CD-36
-- =====================

CREATE TABLE guia (
    id                  SERIAL PRIMARY KEY,
    numero_guia         VARCHAR(50) NOT NULL UNIQUE,
    compania_id         INT NOT NULL REFERENCES cat_compania(id),
    dealer_id           INT NOT NULL REFERENCES cat_dealer(id),
    fecha_guia          DATE NOT NULL,
    tipo_mercancia      VARCHAR(20) NOT NULL CHECK (tipo_mercancia IN ('Nueva','Remanufacturada')),
    incoterm            VARCHAR(10),
    aduana_id           INT REFERENCES cat_aduana(id),
    via_transporte_id   INT REFERENCES cat_via_transporte(id),
    transportadora_id   INT REFERENCES cat_transportadora(id),
    embarcadora         VARCHAR(150),
    exportador          VARCHAR(150),
    pais_compra         VARCHAR(5),    -- Código ISO país
    pais_origen         VARCHAR(5),
    pais_procedencia    VARCHAR(5),
    flete_usd           NUMERIC(14,2),
    valor_fob_total     NUMERIC(18,2) NOT NULL,
    total_referencias   INT,
    total_unidades      NUMERIC(14,3),
    estado              VARCHAR(30) NOT NULL DEFAULT 'Generada'
                        CHECK (estado IN (
                            'Generada','En proceso DIM','DIM generada','Cerrada','Anulada'
                        )),
    -- Validación visual (HU-CD-36)
    validacion_fob_ok   BOOLEAN,
    validacion_fecha    TIMESTAMPTZ,
    es_parcial          BOOLEAN DEFAULT FALSE,   -- HU-CD-31
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- Facturas asociadas a la guía (relación N:M Z95 × Guía)
CREATE TABLE guia_z95 (
    id              SERIAL PRIMARY KEY,
    guia_id         INT NOT NULL REFERENCES guia(id),
    z95_id          INT NOT NULL REFERENCES fac_z95(id),
    UNIQUE (guia_id, z95_id)
);

-- Líneas de la guía (detalle por referencia con cantidades parcializadas)
-- HU-CD-31: parcialización
CREATE TABLE guia_linea (
    id                   SERIAL PRIMARY KEY,
    guia_id              INT NOT NULL REFERENCES guia(id),
    z95_linea_id         INT REFERENCES fac_z95_linea(id),
    inv_linea_id         INT REFERENCES fac_inv_linea(id),
    referencia_id        INT NOT NULL REFERENCES cat_referencia(id),
    cantidad_guia        NUMERIC(12,3) NOT NULL,       -- Puede ser parcial del total Z95
    valor_unitario_usd   NUMERIC(14,4),
    valor_fob_usd        NUMERIC(18,2),
    reman_indicator      SMALLINT DEFAULT 0 CHECK (reman_indicator IN (0,1)),
    numero_caja          VARCHAR(30),                  -- HU-CD-34: trazabilidad física
    created_at           TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- MÓDULO 8: DOCUMENTO OPERATIVO (DO)
-- HU-CD-37
-- =====================

CREATE TABLE do_documento (
    id                   SERIAL PRIMARY KEY,
    numero_do            VARCHAR(50) NOT NULL UNIQUE,
    guia_id              INT NOT NULL REFERENCES guia(id) UNIQUE,  -- RN-01: 1 DO por guía
    fecha_creacion       TIMESTAMPTZ DEFAULT NOW(),
    estado               VARCHAR(30) NOT NULL DEFAULT 'Creado'
                         CHECK (estado IN (
                             'Creado','Enviado a Agencia','En Clasificacion',
                             'Con VoBo','Listo para DIM','Cerrado','Rechazado'
                         )),
    -- Integración FileZilla/SIACO (HU-CD-37)
    archivo_enviado      VARCHAR(300),
    fecha_envio_siaco    TIMESTAMPTZ,
    confirmacion_envio   BOOLEAN DEFAULT FALSE,
    fecha_confirmacion   TIMESTAMPTZ,
    -- Actualizaciones desde agencia
    btn_clasificado      BOOLEAN DEFAULT FALSE,       -- ¿Recibió BTN de SIACO?
    fecha_clasificacion  TIMESTAMPTZ,
    vobo_recibido        BOOLEAN DEFAULT FALSE,
    fecha_vobo           TIMESTAMPTZ,
    observaciones        TEXT,
    created_at           TIMESTAMPTZ DEFAULT NOW(),
    updated_at           TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- MÓDULO 9: DECLARACIÓN DE IMPORTACIÓN (DIM)
-- HU-CD-39, HU-CD-40
-- =====================

CREATE TABLE dim_declaracion (
    id                   SERIAL PRIMARY KEY,
    numero_dim           VARCHAR(50),                             -- Asignado por DIAN
    version              INT NOT NULL DEFAULT 1,                  -- Control de versiones (HU-CD-39)
    do_id                INT NOT NULL REFERENCES do_documento(id),
    guia_id              INT NOT NULL REFERENCES guia(id),
    compania_id          INT NOT NULL REFERENCES cat_compania(id),

    -- Campos de la DIM (HU-CD-39)
    tipo_dim_id          INT REFERENCES cat_tipo_dim(id),
    modalidad_id         INT REFERENCES cat_modalidad_dim(id),
    acuerdo_comercial    VARCHAR(100),
    forma_pago           VARCHAR(50),
    manifiesto_carga     VARCHAR(50),
    fecha_declaracion    DATE,
    tipo_importacion     VARCHAR(30),
    codigo_deposito      VARCHAR(30),
    trm_id               INT REFERENCES cat_trm(id),
    flete_usd            NUMERIC(14,2),
    bultos               INT,
    tipo_embalaje_id     INT REFERENCES cat_tipo_embalaje(id),
    peso_bruto_kg        NUMERIC(12,3),
    pais_origen          VARCHAR(5),
    pais_procedencia     VARCHAR(5),

    -- Estado de la DIM (HU-CD-39, HU-CD-40)
    estado               VARCHAR(30) NOT NULL DEFAULT 'Borrador'
                         CHECK (estado IN (
                             'Borrador','Validada','Impulsada','Transmitida',
                             'Aceptada','Pagada','Con Levante','Rechazada','Anulada'
                         )),

    -- Hito 1: Aceptación (HU-CD-40)
    nro_aceptacion       VARCHAR(50),
    fecha_aceptacion     TIMESTAMPTZ,

    -- Hito 2: Pago / Autoadhesivo (HU-CD-40)
    nro_autoadhesivo     VARCHAR(50),
    fecha_pago           TIMESTAMPTZ,
    valor_pagado_cop     NUMERIC(18,2),
    confirmacion_banco   VARCHAR(100),

    -- Hito 3: Levante (HU-CD-40)
    fecha_levante        TIMESTAMPTZ,
    tipo_levante         VARCHAR(20) CHECK (tipo_levante IN ('Automatico','Fisico')),
    observaciones_levante TEXT,

    -- Valores declarados
    valor_fob_usd        NUMERIC(18,2),
    valor_tributos_cop   NUMERIC(18,2),

    -- Autonomía operativa (HU-CD-39)
    archivo_generado     VARCHAR(300),
    fecha_impulso        TIMESTAMPTZ,
    reemplazada_por      INT REFERENCES dim_declaracion(id),    -- Control de versiones

    created_at           TIMESTAMPTZ DEFAULT NOW(),
    updated_at           TIMESTAMPTZ DEFAULT NOW()
);

-- Líneas de la DIM (por referencia)
CREATE TABLE dim_linea (
    id                SERIAL PRIMARY KEY,
    dim_id            INT NOT NULL REFERENCES dim_declaracion(id),
    referencia_id     INT NOT NULL REFERENCES cat_referencia(id),
    guia_linea_id     INT REFERENCES guia_linea(id),
    licencia_id       INT REFERENCES licencia_importacion(id),
    cantidad          NUMERIC(12,3) NOT NULL,
    valor_fob_usd     NUMERIC(18,2) NOT NULL,
    btn               VARCHAR(20),                              -- BTN asignado por SIACO
    arancel_pct       NUMERIC(6,4),
    valor_arancel_cop NUMERIC(18,2),
    valor_iva_cop     NUMERIC(18,2),
    created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- Actualizar FK en licencia_asignacion
ALTER TABLE licencia_asignacion
    ADD CONSTRAINT fk_licencia_dim FOREIGN KEY (dim_id) REFERENCES dim_declaracion(id);


-- =====================
-- MÓDULO 10: COSTEO Y DRS (HU-CD-41)
-- =====================

CREATE TABLE costeo_embarque (
    id                   SERIAL PRIMARY KEY,
    dim_id               INT NOT NULL REFERENCES dim_declaracion(id) UNIQUE,
    guia_id              INT NOT NULL REFERENCES guia(id),
    compania_id          INT NOT NULL REFERENCES cat_compania(id),

    -- Datos de migración a D365
    estado               VARCHAR(30) NOT NULL DEFAULT 'Listo para Costeo'
                         CHECK (estado IN (
                             'Listo para Costeo','Enviado a D365','Costeado',
                             'DRS Generado','Error de Migracion'
                         )),
    fecha_envio_d365     TIMESTAMPTZ,
    confirmacion_d365    BOOLEAN DEFAULT FALSE,
    fecha_confirmacion   TIMESTAMPTZ,
    error_detalle        TEXT,

    -- Valores del embarque
    valor_fob_total      NUMERIC(18,2),
    flete_usd            NUMERIC(14,2),
    tributos_cop         NUMERIC(18,2),
    costo_estimado_pct   NUMERIC(5,4) DEFAULT 0.02,    -- 2% parametrizable (HU-CD-41)
    costo_estimado_usd   NUMERIC(14,2),

    -- DRS retornado por D365
    nro_drs              VARCHAR(50),
    fecha_drs            TIMESTAMPTZ,
    estado_drs           VARCHAR(30),

    created_at           TIMESTAMPTZ DEFAULT NOW(),
    updated_at           TIMESTAMPTZ DEFAULT NOW()
);

-- Líneas de costeo (distribución por referencia)
CREATE TABLE costeo_linea (
    id                   SERIAL PRIMARY KEY,
    costeo_id            INT NOT NULL REFERENCES costeo_embarque(id),
    referencia_id        INT NOT NULL REFERENCES cat_referencia(id),
    dim_linea_id         INT REFERENCES dim_linea(id),
    cantidad             NUMERIC(12,3),
    valor_fob_usd        NUMERIC(18,2),
    flete_prorrateado    NUMERIC(14,2),
    tributos_prorrateados NUMERIC(14,2),
    costo_estimado_usd   NUMERIC(14,2),                 -- 2% prorrateado
    costo_total_usd      NUMERIC(18,2),                 -- FOB + flete + tributos + estimado
    created_at           TIMESTAMPTZ DEFAULT NOW()
);


-- =====================
-- MÓDULO 11: ALERTAS REMAN SIN LICENCIA (HU-CD-34)
-- =====================

CREATE TABLE alerta_reman (
    id                   SERIAL PRIMARY KEY,
    guia_id              INT REFERENCES guia(id),
    oc_numero            VARCHAR(30),
    z95_id               INT REFERENCES fac_z95(id),
    inv_id               INT REFERENCES fac_inv(id),
    referencia_id        INT REFERENCES cat_referencia(id),
    numero_caja          VARCHAR(30),
    btn                  VARCHAR(20),
    cantidad             NUMERIC(12,3),
    tipo_error           VARCHAR(50) NOT NULL   -- 'Sin licencia','Licencia vencida','Saldo insuficiente','No parametrizada'
                         CHECK (tipo_error IN (
                             'Sin licencia','Licencia vencida',
                             'Saldo insuficiente','No parametrizada'
                         )),
    comentario           TEXT,
    estado               VARCHAR(20) DEFAULT 'Pendiente'
                         CHECK (estado IN ('Pendiente','Resuelta')),
    resuelta_en          TIMESTAMPTZ,
    created_at           TIMESTAMPTZ DEFAULT NOW()
);


-- =====================
-- MÓDULO 12: LOG DE AUDITORÍA / SINCRONIZACIÓN
-- HU-CD-29
-- =====================

CREATE TABLE log_sincronizacion (
    id                   SERIAL PRIMARY KEY,
    tipo_interfaz        VARCHAR(10) NOT NULL CHECK (tipo_interfaz IN ('Z95','INV','OC')),
    fecha_ejecucion      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    registros_recibidos  INT DEFAULT 0,
    registros_insertados INT DEFAULT 0,
    registros_rechazados INT DEFAULT 0,
    registros_duplicados INT DEFAULT 0,
    estado               VARCHAR(20) NOT NULL CHECK (estado IN ('Exitosa','Con errores','Fallida')),
    detalle_error        TEXT,
    created_at           TIMESTAMPTZ DEFAULT NOW()
);

-- Auditoría general de cambios de estado en DIM
CREATE TABLE audit_dim_estado (
    id              SERIAL PRIMARY KEY,
    dim_id          INT NOT NULL REFERENCES dim_declaracion(id),
    estado_anterior VARCHAR(30),
    estado_nuevo    VARCHAR(30) NOT NULL,
    fuente          VARCHAR(50),    -- 'Sistema','DIAN','Agencia','Usuario'
    usuario         VARCHAR(100),
    fecha           TIMESTAMPTZ DEFAULT NOW(),
    observaciones   TEXT
);


-- =====================
-- ÍNDICES CLAVE
-- =====================

CREATE INDEX idx_z95_clave_compuesta ON fac_z95(numero, anio_factura, compania_id);
CREATE INDEX idx_z95_estado         ON fac_z95(estado);
CREATE INDEX idx_inv_compania       ON fac_inv(compania_id);
CREATE INDEX idx_inv_estado         ON fac_inv(estado);
CREATE INDEX idx_guia_estado        ON guia(estado);
CREATE INDEX idx_guia_dealer        ON guia(dealer_id);
CREATE INDEX idx_dim_estado         ON dim_declaracion(estado);
CREATE INDEX idx_dim_do             ON dim_declaracion(do_id);
CREATE INDEX idx_costeo_estado      ON costeo_embarque(estado);
CREATE INDEX idx_discrepancia_estado ON discrepancia(estado);
CREATE INDEX idx_licencia_estado    ON licencia_importacion(estado);
CREATE INDEX idx_alerta_reman_estado ON alerta_reman(estado);
CREATE INDEX idx_guia_linea_referencia ON guia_linea(referencia_id);
CREATE INDEX idx_dim_linea_referencia ON dim_linea(referencia_id);
