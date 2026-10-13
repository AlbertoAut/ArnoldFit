# 04 · Integraciones

Cada integración se describe con: qué aporta, cómo se conecta, qué hay que crear, qué cuesta y qué puede salir mal. El detalle técnico y las fuentes están en `investigacion/`.

## 4.1 Correo de aseguradoras (Gmail) — Fase 1, la integración más valiosa

**Qué aporta.** Es el canal por el que ya llegan carátulas, recibos, avisos de renovación y estados de cuenta. No requiere permiso de ninguna aseguradora ni scraping.

**Cómo.** Gmail Trigger de n8n (OAuth con la cuenta de la agente; polling cada 5 min) sobre la etiqueta `CRM/Entrada`. Filtros de Gmail etiquetan automáticamente por dominio remitente (`@gnp.com.mx`, `@qualitas.com.mx`, `@axa.com.mx`, `@hdi.com.mx`, `@metlife.com.mx`, `@mnyl.com.mx`, `@allianz.com.mx`, etc.). Se procesa **por remitente + adjunto**, nunca por asunto (los asuntos no están documentados y cambian).

**Qué crear.** Proyecto en Google Cloud con OAuth consent (tipo interno/testing basta para una cuenta), credencial Gmail en n8n, etiquetas y filtros. Si ella usa Gmail gratuito funciona igual que con Workspace.

**Costo.** 0.

**Riesgos.** Correos con liga en vez de adjunto (algunas aseguradoras en vida/GMM) → tarea manual en Fase 1, RPA acotado en Fase 3. Dominios desconocidos → lista blanca editable en `aseguradoras.dominios_email`.

**Tarea previa de la agente (2–3 semanas antes de arrancar):** no borrar correos de aseguradoras; anotar qué recibe de cada una (emisión, recibo, renovación, cancelación, comisiones) y guardar 3 ejemplos de cada tipo. Ese muestrario define los prompts.

## 4.2 WhatsApp Business Platform — Fase 1 (envío) y Fase 2 (asistente)

**Decisión clave: coexistencia.** Su número actual sigue en la app WhatsApp Business del teléfono **y** se conecta a la Cloud API a través de un Tech Provider con Embedded Signup. Recomendado **Kapso** (plan Free, 0 % de margen; Pro USD 25) o YCloud; alternativa "enterprise" 360dialog (≈ USD 49/mes). Twilio no sirve (exige borrar la cuenta de la app). Si Meta no la considera elegible (cuenta nueva o calidad baja) o la coexistencia resulta inestable, **contingencia:** segundo número (eSIM) directo en Meta Cloud API sin BSP.

**Requisitos:** número en WhatsApp **Business** App ≥ 2.24.17 con semanas de uso; portafolio de Meta Business donde ella sea admin; **método de pago registrado** (obligatorio desde el 30-sep-2026); elegir **MXN** al crear la WABA; abrir la app al menos cada 13 días.

**Qué pierde con coexistencia (avisarle antes):** listas de difusión (las sustituye el CRM), WhatsApp Web/Desktop (usará la bandeja del proveedor o el teléfono), mensajes temporales y "ver una vez". Los grupos siguen en el teléfono pero la API no los ve. Historial: se puede sincronizar hasta 6 meses.

**Plantillas (crear y someter a aprobación en la semana 3):**

| Nombre | Categoría esperada | Uso |
|---|---|---|
| `poliza_emitida` | Utility (cabecera DOCUMENT) | Entrega de carátula |
| `recibo_por_vencer` | Utility | 7 y 1 días antes |
| `recibo_vencido_gracia` | Utility | Dentro del periodo de gracia |
| `renovacion_30d`, `renovacion_7d` | Utility (texto informativo, sin promoción) | Renovación |
| `confirmacion_cita` | Utility | Citas |
| `documento_recibido` | Utility | Acuse cuando ella recibe un documento del cliente |
| `cumpleanos` | Marketing | Felicitación |
| `oferta_proteccion` | Marketing | Cross-sell con opt-in de marketing |

Texto completo en `anexos/plantillas-whatsapp.md`. Regla de redacción: datos de la póliza existente, sin "descuento", sin "aprovecha", sin botones a ofertas, o Meta la reclasifica a marketing.

**Opt-in.** Antes del primer mensaje iniciado por el negocio se registra consentimiento con nombre del negocio y opción BAJA (tabla `consentimientos`). Para la cartera actual: campaña inicial desde su teléfono (gratis, mensaje personal) pidiendo "responde SÍ para recibir avisos de tus pólizas por aquí"; la respuesta se guarda como evidencia (`wamid`).

**Costo.** Plantillas utility ≈ US$0.0085, marketing ≈ US$0.0397 (tarjeta oct-2026, verificar). 150 clientes ≈ **US$3.5–4.5/mes**. Servicio: 1,000 mensajes/mes gratis por número; arriba de eso, tarifa utility.

**n8n.** Nodo *WhatsApp Business Cloud* (texto, documento, plantilla, "send and wait"); botones/listas interactivos por HTTP Request; *WhatsApp Trigger* o webhook del proveedor para entrantes y estados. Guardar estado de sesión por número en `conversaciones`. **Filtrar los "echo"** de lo que ella escribe desde el teléfono para que el bot no se conteste a sí mismo.

**Políticas.** Seguros está permitido en mensajería; no usar catálogo/carrito. Nunca pedir ni enviar información médica detallada por WhatsApp; para eso, liga a formulario autenticado en la PWA.

## 4.3 Supabase — Fase 0

Proyectos `dev` y `prod` en región `us-east-1` (la más cercana con Free). Habilitar extensiones `vector`, `pg_trgm`, `pgcrypto`. Database Webhooks hacia n8n para `documentos` (aprobación) y `solicitudes_arco`. Storage: buckets `documentos` (privado) y `exportaciones` (privado, TTL). Auth: email + MFA TOTP. Cron anti-pausa (`SELECT 1` diario desde n8n) mientras esté en Free. Variables: `SUPABASE_URL`, `SUPABASE_ANON_KEY` (app), `SUPABASE_SERVICE_ROLE_KEY` (solo n8n/VPS).

## 4.4 Claude API (Anthropic) — Fase 1

Organización dedicada al CRM; activar HIPAA readiness/BAA desde la Consola (Settings → Data retention) porque habrá datos de salud en GMM. Modelos: `claude-haiku-5-5` por defecto, `claude-sonnet-5-5` para escalado, `claude-opus-5-5` solo para generar/afinar prompts y esquemas. Llamadas desde n8n con HTTP Request a `POST https://api.anthropic.com/v1/messages` con bloque `document` (PDF base64) y `output_config.format` (JSON Schema). Caché de prompt en instrucciones + esquema + ejemplos. Batch API para la carga histórica (50 % de descuento). Presupuesto mensual tope en la Consola: USD 10. Detalle en `06-ia-extraccion-y-asistente.md`.

## 4.5 SAT: CFDI y Descarga Masiva — Fase 2

**Para qué.** Conciliar comisiones: lo que la aseguradora reporta en el estado de cuenta vs lo que realmente se facturó/pagó, y entregar al contador un paquete mensual.

**Cómo.** Dos fuentes: (a) estado de cuenta de comisiones (PDF/XLS) por correo o descarga manual → extracción IA; (b) **CFDI** vía Servicio Web de Descarga Masiva del SAT con la **e.firma (FIEL)** de la agente usando la librería abierta `satcfdi` (Python) en un contenedor del VPS, o un proveedor (SW sapien, Edifact, Facturama; precios bajo cotización). Con `satcfdi` el costo es cero.

**Qué debe parametrizarse por aseguradora:** quién timbra (ella con su CSD, o la aseguradora por su cuenta), tasas de retención (ISR 0 %, 1.25 % RESICO o 10 % según práctica; IVA 2/3), exención de IVA por ramo (vida exenta; autos/GMM/daños 16 %).

**Qué guardar:** por pago: aseguradora, póliza/recibo, ramo, base, %, comisión, IVA trasladado y retenido, ISR retenido, neto, fecha, UUID CFDI y complemento de pago; estado de cuenta adjunto. Exportación mensual en CSV + ZIP de XML para el contador.

**Seguridad.** La FIEL (archivos `.cer/.key` + contraseña) se guarda cifrada en el VPS con acceso solo del contenedor del job; nunca en Supabase ni en n8n en claro. Alternativa: que el contador haga la descarga y suba el ZIP de XML al CRM (importador de XML sin FIEL).

## 4.6 Portales de aseguradoras — Fase 1 (manual asistido) y Fase 3 (RPA acotado)

**Realidad:** ninguna aseguradora mexicana publica API abierta para agentes individuales. Lo que existe: portales usuario/contraseña (algunos con OTP), apps de agente, y web services B2B solo para multicotizadores/promotorías con contrato.

**Fase 1.** Botón "Descargué del portal" en la PWA: la agente sube el PDF y el pipeline de IA hace el resto. Lista de portales con liga directa y credencial en Bitwarden.

**Fase 3 (piloto con 1–2 aseguradoras).** Solo portales **sin OTP** y cuyos términos no prohíban el acceso automatizado. Playwright con perfil de navegador persistente (sesión viva, sin resolver CAPTCHAs ni enmascarar huellas), horario nocturno, ritmo humano, solo descarga de documentos ya emitidos para la propia clave de la agente. Si aparece OTP o CAPTCHA, el flujo se detiene y crea una tarea manual. Antes de activarlo: leer los términos de uso del portal y el contrato de comisión mercantil; aceptar que la aseguradora puede pedir que se detenga.

**Multicotizador (Fase 3+).** Preguntar a Dora, BBVA API Market (Auto Insurance MX) y Guros si aceptan **las claves propias de la agente**, costo por emisión y si entregan PDF de carátula. SICAS/Cotizador Mexicano como referencia de qué aseguradoras son integrables.

## 4.7 Chatwoot (opcional, Fase 2)

Bandeja compartida con WhatsApp Cloud API nativo, app móvil, asignación y notas; MIT. n8n se conecta por webhook ("agent bot"); cuando una conversación se asigna a humano, el bot calla. Necesita ≈ 1 GB RAM extra en el VPS. Se adopta solo si la agente quiere una bandeja distinta a su app de WhatsApp o si entra una asistente.

## 4.8 Email transaccional (Resend) — Fase 1

Dominio verificado (SPF/DKIM) en el `.com` del proyecto; remitente `avisos@`. Usos: copia de la carátula, recordatorio de respaldo cuando WhatsApp falla, resumen semanal para la agente, exportaciones. Free: 3,000/mes, 100/día.

## 4.9 Google Calendar — Fase 2

Citas creadas desde la PWA o por el asistente ("agenda llamada mañana 10 am") → evento en el calendario de la agente con liga al cliente. Nodo nativo de n8n.

## 4.10 Cloudflare — Fase 0

Registrar dominio, DNS, Pages/Workers para la PWA, R2 para respaldos, Tunnel + Access para el editor de n8n y para Supabase Studio self-host si se usa. Todo en capa gratuita.

## 4.11 Catálogos externos

- **Aseguradoras**: semilla manual de ~25 con RFC, dominios de correo, teléfonos de cabina y siniestros, URL de portal (fuente: SIPRES de CONDUSEF y sitios oficiales).
- **Códigos postales (SEPOMEX)**: tabla `cp_sepomex` cargada desde el catálogo oficial o un paquete comunitario; autocompleta colonia/municipio/estado.
- **Vehículos (AMIS)**: no es dato abierto; en Fase 1 texto libre + VIN; en Fase 3 vía API del multicotizador.
- **UMA** y **tipo de cambio FIX** (Banxico API gratuita) para pólizas en USD/UDI.
