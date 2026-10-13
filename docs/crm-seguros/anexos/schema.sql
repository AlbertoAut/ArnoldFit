-- =====================================================================
--  CRM SEGUROS · Esquema base PostgreSQL (Supabase)
--  Versión 0.1 · Diseñado para 1 agente hoy, multi-tenant desde el día 1
-- ---------------------------------------------------------------------
--  Convenciones
--   · Toda tabla de negocio lleva tenant_id (la "agencia"). En el MVP hay
--     un solo tenant; cuando se convierta en SaaS no hay que migrar nada.
--   · RLS activado en todas las tablas. El JWT de Supabase Auth lleva
--     app_metadata.tenant_id; n8n usa la service_role key (bypassa RLS)
--     y por eso debe filtrar SIEMPRE por tenant_id explícitamente.
--   · Dinero en numeric(14,2); fechas de vigencia en date; eventos en
--     timestamptz. Moneda ISO (MXN, USD, UDI).
--   · Campos variables por ramo van en jsonb (datos_ramo) y se validan
--     con un JSON Schema por ramo en la app, no en la BD.
--   · Nada de credenciales de portales de aseguradoras en esta BD:
--     viven en el gestor de credenciales de n8n / Bitwarden.
-- =====================================================================

create extension if not exists "pgcrypto";
create extension if not exists "vector";       -- pgvector para RAG
create extension if not exists "pg_trgm";      -- búsqueda difusa por nombre

-- ---------------------------------------------------------------------
-- 0. Tenancy, usuarios, roles
-- ---------------------------------------------------------------------
create table tenants (
  id            uuid primary key default gen_random_uuid(),
  nombre        text not null,                 -- "Promotoría X" / nombre del agente
  rfc           text,
  plan          text not null default 'interno', -- interno | starter | pro (futuro SaaS)
  zona_horaria  text not null default 'America/Mexico_City',
  config        jsonb not null default '{}',   -- días de recordatorio por defecto, etc.
  created_at    timestamptz not null default now()
);

create type rol_usuario as enum ('owner','agente','asistente','solo_lectura');

create table perfiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  tenant_id   uuid not null references tenants(id),
  nombre      text not null,
  email       text,
  telefono    text,
  rol         rol_usuario not null default 'agente',
  activo      boolean not null default true,
  created_at  timestamptz not null default now()
);

-- Cédulas del agente (CNSF). Alerta de vencimiento.
create table cedulas (
  id          uuid primary key default gen_random_uuid(),
  tenant_id   uuid not null references tenants(id),
  perfil_id   uuid references perfiles(id),
  tipo        text not null,          -- A, B, C, D, F, ... (ver anexo legal)
  numero      text not null,
  vigencia_inicio date,
  vigencia_fin    date,
  documento_id    uuid                -- FK lógica a documentos
);

-- ---------------------------------------------------------------------
-- 1. Catálogos
-- ---------------------------------------------------------------------
create table aseguradoras (
  id            uuid primary key default gen_random_uuid(),
  nombre        text not null unique,        -- Quálitas, GNP, AXA, HDI, MetLife, SMNYL...
  nombre_corto  text,
  rfc           text,
  portal_agentes_url text,
  telefono_siniestros text,
  telefono_cabina     text,
  dominios_email text[],                      -- para clasificar correos entrantes
  activo        boolean not null default true
);

create type ramo as enum ('AUTOS','VIDA','GMM','ACCIDENTES','DANOS','EMPRESARIAL','FIANZAS','OTRO');

create table productos (
  id              uuid primary key default gen_random_uuid(),
  aseguradora_id  uuid not null references aseguradoras(id),
  ramo            ramo not null,
  nombre          text not null,              -- "Amplia", "Privilegio", "Flex Plus"...
  descripcion     text,
  comision_pct_default_primer_anio numeric(5,2),
  comision_pct_default_renovacion  numeric(5,2),
  unique (aseguradora_id, ramo, nombre)
);

-- Un agente tiene UNA clave por aseguradora. Las comisiones se liquidan por clave.
create table claves_agente (
  id              uuid primary key default gen_random_uuid(),
  tenant_id       uuid not null references tenants(id),
  aseguradora_id  uuid not null references aseguradoras(id),
  clave           text not null,
  perfil_id       uuid references perfiles(id),
  promotoria      text,                        -- si cobra por conducto de promotoría
  esquema_pago    text,                        -- "directo" | "promotoria"
  credencial_ref  text,                        -- nombre de la credencial en n8n/Bitwarden, NUNCA la contraseña
  activo          boolean not null default true,
  unique (tenant_id, aseguradora_id, clave)
);

-- ---------------------------------------------------------------------
-- 2. Contactos (clientes y prospectos)
-- ---------------------------------------------------------------------
create type tipo_persona as enum ('FISICA','MORAL');
create type etapa_contacto as enum ('PROSPECTO','CLIENTE','EX_CLIENTE');

create table contactos (
  id              uuid primary key default gen_random_uuid(),
  tenant_id       uuid not null references tenants(id),
  tipo_persona    tipo_persona not null default 'FISICA',
  nombre          text,                        -- persona física
  apellido_paterno text,
  apellido_materno text,
  razon_social    text,                        -- persona moral
  nombre_completo text generated always as (
    coalesce(razon_social, nullif(regexp_replace(btrim(
      coalesce(nombre,'') || ' ' || coalesce(apellido_paterno,'') || ' ' || coalesce(apellido_materno,'')
    ), '\s+', ' ', 'g'), ''))
  ) stored,
  rfc             text,
  curp            text,
  fecha_nacimiento date,
  sexo            text,
  estado_civil    text,
  ocupacion       text,
  email           text,
  telefono_whatsapp text,                      -- E.164: +52155...
  telefono_alterno  text,
  -- domicilio
  calle text, numero_ext text, numero_int text, colonia text,
  codigo_postal text, municipio text, estado text, pais text default 'MX',
  -- relación comercial
  etapa           etapa_contacto not null default 'PROSPECTO',
  origen          text,                        -- referido, redes, campaña, cartera heredada...
  referido_por_id uuid references contactos(id),
  agente_id       uuid references perfiles(id),
  tags            text[] not null default '{}',
  notas           text,
  -- comunicación
  whatsapp_optin  boolean not null default false,
  whatsapp_optin_fecha timestamptz,
  no_contactar    boolean not null default false,
  -- housekeeping
  datos_extra     jsonb not null default '{}',
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  deleted_at      timestamptz                   -- borrado lógico (bloqueo ARCO)
);
create index on contactos (tenant_id, etapa);
create index on contactos using gin (nombre_completo gin_trgm_ops);
create unique index contactos_rfc_unq on contactos (tenant_id, rfc) where rfc is not null and deleted_at is null;

-- Consentimientos (LFPDPPP): evidencia de aviso de privacidad, datos sensibles, opt-in WA
create table consentimientos (
  id            uuid primary key default gen_random_uuid(),
  tenant_id     uuid not null references tenants(id),
  contacto_id   uuid not null references contactos(id),
  tipo          text not null,  -- AVISO_PRIVACIDAD | DATOS_SENSIBLES | WHATSAPP_OPTIN | MARKETING
  version_aviso text,
  otorgado      boolean not null,
  fecha         timestamptz not null default now(),
  canal         text,           -- whatsapp | formulario | papel | email
  evidencia     jsonb,          -- wa_message_id, ip, hash del PDF firmado, etc.
  documento_id  uuid
);

-- ---------------------------------------------------------------------
-- 3. Pólizas y su anatomía
-- ---------------------------------------------------------------------
create type estatus_poliza as enum (
  'COTIZADA','EN_TRAMITE','VIGENTE','POR_RENOVAR','RENOVADA','CANCELADA','VENCIDA','REHABILITADA','SUSPENDIDA'
);
create type forma_pago as enum ('ANUAL','SEMESTRAL','TRIMESTRAL','MENSUAL','UNICO');
create type conducto_cobro as enum ('AGENTE','CARGO_TARJETA','DOMICILIACION','VENTANILLA','TRANSFERENCIA','NOMINA');

create table polizas (
  id                uuid primary key default gen_random_uuid(),
  tenant_id         uuid not null references tenants(id),
  contratante_id    uuid not null references contactos(id),
  aseguradora_id    uuid not null references aseguradoras(id),
  producto_id       uuid references productos(id),
  clave_agente_id   uuid references claves_agente(id),
  ramo              ramo not null,
  numero_poliza     text not null,
  numero_renovacion int not null default 0,     -- 0 = emisión original
  poliza_anterior_id uuid references polizas(id),
  estatus           estatus_poliza not null default 'VIGENTE',
  fecha_emision     date,
  vigencia_inicio   date not null,
  vigencia_fin      date not null,
  moneda            text not null default 'MXN',
  prima_neta        numeric(14,2),
  derecho_poliza    numeric(14,2) default 0,    -- gastos de expedición
  recargo_pago_fraccionado numeric(14,2) default 0,
  iva               numeric(14,2) default 0,
  prima_total       numeric(14,2),
  forma_pago        forma_pago not null default 'ANUAL',
  conducto_cobro    conducto_cobro not null default 'AGENTE',
  renovacion_automatica boolean not null default false,
  comision_pct      numeric(5,2),               -- % aplicable a esta vigencia
  comision_estimada numeric(14,2),
  datos_ramo        jsonb not null default '{}', -- ver JSON Schemas por ramo
  observaciones     text,
  caratula_documento_id uuid,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  check (vigencia_fin > vigencia_inicio)
);
create unique index polizas_unq on polizas (tenant_id, aseguradora_id, numero_poliza, numero_renovacion);
create index on polizas (tenant_id, vigencia_fin) where estatus in ('VIGENTE','POR_RENOVAR');

-- Asegurados / incisos / beneficiarios. Autos: cada vehículo es un inciso.
-- GMM: titular + dependientes. Vida: asegurado + beneficiarios con %.
create type rol_asegurado as enum ('TITULAR','DEPENDIENTE','CONDUCTOR','BENEFICIARIO','INCISO','OBLIGADO_SOLIDARIO','FIADO');

create table asegurados (
  id            uuid primary key default gen_random_uuid(),
  tenant_id     uuid not null references tenants(id),
  poliza_id     uuid not null references polizas(id) on delete cascade,
  contacto_id   uuid references contactos(id),   -- si es persona registrada
  rol           rol_asegurado not null,
  numero_inciso int,
  nombre        text,
  parentesco    text,
  fecha_nacimiento date,
  porcentaje    numeric(5,2),                     -- beneficiarios
  suma_asegurada numeric(14,2),
  deducible     text,                             -- "5%" o monto
  coaseguro     text,
  datos         jsonb not null default '{}'       -- vehículo: marca, submarca, modelo, serie, placas, uso, color
);
create index on asegurados (tenant_id, poliza_id);

-- Endosos / movimientos
create table endosos (
  id            uuid primary key default gen_random_uuid(),
  tenant_id     uuid not null references tenants(id),
  poliza_id     uuid not null references polizas(id) on delete cascade,
  numero_endoso text,
  tipo          text not null,       -- A (datos), B (aumento prima), D (devolución), ALTA_INCISO, BAJA_INCISO, CAMBIO_BENEFICIARIO...
  fecha         date not null,
  descripcion   text,
  prima_diferencia numeric(14,2) default 0,
  documento_id  uuid
);

-- ---------------------------------------------------------------------
-- 4. Recibos, pagos, comisiones
-- ---------------------------------------------------------------------
create type estatus_recibo as enum ('PENDIENTE','PAGADO','VENCIDO','CANCELADO','EN_GRACIA');

create table recibos (
  id              uuid primary key default gen_random_uuid(),
  tenant_id       uuid not null references tenants(id),
  poliza_id       uuid not null references polizas(id) on delete cascade,
  numero_recibo   text,
  consecutivo     int not null,              -- 1..n dentro de la vigencia
  total_recibos   int not null,
  periodo_inicio  date not null,
  periodo_fin     date not null,
  fecha_vencimiento date not null,
  dias_gracia     int not null default 30,   -- Ley sobre el Contrato de Seguro art. 40
  fecha_limite_pago date generated always as (fecha_vencimiento + dias_gracia) stored,
  importe         numeric(14,2) not null,
  moneda          text not null default 'MXN',
  estatus         estatus_recibo not null default 'PENDIENTE',
  fecha_pago      date,
  metodo_pago     text,
  referencia_pago text,
  comprobante_documento_id uuid,
  unique (tenant_id, poliza_id, consecutivo)
);
create index on recibos (tenant_id, estatus, fecha_vencimiento);

create type tipo_comision as enum ('DIRECTA','RENOVACION','BONO','AJUSTE','CLAWBACK');
create type estatus_comision as enum ('ESPERADA','REPORTADA','PAGADA','CONCILIADA','DIFERENCIA','NO_RECONOCIDA');

-- Estados de cuenta que manda la aseguradora (PDF/Excel) con el detalle de comisiones
create table estados_cuenta_comisiones (
  id              uuid primary key default gen_random_uuid(),
  tenant_id       uuid not null references tenants(id),
  aseguradora_id  uuid not null references aseguradoras(id),
  clave_agente_id uuid references claves_agente(id),
  periodo_inicio  date,
  periodo_fin     date,
  fecha_pago      date,
  total_bruto     numeric(14,2),
  retencion_isr   numeric(14,2),
  retencion_iva   numeric(14,2),
  total_neto      numeric(14,2),
  cfdi_uuid       text,
  documento_id    uuid,
  parseado        boolean not null default false
);

create table comisiones (
  id              uuid primary key default gen_random_uuid(),
  tenant_id       uuid not null references tenants(id),
  poliza_id       uuid references polizas(id),
  recibo_id       uuid references recibos(id),
  estado_cuenta_id uuid references estados_cuenta_comisiones(id),
  tipo            tipo_comision not null default 'DIRECTA',
  porcentaje      numeric(5,2),
  base            numeric(14,2),               -- prima neta del recibo
  importe_esperado numeric(14,2),
  importe_reportado numeric(14,2),
  diferencia      numeric(14,2) generated always as (coalesce(importe_reportado,0) - coalesce(importe_esperado,0)) stored,
  estatus         estatus_comision not null default 'ESPERADA',
  fecha_esperada  date,
  fecha_pago      date,
  notas           text
);
create index on comisiones (tenant_id, estatus);

-- ---------------------------------------------------------------------
-- 5. Siniestros
-- ---------------------------------------------------------------------
create type estatus_siniestro as enum ('REPORTADO','EN_PROCESO','DOCUMENTACION','EN_VALUACION','PAGADO','RECHAZADO','CERRADO');

create table siniestros (
  id              uuid primary key default gen_random_uuid(),
  tenant_id       uuid not null references tenants(id),
  poliza_id       uuid not null references polizas(id),
  asegurado_id    uuid references asegurados(id),
  numero_siniestro text,
  tipo            text,                        -- colisión, robo total, hospitalización, fallecimiento, incendio...
  fecha_ocurrencia timestamptz,
  fecha_reporte   timestamptz not null default now(),
  descripcion     text,
  estatus         estatus_siniestro not null default 'REPORTADO',
  ajustador_nombre text,
  ajustador_telefono text,
  taller_hospital text,
  deducible_aplicado numeric(14,2),
  monto_reclamado numeric(14,2),
  monto_pagado    numeric(14,2),
  modalidad       text,                        -- pago directo | reembolso (GMM)
  checklist       jsonb not null default '[]', -- [{item, requerido, completado, documento_id}]
  fecha_cierre    timestamptz,
  notas           text
);

-- ---------------------------------------------------------------------
-- 6. Ventas: oportunidades y cotizaciones
-- ---------------------------------------------------------------------
create type etapa_oportunidad as enum ('NUEVO','CONTACTADO','COTIZADO','NEGOCIACION','GANADO','PERDIDO');

create table oportunidades (
  id              uuid primary key default gen_random_uuid(),
  tenant_id       uuid not null references tenants(id),
  contacto_id     uuid not null references contactos(id),
  ramo            ramo not null,
  etapa           etapa_oportunidad not null default 'NUEVO',
  prima_estimada  numeric(14,2),
  fecha_cierre_estimada date,
  fuente          text,
  motivo_perdida  text,
  poliza_id       uuid references polizas(id),  -- cuando se gana
  agente_id       uuid references perfiles(id),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create table cotizaciones (
  id              uuid primary key default gen_random_uuid(),
  tenant_id       uuid not null references tenants(id),
  oportunidad_id  uuid references oportunidades(id),
  contacto_id     uuid not null references contactos(id),
  aseguradora_id  uuid references aseguradoras(id),
  ramo            ramo not null,
  datos_riesgo    jsonb not null default '{}',   -- vehículo, edades, giro, suma asegurada...
  prima_total     numeric(14,2),
  moneda          text default 'MXN',
  vigencia_cotizacion date,
  estatus         text not null default 'ENVIADA', -- BORRADOR | ENVIADA | ACEPTADA | RECHAZADA
  documento_id    uuid,
  created_at      timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 7. Actividad, comunicación, documentos
-- ---------------------------------------------------------------------
create type tipo_actividad as enum ('LLAMADA','WHATSAPP','EMAIL','CITA','TAREA','NOTA','VISITA');

create table actividades (
  id              uuid primary key default gen_random_uuid(),
  tenant_id       uuid not null references tenants(id),
  tipo            tipo_actividad not null,
  titulo          text not null,
  descripcion     text,
  contacto_id     uuid references contactos(id),
  poliza_id       uuid references polizas(id),
  siniestro_id    uuid references siniestros(id),
  oportunidad_id  uuid references oportunidades(id),
  asignado_a      uuid references perfiles(id),
  fecha_programada timestamptz,
  completada_en   timestamptz,
  prioridad       smallint not null default 2,  -- 1 alta, 2 media, 3 baja
  origen          text not null default 'MANUAL', -- MANUAL | AUTOMATICO
  created_at      timestamptz not null default now()
);
create index on actividades (tenant_id, asignado_a, fecha_programada) where completada_en is null;

create type canal as enum ('WHATSAPP','EMAIL','SMS','LLAMADA','PRESENCIAL');

create table conversaciones (
  id              uuid primary key default gen_random_uuid(),
  tenant_id       uuid not null references tenants(id),
  contacto_id     uuid references contactos(id),
  canal           canal not null,
  identificador   text not null,               -- wa_id (teléfono) o email
  modo            text not null default 'BOT', -- BOT | HUMANO
  ventana_servicio_expira timestamptz,         -- 24 h desde último msg del cliente
  ultimo_mensaje_en timestamptz,
  asignado_a      uuid references perfiles(id),
  resumen_ia      text,
  unique (tenant_id, canal, identificador)
);

create table mensajes (
  id              uuid primary key default gen_random_uuid(),
  tenant_id       uuid not null references tenants(id),
  conversacion_id uuid not null references conversaciones(id) on delete cascade,
  direccion       text not null,               -- IN | OUT
  autor           text not null,               -- CLIENTE | BOT | AGENTE | SISTEMA
  tipo            text not null default 'text',-- text | image | document | audio | template | interactive
  contenido       text,
  media_documento_id uuid,
  plantilla       text,                        -- nombre de plantilla Meta si aplica
  categoria_meta  text,                        -- utility | marketing | authentication | service
  proveedor_msg_id text,                       -- wamid
  estatus_entrega text,                        -- sent | delivered | read | failed
  error           jsonb,
  costo_usd       numeric(8,5),
  created_at      timestamptz not null default now()
);
create index on mensajes (tenant_id, conversacion_id, created_at);

create type tipo_documento as enum (
  'CARATULA','RECIBO','ENDOSO','CONDICIONES_GENERALES','COTIZACION','IDENTIFICACION','COMPROBANTE_DOMICILIO',
  'FACTURA_VEHICULO','ESTADO_CUENTA_COMISIONES','CFDI_XML','CFDI_PDF','COMPROBANTE_PAGO','SINIESTRO','CONSENTIMIENTO','OTRO'
);
create type estatus_extraccion as enum ('PENDIENTE','PROCESANDO','POR_REVISAR','APROBADA','RECHAZADA','NO_APLICA');

create table documentos (
  id              uuid primary key default gen_random_uuid(),
  tenant_id       uuid not null references tenants(id),
  tipo            tipo_documento not null default 'OTRO',
  nombre_archivo  text not null,
  storage_bucket  text not null default 'documentos',
  storage_path    text not null,
  mime            text,
  tamano_bytes    bigint,
  sha256          text not null,
  origen          text not null,               -- EMAIL | WHATSAPP | MANUAL | RPA | API
  origen_ref      text,                        -- message-id del correo, wamid...
  contacto_id     uuid references contactos(id),
  poliza_id       uuid references polizas(id),
  recibo_id       uuid references recibos(id),
  siniestro_id    uuid references siniestros(id),
  aseguradora_id  uuid references aseguradoras(id),
  extraccion_estatus estatus_extraccion not null default 'PENDIENTE',
  extraccion      jsonb,                       -- salida estructurada de la IA
  extraccion_confianza numeric(4,3),
  extraccion_modelo text,
  revisado_por    uuid references perfiles(id),
  revisado_en     timestamptz,
  created_at      timestamptz not null default now(),
  unique (tenant_id, sha256)                   -- idempotencia: el mismo PDF no entra dos veces
);
create index on documentos (tenant_id, extraccion_estatus);

-- Chunks vectorizados para el asistente (RAG): condiciones generales, FAQs, carátulas
create table documento_chunks (
  id            bigserial primary key,
  tenant_id     uuid not null references tenants(id),
  documento_id  uuid references documentos(id) on delete cascade,
  aseguradora_id uuid references aseguradoras(id),
  producto_id   uuid references productos(id),
  contacto_id   uuid references contactos(id),  -- null = conocimiento general
  pagina        int,
  contenido     text not null,
  embedding     vector(1024),                   -- ajustar a la dimensión del modelo elegido
  metadata      jsonb not null default '{}'
);
create index on documento_chunks using hnsw (embedding vector_cosine_ops);

-- ---------------------------------------------------------------------
-- 8. Automatización: plantillas, reglas, bitácora de envíos
-- ---------------------------------------------------------------------
create table plantillas_mensaje (
  id            uuid primary key default gen_random_uuid(),
  tenant_id     uuid not null references tenants(id),
  nombre        text not null,                 -- nombre exacto en Meta
  canal         canal not null default 'WHATSAPP',
  categoria     text not null,                 -- utility | marketing | authentication
  idioma        text not null default 'es_MX',
  cuerpo        text not null,
  variables     text[] not null default '{}',
  estatus_meta  text,                          -- APPROVED | PENDING | REJECTED
  unique (tenant_id, nombre, idioma)
);

create table reglas_recordatorio (
  id            uuid primary key default gen_random_uuid(),
  tenant_id     uuid not null references tenants(id),
  nombre        text not null,
  evento        text not null,                 -- VENCIMIENTO_POLIZA | VENCIMIENTO_RECIBO | FIN_GRACIA | CUMPLEANOS | CEDULA | SINIESTRO_SIN_MOVIMIENTO
  ramo          ramo,                          -- null = todos
  dias_offset   int not null,                  -- -30, -15, -7, -1, +3 ...
  canal         canal not null default 'WHATSAPP',
  plantilla_id  uuid references plantillas_mensaje(id),
  destinatario  text not null default 'CLIENTE', -- CLIENTE | AGENTE | AMBOS
  activo        boolean not null default true
);

create table envios_programados (
  id            uuid primary key default gen_random_uuid(),
  tenant_id     uuid not null references tenants(id),
  regla_id      uuid references reglas_recordatorio(id),
  contacto_id   uuid references contactos(id),
  poliza_id     uuid references polizas(id),
  recibo_id     uuid references recibos(id),
  fecha_programada date not null,
  estatus       text not null default 'PENDIENTE', -- PENDIENTE | ENVIADO | OMITIDO | ERROR
  mensaje_id    uuid references mensajes(id),
  error         text
);
-- Idempotencia: un recordatorio por regla, objetivo y fecha
create unique index envios_programados_unq on envios_programados
  (tenant_id, regla_id, coalesce(poliza_id, recibo_id, contacto_id), fecha_programada);

-- ---------------------------------------------------------------------
-- 9. Cumplimiento: auditoría y ARCO
-- ---------------------------------------------------------------------
create table auditoria (
  id          bigserial primary key,
  tenant_id   uuid,
  tabla       text not null,
  registro_id text not null,
  accion      text not null,                   -- INSERT | UPDATE | DELETE | READ_SENSIBLE | EXPORT
  usuario_id  uuid,
  antes       jsonb,
  despues     jsonb,
  ip          inet,
  created_at  timestamptz not null default now()
);
-- Append-only: nadie puede modificar ni borrar auditoría.
revoke update, delete on auditoria from authenticated, anon;

create or replace function fn_auditoria() returns trigger language plpgsql security definer as $$
begin
  insert into auditoria (tenant_id, tabla, registro_id, accion, usuario_id, antes, despues)
  values (
    coalesce(new.tenant_id, old.tenant_id),
    tg_table_name,
    coalesce(new.id::text, old.id::text),
    tg_op,
    auth.uid(),
    case when tg_op in ('UPDATE','DELETE') then to_jsonb(old) end,
    case when tg_op in ('INSERT','UPDATE') then to_jsonb(new) end
  );
  return coalesce(new, old);
end $$;

-- Aplicar a tablas con datos personales / dinero
do $$ declare t text; begin
  foreach t in array array['contactos','polizas','asegurados','recibos','comisiones','siniestros','documentos','consentimientos']
  loop
    execute format('create trigger trg_aud_%1$s after insert or update or delete on %1$s for each row execute function fn_auditoria()', t);
  end loop;
end $$;

create table solicitudes_arco (
  id              uuid primary key default gen_random_uuid(),
  tenant_id       uuid not null references tenants(id),
  contacto_id     uuid not null references contactos(id),
  tipo            text not null,              -- ACCESO | RECTIFICACION | CANCELACION | OPOSICION | PORTABILIDAD
  fecha_recepcion date not null default current_date,
  fecha_limite    date not null,              -- calcular 20 días hábiles en la app
  estatus         text not null default 'RECIBIDA', -- RECIBIDA | EN_PROCESO | RESPONDIDA | NEGADA
  respuesta       text,
  evidencia_documento_id uuid,
  created_at      timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 10. RLS: una política por tabla, basada en tenant del JWT
-- ---------------------------------------------------------------------
-- SECURITY DEFINER es obligatorio: la función lee `perfiles`, que a su vez tiene
-- RLS basada en esta misma función. Sin definer habría recursión infinita.
create or replace function current_tenant_id() returns uuid
language sql stable security definer set search_path = public as $$
  select nullif(coalesce(
    auth.jwt() -> 'app_metadata' ->> 'tenant_id',
    (select tenant_id::text from perfiles where id = auth.uid())
  ), '')::uuid
$$;
revoke all on function current_tenant_id() from public;
grant execute on function current_tenant_id() to authenticated, service_role;

do $$ declare t text; begin
  foreach t in array array[
    'perfiles','cedulas','claves_agente','contactos','consentimientos','polizas','asegurados','endosos',
    'recibos','estados_cuenta_comisiones','comisiones','siniestros','oportunidades','cotizaciones',
    'actividades','conversaciones','mensajes','documentos','documento_chunks','plantillas_mensaje',
    'reglas_recordatorio','envios_programados','solicitudes_arco','auditoria']
  loop
    execute format('alter table %I enable row level security', t);
    execute format('create policy tenant_isolation on %I for all to authenticated using (tenant_id = current_tenant_id()) with check (tenant_id = current_tenant_id())', t);
  end loop;
end $$;

-- Catálogos globales: lectura para todos, escritura solo service_role
alter table aseguradoras enable row level security;
alter table productos enable row level security;
create policy read_all on aseguradoras for select to authenticated using (true);
create policy read_all on productos for select to authenticated using (true);
alter table tenants enable row level security;
create policy own_tenant on tenants for select to authenticated using (id = current_tenant_id());

-- ---------------------------------------------------------------------
-- 11. Vistas operativas (lo que ve el agente cada mañana)
-- ---------------------------------------------------------------------
create or replace view v_renovaciones_proximas as
select p.*, c.nombre_completo, c.telefono_whatsapp, a.nombre as aseguradora,
       (p.vigencia_fin - current_date) as dias_para_vencer
from polizas p
join contactos c on c.id = p.contratante_id
join aseguradoras a on a.id = p.aseguradora_id
where p.estatus in ('VIGENTE','POR_RENOVAR')
  and p.vigencia_fin between current_date and current_date + 60;

create or replace view v_cobranza as
select r.*, p.numero_poliza, p.ramo, c.nombre_completo, c.telefono_whatsapp,
       case
         when r.estatus = 'PAGADO' then 'PAGADO'
         when current_date > r.fecha_limite_pago then 'VENCIDO_SIN_GRACIA'
         when current_date > r.fecha_vencimiento then 'EN_GRACIA'
         else 'POR_VENCER'
       end as semaforo
from recibos r
join polizas p on p.id = r.poliza_id
join contactos c on c.id = p.contratante_id
where r.estatus <> 'CANCELADO';

create or replace view v_kpis_cartera as
select tenant_id,
       count(*) filter (where estatus = 'VIGENTE')                       as polizas_vigentes,
       sum(prima_total) filter (where estatus = 'VIGENTE')               as prima_vigente,
       count(distinct contratante_id) filter (where estatus = 'VIGENTE') as clientes_activos,
       count(*) filter (where estatus = 'CANCELADA' and updated_at > now() - interval '12 months') as canceladas_12m
from polizas group by tenant_id;
