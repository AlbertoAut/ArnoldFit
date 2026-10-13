# CRM para agente de seguros · Plan maestro

**Para quién:** una agente de seguros independiente en México (≈150 clientes, todos los ramos, 6+ aseguradoras), hoy en Excel y WhatsApp.
**Quién construye:** tú, solo, con experiencia en n8n y WhatsApp Cloud API (ArnoldFit), con asistentes de código IA.
**Restricción:** costo mínimo. **Intención:** convertirlo en SaaS multi-tenant si funciona.
**Fecha del plan:** 13 de octubre de 2026.

## Resumen ejecutivo

1. **Qué se construye.** Un CRM móvil (PWA) sobre Supabase + n8n que: importa su cartera desde Excel; recibe las carátulas, recibos y estados de cuenta que las aseguradoras ya le mandan por correo y los convierte en datos con IA (revisión de un clic); genera recibos y comisiones esperadas; manda recordatorios de cobranza y renovación por WhatsApp oficial sin que ella pierda su número ni su app; concilia comisiones; da seguimiento a siniestros; y cumple la nueva ley de datos personales desde el diseño.
2. **Cuánto cuesta.** Escenario recomendado: **≈ MXN 290–500 al mes** (VPS para n8n, dominio, WhatsApp, IA; Supabase, Cloudflare, Resend y monitoreo en capa gratuita). Subir a Supabase Pro (+USD 25) al go-live. Costos únicos: ≈ MXN 3,700–10,000 (dominio y revisión legal opcional). El costo real es tu tiempo: ≈ 120–160 horas para el MVP.
3. **Cuánto tarda.** MVP útil en **8 semanas**; operación completa (comisiones, asistente IA, siniestros) en 14; pilotos (RPA acotado, multicotizador, portal de cliente, segundo tenant) hasta la 20.
4. **Qué cambió respecto a tu documento.** La LFPDPPP de 2010 fue abrogada (nueva ley desde marzo 2025; el INAI ya no existe); Meta cobra mensajes de servicio desde el 1-oct-2026 (sigue siendo < MXN 100/mes); la coexistencia de WhatsApp permite usar su número actual en la API sin perder la app; ninguna aseguradora mexicana ofrece API abierta a agentes individuales, así que el correo es el canal de integración principal; y el plan **no incluye evasión de CAPTCHA ni scraping agresivo**: el riesgo de bloqueo de su clave de agente no vale la pena.
5. **Comprar vs construir.** Comprar cuesta MXN 3,000–14,000/año (Mercadito, SICAS, Winsef, Softseguros). Construir se justifica por lo que no se vende por separado (ingesta por correo con IA, conciliación de comisiones, WhatsApp integrado), por la soberanía de sus datos y por la opción de SaaS. Exige disciplina de alcance.

## Cómo leer este plan

| Documento | Qué contiene |
|---|---|
| [01 · Análisis y decisión](01-analisis-y-decision.md) | Qué validamos y corregimos de tu comparativa; buy vs build; qué copiar de cada competidor; principios de diseño |
| [02 · Arquitectura](02-arquitectura.md) | Componentes, por qué cada uno, seguridad por capas, repositorio, flujo de punta a punta |
| [03 · Modelo de datos](03-modelo-de-datos.md) + [`anexos/schema.sql`](anexos/schema.sql) | Esquema PostgreSQL multi-tenant con RLS, auditoría, consentimientos, ARCO, vistas operativas |
| [04 · Integraciones](04-integraciones.md) | Gmail, WhatsApp (coexistencia), Supabase, Claude, SAT/CFDI, portales, Chatwoot, Resend, Calendar, catálogos |
| [05 · Automatizaciones n8n](05-automatizaciones-n8n.md) | 20 workflows con disparadores, lógica y reglas de recordatorio |
| [06 · IA](06-ia-extraccion-y-asistente.md) | Pipeline de extracción, esquemas, validaciones, asistente RAG con guardrails, costos |
| [07 · Legal y cumplimiento](07-legal-y-cumplimiento.md) | Normas que aplican, aviso de privacidad, consentimiento, ARCO, fiscal, checklist de go-live |
| [08 · Costos](08-costos.md) | Tres escenarios mensuales, únicos, tu tiempo, comparación con comprar, proyección SaaS |
| [09 · Plan de trabajo](09-plan-de-trabajo.md) | 20 semanas, tareas, entregables y criterios de éxito por fase |
| [10 · Riesgos y SaaS](10-riesgos-y-camino-a-saas.md) | Matriz de riesgos, lo que no se hace, pasos hacia el SaaS |
| [`anexos/`](anexos/) | Plantillas de WhatsApp, checklist para la agente, plantilla de importación Excel, JSON Schema de carátula de autos, prompt clasificador |
| [`investigacion/`](investigacion/) | Seis informes con fuentes y fechas: infraestructura y costos, WhatsApp, aseguradoras, legal, IA, dominio y competencia |

## Decisiones ya tomadas (y por qué)

- **Supabase + n8n self-host + Next.js PWA en Cloudflare**: menor costo, tu experiencia, multi-tenant nativo, sin restricciones de uso comercial.
- **WhatsApp por coexistencia (Kapso/YCloud)**, contingencia con número dedicado; nunca APIs no oficiales.
- **Correo como canal principal de ingesta**; RPA solo como piloto acotado en Fase 3, sin evasión de controles.
- **Claude Haiku 5.5 con salidas estructuradas** y escalado a Sonnet 5.5; revisión humana obligatoria hasta demostrar precisión; organización con BAA por los datos de salud.
- **Cumplimiento desde el esquema**: consentimientos, ARCO, auditoría y bloqueo son tablas, no documentos.

## Lo primero que hay que hacer (esta semana)

1. Sesión de 2 horas con la agente y entregarle `anexos/checklist-agente.md`.
2. Confirmar si su número está en WhatsApp Business App (elegibilidad de coexistencia).
3. Verificar los precios marcados ⚠️ en `08-costos.md` (15 minutos).
4. Crear las cuentas de la Fase 0 y el repositorio.

## Notas sobre la investigación

Los seis informes de `investigacion/` se elaboraron el 13-oct-2026. El entorno de investigación no pudo abrir directamente la mayoría de las páginas oficiales, por lo que muchas cifras provienen de extractos de búsqueda y fuentes secundarias; cada una lleva su URL, fecha y nivel de confianza, y las que no se pudieron confirmar están marcadas (⚠️, [VERIFICAR], ❓, [C]). Ninguna de ellas cambia la arquitectura ni el orden del plan; todas son rubros pequeños (< USD 10/mes) o puntos legales que de todas formas deben validarse con un abogado y el contador.
