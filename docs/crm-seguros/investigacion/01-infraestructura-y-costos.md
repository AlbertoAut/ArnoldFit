# Investigación · Infraestructura y costos de herramientas

**Fecha de consulta de todos los precios: 2026-10-13.** Tipo de cambio usado: 1 USD ≈ 18.3 MXN (promedio eldolar.info 11-oct-2026; FIX Banxico 9-oct = 18.4163). Recalcular con el FIX del día.

> Limitación metodológica: las páginas oficiales no pudieron abrirse directamente desde el entorno de investigación; las cifras provienen de resultados de búsqueda (snippets de páginas oficiales y fuentes secundarias de 2026). Lo marcado **[VERIFICAR]** debe confirmarse abriendo el enlace antes de comprometer presupuesto (≈15 minutos).

## 1. Supabase

| Concepto | Free | Pro (USD 25/mes) | Fuente |
|---|---|---|---|
| Base de datos | 500 MB por proyecto activo | 8 GB incluidos; excedente ≈ USD 0.125/GB | https://supabase.com/pricing |
| File Storage | 1 GB | 100 GB; excedente USD 0.0213/GB | https://supabase.com/docs/pricing |
| Egress | 5 GB sin caché + 5 GB con caché | 250 GB; excedente USD 0.09/GB | https://supabase.com/docs/guides/platform/manage-your-usage/egress |
| MAU (Auth) | 50,000 | 100,000 | https://supabase.com/pricing |
| Edge Functions | 500K invocaciones/mes | 2M | https://supabase.com/docs/guides/platform/org-based-billing |
| Proyectos | 2 activos | ilimitados | https://supabase.com/changelog?types=policy |
| Pausa por inactividad | **Sí, tras 1 semana sin actividad** | No | https://supabase.com/pricing |
| Backups | Sin retención usable para el usuario; recomiendan `supabase db dump` | Diarios, 7 días | https://supabase.com/docs/guides/platform/backups |
| PITR | No | Add-on, 7 días ≈ USD 100/mes [VERIFICAR] | https://supabase.com/docs/guides/platform/manage-your-usage/point-in-time-recovery |
| Compute | Nano/Micro compartido | Crédito USD 10 = Micro (1 GB); Small ≈ USD 15; Medium ≈ USD 60 | https://supabase.com/docs/guides/platform/compute-and-disk |
| Dominio personalizado | No | USD 10/mes | https://supabase.com/pricing |
| pgvector | Disponible en todos los planes (extensión estándar) | — | docs de extensiones |

**¿Free viable para una herramienta interna de un agente?** Sí, con dos mitigaciones: (1) un cron de n8n que haga una consulta diaria evita la pausa (con WhatsApp entrando a diario no habrá inactividad real); (2) `pg_dump` nocturno a Cloudflare R2 porque Free no tiene respaldos usables. 150 clientes caben de sobra en 500 MB; los PDFs van a Storage (1 GB) o a R2 (10 GB gratis).

**Cuándo saltar a Pro (USD 25 ≈ MXN 460):** cuando la agente dependa del sistema a diario, se necesiten respaldos gestionados, >500 MB, o entre el segundo tenant.

## 2. n8n

### 2a. n8n Cloud (EUR, facturación anual; mensual ≈ +20 %)

| Plan | Precio | Ejecuciones/mes | Notas |
|---|---|---|---|
| Starter | €20/mes anual (≈ €24 mensual) | 2,500 | workflows activos ilimitados |
| Pro | €50/mes anual (≈ €60 mensual) | 10,000 | 3 proyectos |

Fuente: https://n8n.io/pricing/ ; https://community.n8n.io/t/new-plan-no-active-workflow-limits-introducing-n8n-new-pricing/163840

Riesgo: 1 ejecución = 1 corrida de workflow. Con webhooks de estado de WhatsApp, recordatorios, OCR y crons, 150 clientes superan 2,500 ejecuciones/mes con facilidad. Pro ya cuesta más que un VPS de 4 GB.

### 2b. Licencia Sustainable Use License (self-host)

Fuentes: https://docs.n8n.io/sustainable-use-license/ ; https://docs.n8n.io/n8n-community-license/community-license/license-faq

- **Uso interno de negocio: permitido**, incluso si las salidas (mensajes) llegan a terceros.
- **Construir workflows para clientes en tu instancia: permitido** si los clientes no crean ni editan workflows.
- **Ofrecer n8n como servicio donde los clientes acceden al editor: no permitido** sin licencia de embed.
- **Zona gris para el SaaS futuro:** si n8n corre tras bambalinas y los tenants nunca lo ven, la FAQ lo describe como permitido, pero el criterio es "si el valor principal del producto proviene de n8n, necesitas licencia de embed". Recomendación: escribir a license@n8n.io al llegar a la fase SaaS y mantener la lógica de negocio fuera de n8n (Postgres, Edge Functions) para que sea reemplazable.

### 2c. Self-hosting (n8n necesita ≈2 GB RAM mínimo; 4 GB recomendado con PDFs/IA)

| Proveedor | Plan | Specs | Precio/mes | Notas |
|---|---|---|---|---|
| **Hetzner Cloud** (EU) | CX23 | 2 vCPU, 4 GB, 40 GB | €5.49 + €0.50 IPv4 ≈ €6 (≈ USD 7) tras alza del 15-jun-2026 | https://docs.hetzner.com/general/infrastructure-and-availability/price-adjustment/ ; [VERIFICAR] reportes de falta de stock de la línea CX (ago-2026). EU ≈ 130–160 ms desde CDMX |
| Hetzner Cloud | CX33 | 4 vCPU, 8 GB, 80 GB | €8.49 + €0.50 ≈ €9 (≈ USD 10.5) | misma fuente |
| Hetzner Ashburn | CPX11 | 2 vCPU, 2 GB | reportado USD 20.49 [VERIFICAR, parece anómalo] | |
| **DigitalOcean** (NYC) | Basic | 1 vCPU, 2 GB, 50 GB | USD 12 (4 GB = USD 24) | https://www.digitalocean.com/pricing/droplets ; NYC ≈ 50–70 ms a CDMX |
| **Railway** | Hobby | medido | USD 5 suscripción + uso; n8n con 1 GB ≈ USD 10–15 total | https://docs.railway.com/reference/pricing/plans |
| **Render** | Starter | 512 MB | USD 7 | Free se duerme a los 15 min (inútil para webhooks) |
| **Fly.io** | shared-cpu-1x 1–2 GB | — | ≈ USD 5–11 + volumen | Sin free tier; región Querétaro [VERIFICAR] |
| **Oracle Cloud Always Free** | Ampere A1 | **2 OCPU / 12 GB desde 15-jun-2026** (antes 4/24) | USD 0 | https://docs.oracle.com/en-us/iaas/Content/FreeTier/resourceref.htm ; riesgo de "out of capacity" y reclamo de instancias con CPU p95 <20 % durante 7 días |
| **Coolify / Dokploy** | PaaS sobre tu VPS | — | USD 0 | Coolify usa 0.5–1.2 GB RAM; Dokploy ≈350 MB con backup a S3 nativo |

**Recomendación n8n:** self-host en VPS de 4–8 GB con Docker Compose (n8n + Caddy/Traefik). Opción A: Hetzner CX33 ≈ USD 10.5 ≈ MXN 190/mes si hay stock. Opción B: DigitalOcean 2 GB NYC USD 12 ≈ MXN 220.

## 3. Hosting del frontend

| Opción | Costo | ¿Uso comercial? | Notas |
|---|---|---|---|
| **Vercel Hobby** | 0 | **No.** "All commercial usage requires Pro"; un CRM de un negocio construido a cambio de pago es comercial. Pro = USD 20/mes | https://vercel.com/docs/limits/fair-use-guidelines |
| **Cloudflare Pages / Workers** | 0 | Sí en la práctica [VERIFICAR términos] | 500 builds/mes; Workers free 100K req/día; Next.js vía OpenNext | https://developers.cloudflare.com/pages/platform/limits |
| **Netlify Free** | 0 | Terceros dicen sí [VERIFICAR] | 300 créditos/mes con tope duro; pausan sitios al agotarse | https://www.netlify.com/pricing/ |
| **Self-host en el VPS** | 0 marginal | Sí | Next.js en Docker detrás de Caddy |

**Recomendación:** Cloudflare Pages/Workers + Cloudflare DNS; Vercel Pro cuando el SaaS lo pague; self-host como plan B.

## 4. Low-code / open source para la UI

| Herramienta | Licencia | Comercial interno | Revender SaaS | Supabase directo | Móvil | Esfuerzo CRM seguros |
|---|---|---|---|---|---|---|
| Twenty CRM | AGPL-3.0 (+ paquete enterprise) | Sí | Sí publicando cambios; multi-workspace nativo | No (schema propio + Redis; ≈1.2 GB RAM) | Web responsiva | Bajo arranque, medio para pólizas |
| EspoCRM | AGPLv3 | Sí | Sí publicando cambios | PHP/MySQL (Postgres [VERIFICAR]); schema propio | Aceptable | Bajo (Entity Manager) |
| SuiteCRM 8 | AGPLv3 | Sí | Sí | MySQL solo; pesado | Pobre | Alto. No recomendado |
| Odoo Community | LGPLv3 | Sí | Sí | Postgres pero schema propio; 2–4 GB | Regular | Alto (ERP) |
| NocoDB | **SUL desde 9-ene-2026** | Sí (interno) | No sin licencia comercial | Sí (Postgres externo) | Básico | Muy bajo como admin |
| Baserow | MIT núcleo | Sí | Sí | No como fuente primaria | Aceptable | Bajo como admin |
| Appsmith | Apache 2.0 | Sí | Sí | Sí | Débil | Bajo paneles |
| ToolJet | AGPL-3.0 | Sí | Con AGPL | Sí | Mediocre | Similar |
| Budibase | GPLv3 | Sí | Revisar límites usuarios | Sí | Razonable | Bajo-medio |
| **Refine** (React) | MIT [VERIFICAR] | Sí | Sí | **Sí, `@refinedev/supabase`** | Lo que construyas; PWA | Medio |
| Directus | BSL 1.1 / MSCL (<USD 5M ingresos) | Sí | Sí bajo umbral | **Sí, documentado con Supabase** | Decente | Muy bajo como back-office |
| Softr (SaaS) | Propietario | Sí | Pagando | Conector Supabase [VERIFICAR] | Buena | Free limitado; Basic USD 49–59 |
| Glide (SaaS) | Propietario | Sí | Limitado | SQL solo planes altos | Excelente | Explorer ≈ USD 19/mes |

Fuentes: https://github.com/twentyhq/twenty ; https://www.espocrm.com/blog/espocrm-license/ ; https://nocodb.com/docs/self-hosting/license ; https://refine.dev/core/docs/data/packages/supabase/ ; https://directus.com/docs/guides/integrations/supabase/connect-supabase-postgres-to-directus ; https://github.com/appsmithorg/appsmith

**Opinión:** camino custom (Next.js/Refine + Supabase) con Directus o NocoDB como admin temporal el día 1. Razones: el modelo de datos es de seguros, no de ventas; WhatsApp es el canal principal; multi-tenant con `tenant_id` + RLS es trivial en schema propio; móvil (PWA) a medida; cero licencias en fase SaaS; las herramientas de IA generan CRUD + auth + RLS muy bien, el riesgo real es disciplina de seguridad (revisar cada policy, nunca exponer la service key).

## 5. Servicios auxiliares

| Servicio | Free tier / precio | Fuente | Notas |
|---|---|---|---|
| Resend | 3,000/mes, tope 100/día, 1 dominio; Pro USD 20 | https://resend.com/pricing | Suficiente para avisos por email |
| Amazon SES | USD 0.10/1,000; nuevos planes jul-2026 (Essentials 0.16/1,000) | https://aws.amazon.com/about-aws/whats-new/2026/07/amazon-ses-pricing-plans/ | Más burocracia |
| Brevo | 300 emails/día | https://www.brevo.com/pricing/ | SMTP + marketing |
| Supabase Storage | 1 GB free; Pro 100 GB | https://supabase.com/docs/pricing | RLS integrada, egress caro |
| **Cloudflare R2** | **10 GB free; USD 0.015/GB; egress USD 0** | https://developers.cloudflare.com/r2/pricing/ | Mejor para PDFs y backups; API S3 |
| Backblaze B2 | USD 6/TB/mes [VERIFICAR] | https://www.backblaze.com/cloud-storage/pricing | R2 gana por free tier |
| Dominio .com | Cloudflare Registrar ≈ USD 10.46/año | https://domainoffer.net/tld/com/cloudflare | ≈ MXN 16/mes |
| Dominio .com.mx | ≈ MXN 139–390/año; .mx ≈ USD 36–48/año | https://www.ovhcloud.com/es-es/domains/tld/mx/ | Solo si la marca lo quiere |
| Cloudflare DNS / Tunnel / Access | Gratis hasta 50 usuarios | https://blog.cloudflare.com/teams-plans | Exponer n8n sin abrir puertos y poner login Google delante del editor |
| UptimeRobot | 50 monitores a 5 min; uso comercial permitido | https://uptimerobot.com/terms | |
| Better Stack | 10 monitores, 10 heartbeats | https://betterstack.com/ | Heartbeats para vigilar el backup |
| Sentry | Developer: 5,000 errores/mes | https://sentry.io/pricing | |
| Metabase OSS | AGPL, gratis self-host; ≈1–2 GB RAM | https://coefficient.io/metabase-pricing | Solo si se quiere explorar datos |
| Bitwarden | Free ilimitado; Premium USD 10/año; Organizations gratis 2 usuarios | https://bitwarden.com/pricing | Credenciales de portales; nunca en la BD |
| Google Workspace | Business Starter MXN 140/usuario/mes anual | https://knowledge.workspace.google.com/admin/billing/compare-flexible-and-annual-fixed-term-payment-plans?hl=es-419 | Gmail gratis sirve |

## 6. Costo mensual consolidado

Rubros variables comunes: WhatsApp Cloud API (ver informe 02) ≈ USD 2–8/mes; LLM extracción ≈ USD 1–5/mes.

### (a) Cero dólares
Supabase Free + n8n en Oracle Always Free (o Railway trial) + Cloudflare Pages + R2 + Resend + Bitwarden + Gmail. **≈ USD 4–9/mes (MXN 70–165)**, casi todo WhatsApp/LLM y el dominio. Riesgos: Oracle puede reclamar la instancia, sin respaldos gestionados, Supabase se pausa si falla el cron. Aceptable para piloto de 1–2 meses.

### (b) Lean recomendado
| Rubro | Elección | USD/mes | MXN/mes |
|---|---|---|---|
| BD + Auth | Supabase Free (+ pg_dump diario a R2) | 0 | 0 |
| n8n (+ Directus/NocoDB opcional) | VPS Hetzner CX33 8 GB o DigitalOcean 2 GB | 10.5–12 | 192–220 |
| Frontend | Cloudflare Pages Free | 0 | 0 |
| Archivos + backups | Cloudflare R2 Free | 0 | 0 |
| Email | Resend Free | 0 | 0 |
| Dominio | .com Cloudflare | 0.87 | 16 |
| Acceso seguro a n8n | Cloudflare Tunnel + Access | 0 | 0 |
| Monitoreo / errores | Better Stack Free + Sentry Free | 0 | 0 |
| Contraseñas | Bitwarden Premium | 0.83 | 15 |
| WhatsApp Cloud API | variable | 2–8 | 37–146 |
| LLM extracción | variable | 1–5 | 18–92 |
| **Total** | | **≈ USD 16–27** | **≈ MXN 290–500** |

Variante lean+: Supabase Pro (USD 25) → total ≈ USD 41–52 (MXN 750–950).

### (c) Cómodo
Supabase Pro (25–30) + VPS 4–8 GB con Coolify o n8n Cloud Starter (19–28) + Vercel Pro opcional (0–20) + R2 + Resend/Brevo (0–9) + dominios (2) + Bitwarden Families/Teams (3–8) + Google Workspace (7.7–9.2) + WhatsApp (5–10) + LLM (3–10). **≈ USD 65–127 (MXN 1,190–2,320).**

## 7. Banderas rojas
1. No usar Vercel Hobby: el proyecto es comercial según su propia definición.
2. n8n Community es legal para esto; para la fase SaaS, escribir a license@n8n.io y mantener la lógica de negocio fuera de n8n.
3. Oracle Always Free se degradó en 2026: solo para probar.
4. Hetzner subió precios el 15-jun-2026 y hay reportes de falta de stock CX; verificar.
5. NocoDB ya no es AGPL (SUL desde ene-2026): bien para interno, no para clientes.
6. Supabase Free no tiene backups usables: el `pg_dump` nocturno no es opcional.
7. Tarifas de WhatsApp cambiaron el 1-oct-2026 (ver informe 02).
