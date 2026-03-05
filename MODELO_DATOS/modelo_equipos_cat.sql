-- =============================================================
-- MODELO DE DATOS POSTGRESQL — IMPORTACIÓN DE EQUIPOS CAT
-- Basado en REQ-15 a REQ-22
-- Versión: 1.0 | Fecha: 2026-03-05
-- =============================================================

-- =====================
-- EXTENSIONES
-- =====================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================
-- MÓDULO 0: CATÁLOGOS
-- =====================

-- Compañías / Dealers (Gecolsa, Relianz, etc.)
CREATE TABLE sip_companias (
    id            SERIAL PRIMARY KEY,
    codigo        VARCHAR(10) NOT NULL UNIQUE,
    nombre        VARCHAR(100) NOT NULL,
    nit           VARCHAR(20),
    es_activa     BOOLEAN DEFAULT TRUE,
    created_at    TIMESTAMPTZ DEFAULT NOW(),
    updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Proveedores (Sincronizados de D365 - REQ-15)
CREATE TABLE sip_proveedores (
    id            SERIAL PRIMARY KEY,
    codigo_erp    VARCHAR(50) NOT NULL UNIQUE,
    nombre        VARCHAR(150) NOT NULL,
    pais_origen   VARCHAR(5),
    moneda_pago   VARCHAR(5) DEFAULT 'USD',
    es_activo     BOOLEAN DEFAULT TRUE,
    created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Modelos de Equipos (Maquinaria CAT)
CREATE TABLE sip_equipos_modelos (
    id                SERIAL PRIMARY KEY,
    modelo_codigo     VARCHAR(50) NOT NULL UNIQUE,
    descripcion       VARCHAR(300),
    es_remanufacturado BOOLEAN DEFAULT FALSE, -- REQ-17: Crítico para Licencia VUCE
    subpartida        VARCHAR(20),
    created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- MÓDULO 1: FACTURACIÓN (REQ-15)
-- =====================

-- Cabecera de Facturas
CREATE TABLE sip_facturas (
    id              SERIAL PRIMARY KEY,
    numero_factura  VARCHAR(50) NOT NULL,
    compania_id     INT NOT NULL REFERENCES sip_companias(id),
    proveedor_id    INT NOT NULL REFERENCES sip_proveedores(id),
    fecha_factura   DATE NOT NULL,
    incoterm        VARCHAR(10),
    valor_fob_total NUMERIC(18,2) NOT NULL,
    estado          VARCHAR(30) DEFAULT 'Pendiente Logística'
                    CHECK (estado IN ('Pendiente Logística', 'Asociada HBL', 'Nacionalizada', 'Consolidada')),
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (numero_factura, compania_id, proveedor_id)
);

-- Detalle de Facturas (Equipos individuales)
CREATE TABLE sip_factura_detalles (
    id               SERIAL PRIMARY KEY,
    factura_id       INT NOT NULL REFERENCES sip_facturas(id) ON DELETE CASCADE,
    modelo_id        INT NOT NULL REFERENCES sip_equipos_modelos(id),
    sereal_equipo    VARCHAR(50),
    cantidad         INT DEFAULT 1,
    valor_fob_usd    NUMERIC(18,2) NOT NULL,
    es_activo_fijo   BOOLEAN DEFAULT FALSE, -- REQ-19/20: Flag de persistencia crítica
    created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- MÓDULO 2: LOGÍSTICA (REQ-16 / REQ-18)
-- =====================

-- Embarques / Master BL (REQ-16)
CREATE TABLE sip_embarques_bl (
    id                SERIAL PRIMARY KEY,
    numero_bl         VARCHAR(50) NOT NULL UNIQUE,
    transportadora    VARCHAR(100),
    fecha_embarque    DATE,
    puerto_origen     VARCHAR(100),
    puerto_destino    VARCHAR(100),
    created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- Guías / House BL (REQ-18 - Llave maestra SII)
CREATE TABLE sip_guias_hbl (
    id                SERIAL PRIMARY KEY,
    numero_guia       VARCHAR(50) NOT NULL UNIQUE,
    embarque_id       INT REFERENCES sip_embarques_bl(id),
    compania_id       INT REFERENCES sip_companias(id),
    tipo_mercancia    VARCHAR(20) CHECK (tipo_mercancia IN ('Nueva', 'Remanufacturada')),
    estado            VARCHAR(30) DEFAULT 'Abierta'
                      CHECK (estado IN ('Abierta', 'En VUCE', 'Con Costos', 'Consolidada')),
    created_at        TIMESTAMPTZ DEFAULT NOW(),
    updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- Relación Guía x Facturas (N:M)
CREATE TABLE sip_guia_facturas (
    guia_id    INT REFERENCES sip_guias_hbl(id),
    factura_id INT REFERENCES sip_facturas(id),
    PRIMARY KEY (guia_id, factura_id)
);

-- =====================
-- MÓDULO 3: VUCE - TRÁMITES (REQ-17)
-- =====================

-- Licencias y Registros VUCE
CREATE TABLE sip_vuce_documentos (
    id                SERIAL PRIMARY KEY,
    numero_vuce       VARCHAR(50) NOT NULL UNIQUE,
    tipo_tramite      VARCHAR(20) CHECK (tipo_tramite IN ('Licencia', 'Registro')),
    fecha_vencimiento DATE,
    estado            VARCHAR(20) DEFAULT 'Vigente',
    created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- Vinculación de Documento VUCE a Equipos de la Guía
CREATE TABLE sip_vuce_asignaciones (
    id                SERIAL PRIMARY KEY,
    guia_id           INT NOT NULL REFERENCES sip_guias_hbl(id),
    factura_det_id    INT NOT NULL REFERENCES sip_factura_detalles(id),
    documento_vuce_id INT NOT NULL REFERENCES sip_vuce_documentos(id),
    created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- MÓDULO 4: COSTOS Y LIQUIDACIÓN (REQ-19 / REQ-20)
-- =====================

-- Tipos de Gasto (Flete, Seguro, Arancel, IVA, etc.)
CREATE TABLE sip_costos_conceptos (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(50) NOT NULL UNIQUE,
    es_impuesto BOOLEAN DEFAULT FALSE
);

-- Registro de Costos por Guía
CREATE TABLE sip_costos_nacionalizacion (
    id                SERIAL PRIMARY KEY,
    guia_id           INT NOT NULL REFERENCES sip_guias_hbl(id),
    concepto_id       INT NOT NULL REFERENCES sip_costos_conceptos(id),
    valor_usd         NUMERIC(18,2),
    valor_cop         NUMERIC(18,2),
    trm_aplicada      NUMERIC(15,4),
    created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- Prorrateo de Costos a Nivel Equipo (REQ-19)
CREATE TABLE sip_costos_equipos_det (
    id                SERIAL PRIMARY KEY,
    factura_det_id    INT NOT NULL REFERENCES sip_factura_detalles(id),
    guia_id           INT NOT NULL REFERENCES sip_guias_hbl(id),
    valor_arancel     NUMERIC(18,2),
    valor_iva         NUMERIC(18,2),
    otros_costos_usd  NUMERIC(18,2),
    costo_total_unit  NUMERIC(18,2), -- Landed Cost Unitario
    es_activo_fijo    BOOLEAN,       -- Persistencia REQ-20
    created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- MÓDULO 5: CONSOLIDACIÓN Y ERP (REQ-22)
-- =====================

-- Log de Envío a D365
CREATE TABLE sip_interfaz_erp_logs (
    id                SERIAL PRIMARY KEY,
    guia_id           INT NOT NULL REFERENCES sip_guias_hbl(id),
    fecha_envio       TIMESTAMPTZ DEFAULT NOW(),
    estado_erp        VARCHAR(20) CHECK (estado_erp IN ('Exitoso', 'Error', 'Pendiente')),
    mensaje_respuesta TEXT,
    payload_json      JSONB,
    created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- ÍNDICES
-- =====================
CREATE INDEX idx_factura_num ON sip_facturas(numero_factura);
CREATE INDEX idx_guia_num ON sip_guias_hbl(numero_guia);
CREATE INDEX idx_factdet_serial ON sip_factura_detalles(sereal_equipo);
CREATE INDEX idx_costo_guia ON sip_costos_nacionalizacion(guia_id);
