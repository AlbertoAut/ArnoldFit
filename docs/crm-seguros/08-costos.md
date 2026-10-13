# 08 · Costos

Tipo de cambio de referencia: **1 USD ≈ 18.3 MXN** (oct-2026). Todos los precios tienen fecha 2026-10-13 y fuente en `investigacion/`; los marcados ⚠️ no se pudieron confirmar en página oficial y deben verificarse antes de comprometerse.

## 1. Costo mensual recurrente

### Escenario recomendado ("lean"): ≈ USD 16–27 ≈ MXN 290–500 al mes

| Rubro | Elección | USD/mes | MXN/mes |
|---|---|---|---|
| Base de datos, auth, storage | Supabase Free (+ `pg_dump` diario a R2) | 0 | 0 |
| n8n (+ Directus opcional) | VPS 4–8 GB: Hetzner CX33 ≈ €9 ⚠️ stock, o DigitalOcean 2 GB NYC USD 12 | 10.5–12 | 192–220 |
| Frontend PWA | Cloudflare Pages/Workers Free | 0 | 0 |
| Respaldos y archivo | Cloudflare R2 Free (10 GB) | 0 | 0 |
| Email | Resend Free | 0 | 0 |
| Dominio `.com` | Cloudflare Registrar ≈ USD 10.46/año | 0.87 | 16 |
| Acceso seguro a n8n | Cloudflare Tunnel + Access Free | 0 | 0 |
| Monitoreo y errores | Better Stack Free + Sentry Free | 0 | 0 |
| Contraseñas | Bitwarden Premium USD 10/año | 0.83 | 15 |
| WhatsApp Cloud API | Kapso Free + Meta ≈ 300 utility + 30 marketing ⚠️ | 3.5–8 | 65–146 |
| IA (Claude Haiku/Sonnet, embeddings, voz) | ≈ 60 documentos + 200 conversaciones | 1–5 | 18–92 |
| **Total** | | **≈ 16–27** | **≈ 290–500** |

### Cero dólares (piloto 1–2 meses): ≈ USD 4–9 ≈ MXN 70–165
Igual que lean pero n8n en Oracle Cloud Always Free (ARM, 2 OCPU/12 GB desde jun-2026; riesgo de reclamo por inactividad y falta de capacidad). Solo para probar; no para que ella dependa de él.

### Cómodo: ≈ USD 65–127 ≈ MXN 1,190–2,320
Supabase Pro (USD 25, respaldos de 7 días, sin pausa), VPS de 8 GB con Coolify o n8n Cloud Starter, Vercel Pro opcional, Google Workspace para la agente, Bitwarden Families, `.com.mx` de marca. Es el escenario natural cuando entre el segundo tenant.

### Cuándo subir de escenario
- Supabase Free → Pro (+USD 25): cuando ella dependa del sistema a diario (recomendado al go-live del MVP, semana 8) o al llegar a 400 MB.
- Kapso Free → Pro (+USD 25): arriba de 2,000 mensajes/mes totales.
- Añadir Chatwoot: si entra una asistente o ella quiere bandeja compartida (+0 USD, +1 GB RAM).

## 2. Costos únicos (setup)

| Concepto | MXN | Nota |
|---|---|---|
| Dominio primer año | ≈ 190 | `.com` |
| eSIM/línea secundaria (solo contingencia WhatsApp) | 0–200/mes | Si la coexistencia no es elegible |
| Revisión legal del aviso de privacidad y flujo de consentimiento | 3,000–8,000 | Recomendado antes del go-live |
| Hora de contador para parametrizar retenciones por aseguradora | 500–1,500 | |
| Hardware | 0 | Su celular + tu equipo |
| **Total único** | **≈ 3,700–10,000** | La parte legal es opcional pero prudente |

## 3. Tu tiempo (el costo real)

Estimación para un constructor solo con experiencia en n8n y Supabase, usando asistentes de código IA para el frontend:

| Fase | Semanas | Horas estimadas |
|---|---|---|
| 0 Preparación y cuentas | 1 | 10–15 |
| 1 MVP núcleo (datos, importación, ingesta por correo, IA, recordatorios, PWA básica) | 2–8 | 120–160 |
| 2 Cobranza avanzada, comisiones, asistente IA, siniestros | 9–14 | 80–110 |
| 3 Pilotos: RPA acotado, multicotizador, portal de cliente | 15–20 | 60–90 |
| Mantenimiento mensual (prompts, plantillas, actualizaciones) | continuo | 4–8 / mes |

A MXN 400–600 por hora de valor de tu tiempo, el MVP "cuesta" MXN 50,000–100,000 en tiempo. Es el número a comparar contra MXN 8,000/año de SICAS: el proyecto se justifica por el aprendizaje, la soberanía y la opción SaaS, no por ahorro de licencia en el año 1.

## 4. Comparación con comprar (1 agente, por año)

| Opción | MXN/año | Incluye |
|---|---|---|
| Mercadito Software (licencia local) | ≈ 3,700 | Pólizas, cobranza; sin WhatsApp ni IA |
| SICAS Online Corredor | 7,990 | Profundidad contable; sin IA documental |
| Winsef Startup | ⚠️ no verificado (investigación previa: 650/mes ≈ 7,800) | Pólizas, cobranza, conciliación, WhatsApp |
| Softseguros (mínimo 2 usuarios) | ≈ 14,000 | 360, WhatsApp, IA ≥3 usuarios |
| **CRM propio, escenario lean** | **≈ 3,500–6,000** + tu tiempo | Todo lo anterior a tu medida + opción SaaS |

## 5. Proyección fase SaaS (orientativa)

Costo variable por agente activo: IA ≈ USD 3–8 (Haiku-first), WhatsApp ≈ USD 3–5, infraestructura compartida ≈ USD 1–2 → **≈ USD 7–15 por agente/mes**. Un precio de MXN 400–600/agente/mes (USD 22–33) deja margen bruto > 50 % desde el agente 10 y es la mitad de Softseguros. Costos fijos a esa escala: Supabase Pro + compute Small (USD 40), VPS 8 GB (USD 20), Kapso Pro (USD 25), dominio, legal recurrente.
