-- 1. CREAR TIPO ENUM PARA ESTADOS DEL VEHÍCULO
CREATE TYPE estado_vehiculo AS ENUM ('ACTIVO', 'INHABILITADO', 'MANTENIMIENTO');

-- =====================================================
-- 2. TABLA: VEHICULO
-- =====================================================
CREATE TABLE vehiculo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    placa VARCHAR(6) NOT NULL UNIQUE,
    modelo VARCHAR(100) NOT NULL,
    estado estado_vehiculo NOT NULL DEFAULT 'ACTIVO',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT placa_formato_check CHECK (placa ~ '^[A-Z0-9]{6}$')
);

-- =====================================================
-- 3. TABLA: DOCUMENTO_VIGENCIA (Relación 1 a muchos con VEHICULO)
-- =====================================================
CREATE TABLE documento_vigencia (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL REFERENCES vehiculo(id) ON DELETE RESTRICT,
    tipo_documento VARCHAR(50) NOT NULL,
    fecha_emision DATE NOT NULL,
    fecha_expiracion DATE NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'VIGENTE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fecha_check CHECK (fecha_expiracion > fecha_emision)
);

-- =====================================================
-- 4. TABLA: CONDUCTOR
-- =====================================================
CREATE TABLE conductor (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    dni VARCHAR(8) NOT NULL UNIQUE,
    licencia_cat VARCHAR(5) NOT NULL,
    fecha_vencimiento_licencia DATE NOT NULL,
    telefono VARCHAR(15),
    email VARCHAR(100),
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT dni_formato_check CHECK (dni ~ '^[0-9]{8}$')
);

-- =====================================================
-- 5. TABLA: SOLICITUD_SERVICIO (SOLO DATOS DE LA SOLICITUD)
-- SIN vehiculo_id, sin conductor_id, sin fecha_inicio_servicio
-- =====================================================
CREATE TABLE solicitud_servicio (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre_cliente VARCHAR(200) NOT NULL,
    fecha_solicitud TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    punto_recogida_direccion VARCHAR(255) NOT NULL,
    punto_recogida_distrito VARCHAR(100) NOT NULL,
    terminal_destino VARCHAR(50) NOT NULL,
    tipo_carga VARCHAR(100),
    peso_estimado_kg NUMERIC(10, 2),
    estado_solicitud VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT terminal_destino_check CHECK (terminal_destino IN ('Santa Anita', 'Callao'))
);

-- =====================================================
-- 6. CREAR ÍNDICES
-- =====================================================

-- Índices para DOCUMENTO_VIGENCIA
CREATE INDEX idx_documento_vehiculo ON documento_vigencia(vehiculo_id);
CREATE INDEX idx_documento_fechas ON documento_vigencia(fecha_expiracion);
CREATE INDEX idx_documento_tipo ON documento_vigencia(tipo_documento);

-- Índices para CONDUCTOR
CREATE INDEX idx_conductor_dni ON conductor(dni);
CREATE INDEX idx_conductor_licencia_cat ON conductor(licencia_cat);

-- Índices para SOLICITUD_SERVICIO
CREATE INDEX idx_solicitud_estado ON solicitud_servicio(estado_solicitud);
CREATE INDEX idx_solicitud_cliente ON solicitud_servicio(nombre_cliente);
CREATE INDEX idx_solicitud_fechas ON solicitud_servicio(fecha_solicitud);
CREATE INDEX idx_solicitud_terminal ON solicitud_servicio(terminal_destino);

-- =====================================================
-- 7. TRIGGER PARA updated_at
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_vehiculo_updated_at 
    BEFORE UPDATE ON vehiculo 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_documento_vigencia_updated_at 
    BEFORE UPDATE ON documento_vigencia 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conductor_updated_at 
    BEFORE UPDATE ON conductor 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_solicitud_servicio_updated_at 
    BEFORE UPDATE ON solicitud_servicio 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
