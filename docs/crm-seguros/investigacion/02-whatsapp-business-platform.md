# Investigación · WhatsApp Business Platform para el CRM (México)

**Fecha de consulta: 2026-10-13.** Marcas: ✅ confirmado en documentación oficial de Meta (vía snippet o espejo) · ⚠️ fuente de terceros o conflicto entre fuentes · ❓ no verificado. Las páginas oficiales de Meta no pudieron abrirse directamente; las cifras de México provienen de agregadores/BSPs que citan la tarjeta de Meta y se contradicen entre sí hasta ±45 % en marketing. **Antes de presupuestar, abrir la tarjeta oficial de México** en https://developers.facebook.com/documentation/business-messaging/whatsapp/pricing → Rate cards → México.

## 1. Modelo de precios y tarifas para México

| Hecho | Detalle | Fuente / vigencia |
|---|---|---|
| Cobro **por mensaje** | Desde el 1-jul-2025 cada plantilla entregada se cobra según categoría + país. | ✅ Meta pricing page; vigencia 2025-07-01 |
| Categorías | Marketing, Utility, Authentication, Service (texto libre dentro de la ventana de 24 h) | ✅ |
| Punto de entrada gratuito (72 h) | Conversación desde anuncio Click-to-WhatsApp o CTA de Página de Facebook: todos los mensajes gratis 72 h. | ⚠️ SleekFlow, BIK; mencionado en Meta pricing |
| Utility dentro de 24 h | Gratis entre 1-jul-2025 y 30-sep-2026. **Desde 1-oct-2026 se cobra** a tarifa utility. | ✅ https://developers.facebook.com/documentation/business-messaging/whatsapp/pricing/non-template-messages ; Twilio https://help.twilio.com/articles/53100480177819 |
| Mensajes de **servicio** | Gratis hasta 30-sep-2026. **Desde 1-oct-2026: 1,000 mensajes de servicio gratis al mes por número**; del 1,001 en adelante tarifa utility del país. Entrantes nunca se cobran. | ✅ Meta non-template-messages; ⚠️ YCloud, wawcd |
| Método de pago obligatorio | Sin método de pago al 30-sep-2026 no se pueden enviar mensajes de servicio desde 1-oct-2026. | ✅ |
| Facturación en MXN | Desde 1-ene-2026 se puede elegir MXN **solo al crear una WABA nueva**. | ✅ vía AiSensy |

### Tarifas México (USD por mensaje entregado, antes de impuestos y márgenes de BSP)

| Categoría | Cifra más citada (vigencia 2026-10-01) | Alternativas / históricas | Confianza |
|---|---|---|---|
| Marketing | **US$0.0397** (≈ MXN 0.73) | 0.0305 (jul–sep 2026); 0.0436 (2024-25) | ⚠️ media |
| Utility | **US$0.0085** (≈ MXN 0.16) | 0.0080–0.0102 | ⚠️ media-alta |
| Authentication | **US$0.0085** | 0.0102–0.0235 antiguas | ⚠️ media |
| Service (>1,000/mes) | = utility **US$0.0085** | — | ✅ regla; cifra ⚠️ |

Fuentes: Aurora Inbox https://www.aurorainbox.com/en/2026/05/26/price-whatsapp-business-api-mexico-2026/ ; iTechDev https://itechdev.com.mx/en/blog/precio-whatsapp-business-api-mexico-2026 ; Flowcall; Whatsetter; Goeva.

### Cálculo mensual para 150 clientes
Supuestos: 300 utility/mes (2 por cliente), 30 marketing/mes, asistente IA dentro de la franquicia de 1,000 mensajes de servicio.

| Escenario | Utility (300) | Marketing (30) | Total USD | Total MXN |
|---|---|---|---|---|
| Tarjeta oct-2026 (0.0085 / 0.0397) | 2.55 | 1.19 | **≈ 3.74** | **≈ 69** |
| Pesimista (0.0102 / 0.0456) | 3.06 | 1.37 | ≈ 4.43 | ≈ 81 |

Extras: si la IA supera 1,000 mensajes de servicio/mes, cada extra ≈ 0.0085; ❓ IVA 16 % sobre la factura de Meta; margen del BSP si no se va directo. **Conclusión: el costo de Meta es despreciable (< MXN 100/mes).**

## 2. Ventana de 24 h, categorías, aprobación, límites, opt-in

- **Ventana de servicio:** se abre con cada mensaje del usuario y dura 24 h desde su último mensaje. Dentro: texto libre, media, botones interactivos (hasta 3) y listas (hasta 10 opciones). Fuera: solo plantillas aprobadas. ✅ Meta blog 2022.
- **Clasificación de plantillas** (✅ https://developers.facebook.com/documentation/business-messaging/whatsapp/templates/template-categorization): Utility = seguimiento a acción/transacción existente sin promoción; contenido mixto → Marketing; contenido vago → Marketing; Meta puede recategorizar antes y después de aprobar.

| Mensaje del CRM | Categoría probable | Cómo redactar |
|---|---|---|
| Recordatorio de renovación (nº póliza, vigencia, prima) | **Utility** si es informativo ("Tu póliza X vence el DD/MM; responde para renovar") | Sin "¡Renueva hoy con descuento!", sin CTAs de venta |
| Recordatorio de recibo/pago | **Utility** | Solo datos del recibo |
| Entrega de PDF de póliza | **Utility** (cabecera DOCUMENT) | Dentro de 24 h puede ir como mensaje libre |
| Cumpleaños | **Marketing** | Cuenta para límite por usuario |
| Cross-sell | **Marketing** | Siempre |

- **Aprobación:** revisión automática en minutos; humana hasta 48 h (⚠️ Twilio). Estados Pending → Approved/Rejected; pausas de 3 h/6 h por baja calidad; el mismo nombre no se reutiliza en 30 días.
- **Límite de marketing por usuario** (✅ https://developers.facebook.com/documentation/business-messaging/whatsapp/templates/marketing-templates/per-user-limits/): dinámico; error 131049 al bloquear; **no se entregan plantillas de marketing a números de EE. UU. (+1)**. Irrelevante a 30 marketing/mes.
- **Opt-in** (✅ https://developers.facebook.com/documentation/business-messaging/whatsapp/getting-opt-in): permiso antes del primer mensaje iniciado por el negocio; debe indicar que acepta recibir mensajes y el nombre del negocio; facilitar opt-out ("BAJA"). Buena práctica: opt-in por categoría (recordatorios vs promociones).

## 3. Coexistencia (mismo número en la app del teléfono y en la Cloud API)

**Sí es posible** mediante la función oficial "Onboard WhatsApp Business app users", **pero solo a través de un Solution Partner o Tech Provider** con Embedded Signup. No hay botón de coexistencia para un negocio que va directo a developers.facebook.com.

| Requisito | Detalle (✅ Meta https://developers.facebook.com/documentation/business-messaging/whatsapp/embedded-signup/onboarding-business-app-users/ ; ⚠️ 360dialog, Kapso, Infobip) |
|---|---|
| App | WhatsApp **Business** App (no personal) ≥ 2.24.17, número activo. Un número ya en Cloud API no se convierte a coexistencia ni viceversa. |
| Elegibilidad | Meta la decide por antigüedad de la cuenta y calidad; cuentas nuevas no son elegibles de inmediato (≥7 días ⚠️). |
| Actividad | **Abrir la app al menos cada 13 días**; desinstalarla desconecta la API. |
| Flujo | Embedded Signup del partner → "WhatsApp Business App" → escanear QR desde el teléfono → confirmar → opcional compartir historial (hasta 6 meses) y contactos. Si pide código SMS se tomó la ruta equivocada. |
| País | México nunca apareció en la lista de excluidos (EEE/UE, UK, Australia, Japón, Nigeria, Filipinas, Rusia, Corea, Sudáfrica, Turquía); varios vendors afirman disponibilidad global en 2026. ❓ lista vigente no confirmada. |

**Qué se conserva y qué se pierde** (⚠️ consenso de docs de BSPs):

| Función | App del teléfono | API |
|---|---|---|
| Chats 1:1 | Siguen; se sincronizan en ambos sentidos (lo que ella escribe desde el teléfono llega a n8n como "echo") | Sí |
| Historial previo | Se queda en el teléfono | Opcional sincronizar hasta 6 meses |
| **Listas de difusión** | **Deshabilitadas** (las sustituyen las plantillas) | — |
| Grupos | Siguen en la app | No se ven en la API |
| Mensajes temporales, ver una vez, ubicación en vivo | Deshabilitados | No |
| WhatsApp Web/Desktop | **Se desvinculan**; solo teléfono principal + API | — |
| Throughput | — | 20 msg/s (irrelevante) |
| Estabilidad | Kapso la describe como menos estable que un número dedicado | |

**Proveedores con coexistencia (2026-10-13):** 360dialog ✅ (≈ USD 49/mes por número); **Kapso ✅ (plan Free, Pro USD 25)**; Wati ✅ (USD 49+); YCloud ✅ (Free, afirmación del vendor); Infobip, respond.io, SleekFlow, 8x8, Telnyx ✅; Gupshup ⚠️ beta cerrada; **Twilio ❌** (exige borrar la cuenta de la app); **Meta Cloud API directa ❌** para un negocio final.

## 4. Cloud API directa vs BSPs

| Opción | Fijo | Margen | Complejidad | Coexistencia | Veredicto |
|---|---|---|---|---|---|
| Meta Cloud API directa | 0 | 0 % | Media (portafolio → app → número que NO esté en la app → token de sistema → webhook → plantillas) | ❌ | Más barato; nodos nativos de n8n; exige segundo número |
| **Kapso** | Free (2,000 msgs/mes, 1 número); Pro USD 25 | 0 % | Baja; API-first | ✅ | **Mejor relación costo/coexistencia** (https://docs.kapso.ai/docs/whatsapp/pricing-faq) |
| 360dialog | ≈ USD 49/mes por número | 0 % | Baja-media | ✅ | Sólido pero el fijo supera 10× el gasto en mensajes |
| YCloud | Free; Growth USD 39 | 0 % (vendor) | Baja | ✅ (vendor) | Alternativa con inbox |
| Twilio | 0 | +USD 0.005/msg | Baja | ❌ | Descartado |
| Wati | USD 49–299 | ~20 % utility | Baja | ✅ | Caro para 150 clientes |
| Evolution API / Baileys (no oficial) | hosting | 0 | Baja | "sí" | **No usar con el número principal**: viola ToS, riesgo real de baneo permanente |

## 5. Requisitos: verificación, límites, nombre, seguros

- **Límites de envío:** inicio 250 clientes únicos/24 h; escalones 250 → 1K/2K → 10K → 100K → ilimitado; desde 7-oct-2025 el límite es por portafolio. No aplican a conversaciones iniciadas por el usuario. ⚠️ 360dialog, Wati, AiSensy.
- **Verificación de negocio:** no necesaria para 150 clientes; sí para subir de nivel y para mostrar el nombre en el chat sin verificación pendiente. 2–10 días hábiles con RFC/acta/comprobante.
- **Migrar el número sin coexistencia:** hay que eliminar la cuenta en la app; se pierde el historial. ✅ Meta.
- **Seguros:** la Business Messaging Policy no prohíbe seguros; Meta publica una guía oficial de Flows "Insurance Quote" (https://developers.facebook.com/docs/whatsapp/flows/gettingstarted/health-insurance). Resúmenes de la Commerce Policy listan servicios financieros como restringidos para **comercio** (catálogo/carrito). Recomendación: no usar catálogo ni "vender" pólizas como productos; usar mensajería, documentos y Flows. ❓ texto oficial no verificado.

## 6. Integración con n8n y WhatsApp Flows

- **Nodo WhatsApp Business Cloud:** Send (texto, imagen, documento…), Send Template (variables y cabecera de documento → PDF de póliza), Send and Wait for Response (aprobación, texto libre, formulario), Media upload/download. **Botones y listas interactivas no están en el nodo** → HTTP Request a `graph.facebook.com/v*/{phone_id}/messages` con `type: interactive`.
- **Nodo WhatsApp Trigger:** mensajes entrantes (texto, media, respuestas de botón/lista, respuestas de Flow), estado de plantillas y calidad. Cada respuesta a un botón re-dispara el workflow → guardar estado de sesión por número en Postgres. Con coexistencia, filtrar los "echo" de la agente para no responderlos con la IA.
- **WhatsApp Flows:** viables para captar datos de cotización; respuesta llega como `nfm_reply`; Flows dinámicos requieren endpoint con cifrado de clave pública. Sin tarifa propia (⚠️ inferido). Caso real: Icatu Seguros (Brasil) cotizador para 1,000 corredores en n8n.

## 7. Canales de respaldo en México

| Canal | Precio | Comentario |
|---|---|---|
| SMS Twilio → México | US$0.1511/segmento saliente (https://twilio.com/sms/pricing/mx) | ≈ 18× una utility de WhatsApp; solo para alertas críticas |
| Email Resend | Free 3,000/mes (100/día) | Suficiente; ideal para PDFs |
| Email SES | US$0.10/1,000 | Más configuración |
| Telegram | gratis | **No sensato**: casi ningún cliente de seguros en México lo usa (WhatsApp ≈ 94–96 M usuarios en MX) |

## 8. Recomendación

**Opción A (recomendada): coexistencia con Kapso (Free) o YCloud, conservando la WhatsApp Business App de la agente.**
1. Confirmar que su número está en WhatsApp Business App (no personal), actualizada, con semanas de uso y buena calidad. Si está en WhatsApp personal: migrar primero a Business App y usarla unas semanas.
2. Crear portafolio de Meta Business donde ella sea admin; agregar método de pago; elegir MXN al crear la WABA.
3. Conectar vía Embedded Signup "WhatsApp Business App → QR"; aceptar sincronizar 6 meses de historial.
4. Avisarle de las pérdidas: listas de difusión, WhatsApp Web/Desktop, mensajes temporales; abrir la app cada ≤13 días.
5. n8n con WhatsApp Trigger/webhook del proveedor + HTTP Request para plantillas/interactivos + tabla de sesión y consentimiento + filtro de echo. 4–5 plantillas utility (renovación, recibo, entrega de póliza, cita) y 2 marketing (cumpleaños, cross-sell) con texto neutro.
6. Presupuesto Meta ≈ US$3.5–4.5/mes + 0 de plataforma en plan Free.

**Opción B (contingencia): segundo número dedicado en Cloud API directa** (SIM/eSIM nueva, sin BSP), si Meta declara el número no elegible o la coexistencia resulta inestable. Desventaja: los clientes reciben de dos números.

**Lo que NO hacer:** borrar la cuenta de la app para migrar el número; usar Evolution API/Baileys con el número principal.

## 9. Pendientes de verificación
1. Tabla oficial de tarifas de México (cifras y vigencia 1-oct-2026; IVA).
2. Lista oficial vigente de países soportados para coexistencia.
3. Página oficial de messaging limits (1K vs 2K primer escalón).
4. Texto oficial de la Commerce Policy sobre seguros.
5. Tarifa y requisitos de endpoint de Flows.
6. Si Kapso/YCloud aceptan números +52 en coexistencia (muy probable; no confirmado).
