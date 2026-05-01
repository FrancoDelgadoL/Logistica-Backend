-- =====================================================
-- 1. TIPOS ENUM
-- =====================================================
CREATE TYPE estado_vehiculo AS ENUM ('ACTIVO', 'INHABILITADO', 'MANTENIMIENTO');
CREATE TYPE estado_solicitud AS ENUM ('ASIGNAR_VIAJE', 'EN_TRANSITO', 'COMPLETAR');

-- =====================================================
-- 2. TABLA VEHICULO (con user_id y capacidad_carga)
-- =====================================================
CREATE TABLE vehiculo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    placa VARCHAR(6) NOT NULL UNIQUE,
    modelo VARCHAR(100) NOT NULL,
    capacidad_carga NUMERIC(10,2) NOT NULL,
    estado estado_vehiculo NOT NULL DEFAULT 'ACTIVO',
    user_id UUID REFERENCES auth.users(id),          -- ← se mantiene
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT placa_formato_check CHECK (placa ~ '^[A-Z0-9]{6}$')
);

-- =====================================================
-- 3. TABLA: DOCUMENTO_VIGENCIA (Relación 1 a muchos con VEHICULO)
-- =====================================================
CREATE TABLE documento_vehiculo (
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
    dni VARCHAR(8) NOT NULL UNIQUE,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    licencia_categoria VARCHAR(5) NOT NULL,
    fecha_vencimiento_licencia DATE NOT NULL,
    telefono VARCHAR(15),
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    user_id UUID REFERENCES auth.users(id) UNIQUE,   -- ← se mantiene y es único
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
    codigo_servicio VARCHAR(50) NOT NULL UNIQUE,
    vehiculo_id UUID NULL REFERENCES vehiculo(id) ON DELETE RESTRICT,
    conductor_id UUID NULL REFERENCES conductor(id) ON DELETE RESTRICT,
    estado estado_solicitud NOT NULL DEFAULT 'ASIGNAR_VIAJE',
    cliente_nombre VARCHAR(200) NOT NULL,
    direccion_origen VARCHAR(255) NOT NULL,
    terminal_destino VARCHAR(50) NOT NULL,
    tipo_carga VARCHAR(100),
    peso_aprox_carga NUMERIC(10,2),
    fecha_solicitud TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT terminal_destino_check CHECK (terminal_destino IN ('Santa Anita', 'Callao')),
    CONSTRAINT asignacion_coherente CHECK (
        (estado = 'ASIGNAR_VIAJE' AND vehiculo_id IS NULL AND conductor_id IS NULL) OR
        (estado IN ('EN_TRANSITO', 'COMPLETAR') AND vehiculo_id IS NOT NULL AND conductor_id IS NOT NULL)
    )
);

-- =====================================================
-- 6. CREAR ÍNDICES
-- =====================================================

CREATE INDEX idx_vehiculo_placa ON vehiculo(placa);
CREATE INDEX idx_vehiculo_user_id ON vehiculo(user_id);
CREATE INDEX idx_documento_vehiculo_id ON documento_vehiculo(vehiculo_id);
CREATE INDEX idx_documento_vehiculo_expiracion ON documento_vehiculo(fecha_expiracion);
CREATE INDEX idx_conductor_dni ON conductor(dni);
CREATE INDEX idx_conductor_user_id ON conductor(user_id);
CREATE INDEX idx_solicitud_codigo ON solicitud_servicio(codigo_servicio);
CREATE INDEX idx_solicitud_estado ON solicitud_servicio(estado);
CREATE INDEX idx_solicitud_vehiculo ON solicitud_servicio(vehiculo_id);
CREATE INDEX idx_solicitud_conductor ON solicitud_servicio(conductor_id);

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




-- =====================================================
-- 8. TABLA ROLES
-- =====================================================

CREATE TABLE public.roles(
    id uuid PRIMARY KEY,
    role text NOT NULL DEFAULT 'CONDUCTOR',
    CONSTRAINT fk_user FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE,
    CONSTRAINT role_check CHECK (role IN ('ADMINISTRADOR', 'CONDUCTOR'))
);


---TRIGGER
create or REPLACE function public.handle_new_user()
returns TRIGGER as $$
begin
  insert into public.roles (id,role)
  values (new.id, 'CONDUCTOR');
  return new;
end;
$$ language plpgsql;

create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();



--=============================
--RLS
--=============================

ALTER TABLE conductor 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) UNIQUE;


alter table vehiculo enable row level security;
CREATE POLICY "vista_conductores" ON conductor
FOR SELECT USING (auth.uid()=user_id );

CREATE POLICY "admins_full_access_conductor" ON conductor
FOR ALL USING (
    EXISTS(SELECT 1 FROM roles WHERE id = auth.uid() AND role = 'ADMINISTRADOR')
);

CREATE POLICY "conductores_ven_sus_vehiculos" ON vehiculo
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "admins_full_vehiculo" ON vehiculo
FOR ALL USING (
    EXISTS(SELECT 1 FROM roles WHERE id = auth.uid() AND role = 'ADMINISTRADOR')
);
    

UPDATE roles
SET role = 'ADMINISTRADOR'
WHERE id=(SELECT id FROM auth.users WHERE email='administrador56@gmail.com');
