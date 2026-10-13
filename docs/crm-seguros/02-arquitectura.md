# 02 · Arquitectura

## 1. Vista general

```
┌──────────────── Canales de entrada ────────────────┐      ┌──────── Usuarios ────────┐
│ Gmail de la agente (correos de aseguradoras)       │      │ Agente (PWA móvil/web)   │
│ WhatsApp de la agente (coexistencia Cloud API)     │      │ Asistente (opcional)     │
│ Carga manual (PDF, Excel, fotos)                   │      │ Tú (admin / soporte)     │
│ Portales de aseguradoras (Fase 3, RPA acotado)     │      └───────────┬──────────────┘
└───────────────┬────────────────────────────────────┘                  │ HTTPS + JWT
                │ webhooks / polling                                     ▼
        ┌───────▼─────────┐   service_role   ┌────────────────────────────────────────┐
        │   n8n (VPS)     │─────────────────▶│ Supabase: Postgres + RLS + Auth +       │
        │ 20 workflows    │◀─────────────────│ Storage + pgvector + Realtime + Edge Fn │
        └───┬──────┬──────┘  DB webhooks     └────────────────────────────────────────┘
            │      │                                           ▲
            │      ├──▶ Claude API (Haiku 5.5 / Sonnet 5.5)    │ anon key + RLS
            │      ├──▶ WhatsApp Cloud API (vía Kapso/BSP)     │
            │      ├──▶ Resend (email)                  ┌──────┴────────────────────┐
            │      ├──▶ SAT Descarga Masiva (FIEL)      │ App Next.js (PWA)         │
            │      └──▶ Voyage/OpenAI embeddings        │ Cloudflare Pages/Workers  │
            └──▶ Cloudflare R2 (respaldos cifrados)     └───────────────────────────┘
```

## 2. Componentes y decisiones

| Componente | Elección | Por qué | Alternativa descartada |
|---|---|---|---|
| Base de datos, auth, archivos | **Supabase** (Free → Pro) | Postgres con RLS nativa, Auth, Storage, pgvector, Realtime, Database Webhooks; multi-tenant sin esfuerzo; Pro a USD 25 cuando haga falta | Firebase (sin SQL ni RLS relacional); Postgres self-host (más ops) |
| Orquestación | **n8n Community self-host** en VPS (Hetzner/DigitalOcean) con Docker Compose | Ya lo dominas; nodos nativos de Gmail, WhatsApp, Supabase, Anthropic; licencia SUL permite uso interno; coste USD 10–12/mes | n8n Cloud (2,500 ejecuciones se quedan cortas; EUR 20–50/mes) |
| Frontend | **Next.js 15 + TypeScript + Tailwind + shadcn/ui**, PWA, desplegado en **Cloudflare Pages/Workers** (OpenNext) | Código propio generado con IA; PWA instalable; Cloudflare permite uso comercial gratis; Vercel Hobby lo prohíbe | Refine (válido si prefieres scaffolding CRUD); Twenty/EspoCRM (modelo de ventas, AGPL, schema propio); Appsmith/ToolJet (móvil pobre) |
| Admin temporal | **Supabase Studio** (día 1) y opcionalmente **Directus** sobre la misma BD | Ver/editar tablas sin escribir UI mientras se construye la PWA | NocoDB (licencia SUL; bien interno, no para clientes) |
| IA documental | **Claude Haiku 5.5** (clasificación + extracción con `output_config.format`) con escalado a **Sonnet 5.5**; Batch API para históricos | PDF nativo, salidas estructuradas, caché; < USD 1/mes al volumen de ella; no retiene datos por defecto y permite BAA | OCR dedicado (Mistral/Vision) solo como fallback para fotos |
| Asistente WhatsApp | Haiku 5.5 con RAG (pgvector, búsqueda híbrida en español) y escalado a Sonnet en preguntas de cobertura | ≈ USD 1–3/mes; citas obligatorias; handoff | Flowise (archivado ago-2026); Dify (pesado) |
| Bandeja humana | Fase 1: la app de WhatsApp Business de la agente + `conversaciones.modo`; Fase 2: **Chatwoot** (MIT) si hace falta bandeja compartida | Mínimo viable primero; Chatwoot añade app móvil de bandeja, asignación y handoff formal | Front propio de chat (caro de mantener) |
| WhatsApp | **Cloud API vía coexistencia** con **Kapso** (Free) o YCloud; contingencia: segundo número directo en Meta | Conserva la app del teléfono y el historial; 0 % de margen; plantillas utility ≈ MXN 0.16 | Twilio (sin coexistencia); Evolution/Baileys (riesgo de baneo) |
| Email saliente | **Resend** Free (3,000/mes, 100/día) | PDFs de pólizas y avisos de respaldo | SES (más burocracia) |
| Archivos | Supabase Storage (buckets privados, URLs firmadas) + **Cloudflare R2** para respaldos y archivo frío | R2: 10 GB gratis y egress cero | Backblaze B2 |
| Respaldos | `pg_dump` diario cifrado con `age` → R2; `rclone` semanal del bucket de documentos; heartbeat en Better Stack | Supabase Free no tiene respaldos usables | PITR (USD 100+/mes) |
| Secretos | Credenciales de n8n (cifradas) + **Bitwarden** (bóveda compartida agente↔tú) para portales | Nunca en la BD | |
| Acceso al editor n8n | **Cloudflare Tunnel + Access** (login Google) | Sin puertos abiertos, MFA gratis | Exponer n8n directo |
| Observabilidad | Sentry Free (app), Better Stack Free (uptime + heartbeats), tabla `auditoria` | Suficiente para 1 tenant | |
| Dominio | `.com` en Cloudflare Registrar (≈ USD 10/año) | Al costo | `.mx` (3–4× más caro) solo por marca |

## 3. Seguridad por capas

1. **Postgres RLS** como única frontera de datos: la app usa `anon` key + JWT; n8n usa `service_role` y filtra `tenant_id` en cada query.
2. **Auth**: Supabase Auth con email + contraseña y **MFA TOTP obligatorio** para el rol `owner`; magic link para asistentes; sesiones de 7 días en móvil.
3. **Storage**: buckets privados; URLs firmadas de 10 minutos; carpeta por tenant; política RLS en `storage.objects`.
4. **Secretos**: `.env` solo en el VPS; rotación de tokens de WhatsApp cada 60 días; Bitwarden para portales.
5. **Red**: VPS con firewall (solo 80/443 vía Tunnel, SSH por llave y Tailscale opcional), Fail2ban, actualizaciones automáticas.
6. **Datos sensibles (salud)**: columna `datos_ramo` de GMM nunca sale al LLM salvo la carátula; chunks del RAG pre-redactados; organización de Anthropic dedicada con BAA.
7. **Auditoría append-only** y exportación de evidencia (consentimientos, acuses de WhatsApp).
8. **Respaldos cifrados** en otra cuenta/proveedor; prueba de restauración trimestral.

## 4. Entornos y repositorio

```
crm-seguros/                      (monorepo)
├── apps/web/                     Next.js PWA
├── supabase/
│   ├── migrations/               0001_inicial.sql (= anexos/schema.sql) ...
│   ├── seed/                     aseguradoras.sql, productos.sql, plantillas.sql
│   └── functions/                Edge Functions (export de tenant, firma de URLs)
├── n8n/
│   ├── workflows/                WF-00 … WF-20 en JSON (exportados)
│   ├── prompts/                  por aseguradora y tipo de documento
│   └── schemas/                  JSON Schema por (tipo_documento, ramo)
├── infra/
│   ├── docker-compose.yml        n8n + caddy (+ chatwoot en fase 2)
│   ├── backup.sh                 pg_dump + age + rclone
│   └── cloudflared/              túnel
└── docs/                         este plan
```

Entornos: `dev` (Supabase proyecto 1 + n8n local con Docker) y `prod` (Supabase proyecto 2 + VPS). El plan Free permite 2 proyectos activos. Migraciones con Supabase CLI; workflows de n8n exportados a JSON en cada cambio (hay nodo/CLI para hacerlo automático).

## 5. Flujo de datos de una póliza, de punta a punta

1. GNP emite la póliza de GMM de María y manda el PDF al correo de la agente.
2. Gmail etiqueta el correo; WF-01 lo detecta, calcula el hash, sube el PDF a Storage e inserta `documentos`.
3. WF-03 clasifica (GNP, carátula, GMM) y extrae el JSON con confianza por campo; valida RFC, CP, sumas; encuentra a María por RFC.
4. La agente recibe en WhatsApp: "Llegó la póliza GM-998877 de GNP para María García, mensual, prima 49,200. Revisar →". Abre la PWA, ve el PDF a la izquierda y los campos a la derecha, corrige el deducible, aprueba.
5. WF-04 crea la póliza, 12 recibos, 12 comisiones esperadas y los envíos programados (−30, −15, −7, 0 días de cada recibo; −30/−15/−7 de la renovación).
6. María recibe por WhatsApp la plantilla "Tu póliza quedó emitida" con el PDF.
7. Cada 08:00, WF-05 revisa qué toca hoy. Siete días antes del recibo 2, María recibe el recordatorio. Si responde "¿cuánto es?", WF-08/09 contestan con el importe exacto de su recibo y la referencia de pago, y citan la póliza.
8. A fin de mes llega el estado de cuenta de comisiones de GNP; WF-10 lo cruza: 11 recibos coinciden, uno tiene diferencia; la agente ve la diferencia en el tablero y la reclama.
9. Todo quedó en `auditoria`; si María ejerce ARCO, el módulo genera el acuse y cuenta los 20 días.
