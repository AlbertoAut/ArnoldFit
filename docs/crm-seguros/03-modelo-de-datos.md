# 03 · Modelo de datos

El esquema completo y ejecutable está en [`anexos/schema.sql`](anexos/schema.sql). Este documento explica las decisiones.

## Decisiones estructurales

**Multi-tenant desde el primer `CREATE TABLE`.** Toda tabla de negocio lleva `tenant_id`. Hoy habrá un solo registro en `tenants`. Cuando el producto se venda a otros agentes no habrá migración: se crea otro tenant, otro usuario con `app_metadata.tenant_id`, y las políticas RLS hacen el resto. Es la decisión más barata que se puede tomar hoy y la más cara de tomar después.

**RLS como única frontera de seguridad.** La app usa la `anon` key + JWT del usuario; Postgres filtra. n8n usa `service_role` y por eso cada query en n8n filtra tenant explícitamente. Para la fase SaaS se agregará un test automatizado que intenta leer datos de otro tenant con cada rol y debe fallar.

**Una póliza por vigencia.** La renovación crea un registro nuevo con `numero_renovacion + 1` y `poliza_anterior_id`. Así la historia queda íntegra, las comisiones de cada año se separan y el KPI de conservación se calcula contando cadenas con continuidad.

**Recibos como unidad de cobranza y de comisión.** En México la comisión se devenga cuando el recibo se paga, no cuando la póliza se emite. Por eso `comisiones` cuelga de `recibos`. Un recibo tiene `fecha_vencimiento` y `fecha_limite_pago` (vencimiento + periodo de gracia, 30 días por defecto según la Ley sobre el Contrato de Seguro). Los recordatorios de cobranza se calculan contra ambas fechas.

**`datos_ramo` en jsonb.** Lo que cambia por ramo (vehículo, deducibles de GMM, giro de un negocio, fiado de una fianza) va en jsonb validado por un JSON Schema por ramo en la aplicación. Lo que es común a todos (primas, vigencias, forma de pago, contratante) va en columnas. Esto evita 6 tablas de pólizas distintas y sigue permitiendo consultas (`datos_ramo->>'placas'`).

**`asegurados` cubre incisos, dependientes y beneficiarios.** Un vehículo de una flotilla, el hijo de un asegurado de GMM y el beneficiario de una póliza de vida son todos "personas u objetos protegidos por la póliza con un rol". Se modelan en una sola tabla con `rol` y `datos` jsonb.

**Documentos con hash.** `documentos.sha256` es único por tenant. El mismo PDF que llega por correo y luego por WhatsApp no se duplica ni se vuelve a mandar a la IA.

**Auditoría append-only.** Trigger en las tablas con datos personales o dinero. Se revocan `UPDATE/DELETE` a los roles de la app. Esto es lo que se enseña en una revisión de cumplimiento o en una disputa con una aseguradora.

**Consentimientos y ARCO como tablas de primera clase.** No basta con un checkbox. Se guarda qué versión del aviso, por qué canal, cuándo y con qué evidencia (por ejemplo el `wamid` del mensaje donde el cliente respondió "Acepto").

**Credenciales de portales fuera de la BD.** `claves_agente.credencial_ref` solo guarda el nombre de la credencial. La contraseña del portal de GNP vive en el gestor de credenciales de n8n (cifrado) o en Bitwarden. Si algún día la BD se filtra, no se filtran los accesos a las aseguradoras.

## Diagrama de entidades (resumen)

```
tenants ─┬─ perfiles ─── cedulas
         ├─ claves_agente ──────────────┐
         ├─ contactos ─┬─ consentimientos│
         │             ├─ oportunidades ── cotizaciones
         │             ├─ conversaciones ── mensajes
         │             └─ polizas ─┬─ asegurados
         │                 (aseguradora, producto, clave_agente)
         │                         ├─ endosos
         │                         ├─ recibos ── comisiones ── estados_cuenta_comisiones
         │                         └─ siniestros
         ├─ actividades (→ contacto | póliza | siniestro | oportunidad)
         ├─ documentos (→ contacto | póliza | recibo | siniestro) ── documento_chunks (vector)
         ├─ plantillas_mensaje ── reglas_recordatorio ── envios_programados
         ├─ solicitudes_arco
         └─ auditoria
catálogos globales: aseguradoras, productos
```

## JSON Schemas por ramo (campos de `datos_ramo`)

| Ramo | Campos mínimos en `datos_ramo` |
|------|-------------------------------|
| AUTOS | `paquete` (Amplia/Limitada/RC), `marca`, `submarca`, `modelo`, `serie_vin`, `placas`, `color`, `tipo_uso`, `deducible_danos_pct`, `deducible_robo_pct`, `suma_rc`, `gastos_medicos_ocupantes`, `asistencia_vial` |
| VIDA | `plan` (temporal/ordinario/dotal/inversión), `suma_asegurada_basica`, `coberturas_adicionales[]` (BIT, invalidez, muerte accidental), `plazo_pago`, `plazo_seguro`, `fumador`, `moneda_udi` |
| GMM | `plan`, `suma_asegurada`, `deducible`, `coaseguro_pct`, `tope_coaseguro`, `nivel_hospitalario`, `zona_tarifa`, `antiguedad_desde`, `preexistencias_declaradas`, `emergencia_extranjero` |
| ACCIDENTES | `suma_asegurada`, `reembolso_gastos_medicos`, `actividad` |
| DANOS (hogar) | `tipo_inmueble`, `valor_construccion`, `valor_contenidos`, `coberturas[]` (incendio, hidro, robo, RC), `deducibles` |
| EMPRESARIAL | `giro`, `ubicaciones[]`, `secciones[]` (incendio, RC, robo, equipo electrónico, transporte), `sumas_por_seccion` |
| FIANZAS | `tipo_fianza` (fidelidad, judicial, administrativa, crédito), `fiado`, `beneficiario`, `monto_afianzado`, `obligacion_garantizada`, `vigencia_contrato` |

## Catálogo inicial de aseguradoras (semilla)

Se cargan las 6+ con las que trabaja la agente y las más comunes del mercado: Quálitas, GNP, AXA, HDI, MetLife, Seguros Monterrey New York Life, Mapfre, Chubb, Zurich, Allianz, Banorte, Inbursa, Atlas, SURA, Plan Seguro, Bupa, General de Seguros, ANA, El Potosí, Afirme, Sofimex, Aserta, Afianzadora Insurgentes. Cada una con sus dominios de correo (para WF-01) y teléfonos de cabina/siniestros (para el asistente).

## Validación realizada

El esquema se ejecutó completo en PostgreSQL 16 (con stubs del esquema `auth` de Supabase y de pgvector) y se probó con datos de dos tenants: columnas generadas, fecha límite de pago (vencimiento + 30 días), vistas `v_renovaciones_proximas` y `v_cobranza`, triggers de auditoría y aislamiento RLS (un usuario del tenant B no ve contactos, pólizas ni recibos del tenant A). Dos lecciones que quedaron incorporadas:

1. Las columnas generadas solo admiten expresiones inmutables; `concat_ws` no lo es, por eso `nombre_completo` usa concatenación con `||` y `regexp_replace`.
2. `current_tenant_id()` debe ser `security definer`: lee `perfiles`, cuya política RLS invoca a la misma función; sin definer se produce recursión infinita ("stack depth limit exceeded"). Es el error más común al implementar multi-tenant en Supabase y conviene cubrirlo con un test automatizado en CI.

## Migraciones

Supabase CLI (`supabase migration new`, `supabase db push`). El `schema.sql` del anexo es la migración `0001_inicial`. Toda modificación posterior es una migración nueva; nunca se edita la BD a mano en producción.
