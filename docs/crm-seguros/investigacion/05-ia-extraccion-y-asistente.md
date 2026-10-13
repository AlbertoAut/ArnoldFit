# Investigación · Capa de IA: extracción documental, RAG y asistente

**Fecha: 2026-10-13.** Verificado en fuente primaria: precios y límites de Anthropic (platform.claude.com), Google Cloud Vision OCR, docs de n8n (repo n8n-docs), Supabase, READMEs de Docling/Marker/Surya/PaddleOCR/Tesseract/Chatwoot/Flowise/Dify/Typebot, Términos Comerciales de Anthropic. ⚠️ = no verificado en fuente primaria (OpenAI, Gemini, Mistral, Google Document AI, Azure, AWS, Voyage, Deepgram, Groq).

## 1. Extracción de datos estructurados de PDFs

### 1a. LLM multimodal con PDF directo

| Opción | Precio (1M tokens, in/out) | Soporte PDF | Fuente |
|---|---|---|---|
| **Claude Haiku 5.5** | $0.10 / $0.50 (≤100K tokens); caché lectura $0.01; Batch $0.05/$0.25 | Nativo (base64 o Files API); 32 MB, 600 páginas; cada página se procesa como texto (~1,500–3,000 tokens) **y** como imagen; sin cargo extra. Structured outputs (`output_config.format`) soportado | https://platform.claude.com/docs/en/about-claude/pricing ; https://platform.claude.com/docs/en/build-with-claude/pdf-support ; https://platform.claude.com/docs/en/build-with-claude/structured-outputs (verificado 2026-10-13) |
| **Claude Sonnet 5.5** | $2 / $10; caché lectura $0.10; Batch $1/$5 | Igual | ídem |
| **Claude Opus 5.5** | $4 / $20; caché lectura $0.20 | Igual | ídem |
| ⚠️ OpenAI GPT-5 / mini / nano | $1.25/$10 · $0.25/$2 · $0.05/$0.40 | Responses API acepta PDF | fuentes secundarias |
| ⚠️ Gemini 2.5 Flash / Flash-Lite / 3 Flash | $0.30/$2.50 · $0.10/$0.40 · $0.50/$3 | PDF nativo (~258 tokens/página) | fuentes secundarias |

Español sin problema en modelos frontier; tablas bien con JSON schema por fila; **manuscrito** es el punto débil (marcar baja confianza). Integración n8n: HTTP Request a `POST /v1/messages` con bloque `document` base64 y `output_config.format` (el sub-nodo LangChain "Anthropic Chat Model" no documenta PDF ni `output_config`; sí expone caché 5 min/1 h).

### 1b. OCR / Document AI especializados

| Servicio | Precio | Notas | n8n |
|---|---|---|---|
| ⚠️ Mistral OCR | $4/1,000 págs ($2 batch); annotations ~$5/1,000 | Markdown con tablas; manuscrito limitado | **Nodo nativo n8n "Mistral AI → Document → Extract Text"** (verificado en n8n-docs) |
| ⚠️ Google Document AI | OCR $1.50/1,000; Custom Extractor $30/1,000 + ~$36/mes hosting | Muy buen español y manuscrito | HTTP + OAuth |
| **Google Cloud Vision OCR** | **$1.50/1,000; primeras 1,000/mes gratis** | OCR sólido; sin tablas | HTTP (verificado https://cloud.google.com/vision/pricing) |
| ⚠️ Azure Document Intelligence | Read $1.50/1,000; Layout ~$10/1,000; Custom $30/1,000 | Tablas buenas | HTTP |
| ⚠️ AWS Textract | DetectText $1.50; Tables $15; Forms $50 /1,000 | SigV4 incómodo en n8n | HTTP |

### 1c. Open source
Docling (MIT), Marker/Surya (Apache + pesos OpenRAIL-M <$5M), PaddleOCR 3.7 (Apache), Tesseract 5 (Apache; sin layout, mal con fotos). Para 180 págs/mes **no se justifica** un VPS con GPU.

### 1d. n8n "Extract from File"
No hace OCR; solo capa de texto. Útil como **detector de "PDF nativo vs escaneado"** (<50 caracteres/página → imagen), para XLSX de comisiones y, con el nodo XML, para CFDI.

### 1e. Estimación mensual: 60 documentos × 3 páginas

| Enfoque | USD/mes |
|---|---|
| **A. Haiku 5.5 directo (clasificar + extraer)** | **≈ $0.16** ($0.08 con Batch) |
| B. Sonnet 5.5 directo | ≈ $3.20 |
| C. Mistral OCR + Haiku ⚠️ | ≈ $0.75 |
| D. Google Vision OCR + Haiku | ≈ $0.30 (0 bajo 1,000 págs) |
| G. Opus 5.5 directo | ≈ $6.50 |

**Conclusión:** el costo de IA es irrelevante (<$5/mes); optimizar por exactitud y simplicidad: Haiku 5.5 directo, escalando a Sonnet 5.5 cuando la confianza sea baja o el documento sea foto/manuscrito.

## 2. Pipeline recomendado
1. Ingesta → `sha256` → dedup en `documentos`.
2. Normalización: PDF tal cual; JPG/PNG como `image`; XLSX → Extract From File; XML CFDI → nodo XML (sin LLM).
3. Detección nativo vs escaneado.
4. **Clasificación (Haiku 5.5, página 1, JSON schema):** `{aseguradora: enum, tipo_doc: enum[caratula, recibo, endoso, estado_cuenta_comisiones, cfdi, condiciones_generales, otro], ramo: enum, confianza}`.
5. **Extracción (Haiku → Sonnet si confianza <0.8 o escaneado)** con JSON schema por (tipo_doc, ramo); por campo `{valor, confianza, pagina, evidencia_textual}`. Límites de structured outputs: sin `minimum/maximum/minLength`, `additionalProperties:false` obligatorio → validar formatos en n8n.
6. **Few-shot por aseguradora** en tabla `plantillas_extraccion` con caché de prompt.
7. **Validación determinista:** RFC `^([A-ZÑ&]{3}|[A-ZÑ&]{4})\d{6}[A-Z0-9]{3}$` + fecha interna; CURP regex completo; CP 5 dígitos; `vigencia_fin > vigencia_inicio`; `prima_neta + recargo + derechos + iva = prima_total` (±$1); IVA 16 % (vida sin IVA); suma de recibos = prima total; VIN 17 caracteres sin I/O/Q; UUID CFDI.
8. **Cola de revisión humana** para confianza <0.85 o regla fallida.
9. **Upsert** por clave natural `(aseguradora, numero_poliza, numero_endoso, tipo_doc)`; dedup semántica (misma póliza + vigencia + total aunque el hash difiera).
10. Registrar `usage` de cada llamada.

**Campos de carátula por ramo:** comunes (aseguradora, póliza, endoso, producto, contratante con RFC/CURP/domicilio, asegurado, vigencia, moneda, forma de pago, conducto, prima neta, recargo, derechos, IVA, total, clave de agente, fecha de emisión); autos (vehículo, VIN, placas, uso, paquete, tabla de coberturas con SA y deducible, conductor); vida (plan, SA, coberturas adicionales, plazos, fumador, beneficiarios con %); GMM (plan, SA, deducible, coaseguro y tope, nivel hospitalario, zona, asegurados con fecha de alta, periodos de espera); daños (ubicación, giro, secciones con SA y deducible, beneficiario preferente); recibo (número, periodo, fecha límite, importe desglosado, n de m); estado de cuenta de comisiones (periodo, clave, tabla por línea: póliza, recibo, prima, %, comisión, IVA, ISR retenido, IVA retenido, neto).

Técnicas: doble lectura (Haiku y Sonnet) y comparar; evidencia textual por campo; Citations API no se combina con `output_config.format`; ordenar prompt como instrucciones + esquema + few-shots (cacheados) → documento; **nunca** poner datos de clientes en el JSON schema (se cachea 24 h aparte).

## 3. Embeddings y RAG

| Modelo | Precio / 1M tokens | Dims |
|---|---|---|
| ⚠️ OpenAI text-embedding-3-small | $0.02 | 1536 |
| ⚠️ Voyage voyage-3.5-lite (recomendado por Anthropic) | $0.02 | 1024 |
| Supabase Edge `gte-small` | $0 | 384 (inglés-céntrico; evitar para español) |

**pgvector en Supabase** (verificado): HNSW con `vector_cosine_ops`; `hnsw.iterative_scan = relaxed_order` al filtrar por cliente; **búsqueda híbrida** (RRF full-text `'spanish'` + vector); RLS por `cliente_id`. El nodo n8n *Supabase Vector Store* requiere la función `match_documents`; con esquema propio usar RPC.

**Chunking de condiciones generales:** indexar una vez por (aseguradora, producto, versión) (~20–40 documentos únicos); Markdown por secciones (Definiciones → Coberturas → Exclusiones → Cláusulas → Siniestro); chunk por cláusula 400–800 tokens con solapamiento 10–15 % y **prefijo de contexto** ("GNP · Autos Amplia · CG 2025 · Sección 3 Exclusiones · Cláusula 3.4"); tablas como chunk propio; **los datos del cliente se consultan por SQL, no por vector**.

**Costo por conversación (200 conv/mes × 6 turnos):** Haiku 5.5 ≈ **$0.60/mes**; Sonnet 5.5 ≈ $12/mes; híbrido ≈ $3/mes; embeddings de consulta < $0.01; indexación inicial ≈ $0.04.

**Guardrails:** toda afirmación de cobertura cita cláusula y documento y cierra con "la cobertura definitiva la determina la aseguradora"; sin chunk de soporte → "lo reviso con [agente]"; salida JSON `{respuesta, citas[], requiere_humano, motivo}` y rechazo si `citas=[]` en tema cobertura. **Handoff obligatorio:** siniestro en curso (dar primero teléfono 24 h), queja/CONDUSEF, cancelación, cambio de beneficiarios, reclamación de pago, datos médicos, solicitud de persona, sentimiento negativo, 2 fallos de recuperación. No pedir datos sensibles completos; verificar identidad. Memoria Postgres por número, ventana 10–20 mensajes, purga >90 días.

## 4. Orquestación en n8n y alternativas
- **AI Agent** (Tools Agent desde 1.82; v1 se elimina en 3.0): system message, max iterations, human review, `$fromAI()`. **Anthropic Chat Model**: caché 5 min/1 h; no documenta `output_config`, thinking adaptativo ni PDF. **Postgres Chat Memory**: session key, tabla, ventana. **Information Extractor / Structured Output Parser**: es prompting, no decodificación restringida. **WhatsApp Trigger**: un solo webhook por app de Meta.
- **Recomendación:** HTTP Request contra `api.anthropic.com/v1/messages` para extracción (PDF + `output_config.format` + `cache_control`) y para la respuesta final del asistente; AI Agent + Postgres Chat Memory + Tools opcional para el bucle con herramientas; alternativa: un nodo Code de ~80 líneas que maneje el bucle `tool_use`.

| Alternativa | Veredicto |
|---|---|
| **Chatwoot** (MIT; bandeja humana multicanal con WhatsApp Cloud API nativo, app móvil, webhooks "agent bot") | **Sí** para bandeja + handoff; plantilla comunitaria n8n "Route Chatwoot chats to AI and live agents" |
| Flowise | **No**: repositorio archivado 13-ago-2026 |
| Dify | Redundante con n8n; pesado (2 vCPU/4 GiB) |
| Typebot | Solo formularios guiados |

**Stack MVP:** WhatsApp Cloud API → Chatwoot (bandeja + handoff + móvil) → webhook → n8n (clasificador → RAG → Claude) → respuesta vía API de Chatwoot. Sin Chatwoot: WhatsApp Trigger directo + tabla `conversaciones(modo: bot|humano)` y la agente contesta desde la app (funciona, pierde bandeja/colisiones).

## 5. Notas de voz
⚠️ OpenAI `gpt-4o-mini-transcribe` ~$0.003/min; `whisper-1` ~$0.006/min; Deepgram Nova-3 ~$0.0077/min; AssemblyAI $0.0025/min; Groq Whisper y Gemini audio no verificados. 150 audios × 1 min ≈ **$0.10–1.20/mes**. Guardar transcripción, no el audio.

## 6. Privacidad con proveedores LLM (datos de salud en GMM)

| Proveedor | Entrenamiento | Retención | ZDR / salud | Fuente |
|---|---|---|---|---|
| **Anthropic API** | No entrena con contenido de clientes (Términos Comerciales) | "Conversation content is not retained by default"; excepción: *Covered Models* (Fable/Mythos) 30 días. **Haiku 5.5 y Sonnet 5.5 no son Covered Models.** El JSON schema se cachea 24 h aparte | ZDR por organización vía ventas; **HIPAA readiness con BAA autoservicio desde la Consola** | https://platform.claude.com/docs/en/manage-claude/api-and-data-retention ; https://www.anthropic.com/legal/commercial-terms (verificado) |
| ⚠️ OpenAI API | No entrena por defecto | Logs de abuso 30 días; ZDR previa aprobación | BAA bajo solicitud | |
| ⚠️ Gemini API | Pago: no entrena; **gratuito: sí puede** | "periodo limitado" | ZDR → Vertex AI | |

**Minimización recomendada:** (1) en GMM, solo la carátula al LLM, nunca cuestionarios médicos ni dictámenes; (2) pre-redacción determinista (RFC, CURP, teléfonos, CLABE, nombres de dependientes) en los chunks; (3) proveedor con no-retención + BAA y **organización dedicada**; (4) sin niveles gratuitos de Gemini; (5) buckets privados con URLs firmadas cortas, RLS, logs, retención definida; (6) no almacenar audios; (7) consentimiento para atención por asistente automatizado.

## 7. Recomendación final
**MVP (≈ $2–5 USD/mes de IA):** Haiku 5.5 con PDF directo + structured outputs + caché, escalado a Sonnet 5.5; Batch API para cargas históricas; CFDI XML y Excel sin LLM; fallback OCR (Google Vision o Mistral vía nodo n8n) solo si fallan fotos; validación + cola de revisión; RAG en pgvector con Voyage 3.5-lite u OpenAI 3-small; asistente Haiku con escalado a Sonnet en cobertura; voz con `gpt-4o-mini-transcribe` o Deepgram; n8n + Chatwoot; org Anthropic con HIPAA readiness.

**Fase SaaS:** Batch API para lo no interactivo (−50 %); eval de 100–200 documentos etiquetados por aseguradora; capa OCR especializada para fotos/tablas largas; plantillas por aseguradora versionadas con aprendizaje de correcciones; RAG multi-tenant con corpus compartido de condiciones generales; Chatwoot multi-cuenta; ZDR por organización. Costo IA por agente activo ≈ **$3–8/mes Haiku-first**, $15–25 todo Sonnet.
