# 06 · IA: extracción documental y asistente de WhatsApp

## 1. Extracción documental

### Objetivo
Que ningún dato de una póliza se capture a mano. Entrada: PDF nativo, PDF escaneado, foto de WhatsApp, XLSX de comisiones, XML CFDI. Salida: JSON validado en `documentos.extraccion`, listo para revisión de un clic.

### Modelo y costo
- Por defecto **Claude Haiku 5.5** (US$0.10/1M entrada, US$0.50/1M salida). Un documento de 3 páginas ≈ 22K tokens de entrada → ≈ US$0.003. 60 documentos/mes ≈ **US$0.16**.
- Escalado automático a **Sonnet 5.5** si `confianza < 0.8`, documento escaneado/foto, o campo manuscrito. 60 documentos todo en Sonnet ≈ US$3.20.
- **Batch API** (−50 %) para la carga histórica de la cartera.
- Fallback OCR solo si fallan sistemáticamente las fotos: Google Vision (US$1.50/1,000 págs, 1,000 gratis) o Mistral OCR (nodo nativo de n8n).

### Dos pasos, no uno
1. **Clasificar** (página 1): `{aseguradora, tipo_documento, ramo, confianza}`. Se compara con el remitente del correo; si difieren, bandera.
2. **Extraer** con el JSON Schema del par `(tipo_documento, ramo)`. Cada campo devuelve `{valor, confianza, pagina, evidencia_textual}` para que la revisora valide en segundos y se detecten alucinaciones.

### Esquemas (en `n8n/schemas/`)
`caratula.autos.json`, `caratula.vida.json`, `caratula.gmm.json`, `caratula.danos.json`, `caratula.fianzas.json`, `recibo.json`, `endoso.json`, `estado-cuenta-comisiones.json`, `cotizacion.json`. Ejemplo completo en `anexos/schemas/caratula.autos.json`. Restricciones de structured outputs: `additionalProperties: false` obligatorio, sin `minimum/maximum/minLength`, regex parcial → las validaciones de formato se hacen en n8n.

### Prompt (en `n8n/prompts/`)
Estructura estable primero (cacheable): rol, reglas, esquema, 1–2 ejemplos reales de esa aseguradora; al final el documento (variable). Reglas clave del prompt:
- "Extrae solo lo que está en el documento. Si un dato no aparece, `valor: null` y `confianza: 0`."
- "Las cantidades en pesos van como número sin símbolo ni comas; la moneda en campo aparte."
- "Fechas en ISO 8601. Si el documento dice 'a las 12:00 hrs', ignora la hora."
- "Nunca inventes RFC, CURP ni número de póliza; si están incompletos, copia lo visible y baja la confianza."

### Validaciones deterministas (nodo Code)
RFC (regex + fecha interna), CURP (regex), CP (5 dígitos + catálogo), `vigencia_fin > vigencia_inicio`, `prima_neta + recargo + derechos + iva ≈ prima_total` (±1 %), IVA 16 % salvo vida, suma de recibos = prima total, VIN 17 caracteres sin I/O/Q, UUID CFDI, número de póliza con patrón conocido de la aseguradora.

### Cola de revisión
Todo entra como `POR_REVISAR`. La PWA muestra PDF y campos lado a lado, resalta los de confianza < 0.85 o con regla fallida. Aprobación de un clic cuando todo está verde. Cada corrección humana se guarda (`extraccion` vs valor final) y alimenta los ejemplos few-shot por aseguradora. Meta de salida de la revisión obligatoria: 98 % de campos correctos en 50 documentos consecutivos por (aseguradora, tipo).

### Privacidad
- GMM: al LLM solo va la **carátula**; cuestionarios médicos y dictámenes se clasifican y archivan cifrados sin pasar por el modelo.
- Organización de Anthropic dedicada con HIPAA readiness/BAA; Haiku/Sonnet 5.5 no retienen contenido por defecto.
- Nunca poner datos de clientes dentro del JSON Schema (se cachea 24 h aparte).
- Las fotos de WhatsApp se procesan y se conserva el original en Storage privado; los audios no se conservan, solo la transcripción.

## 2. Asistente de WhatsApp (Fase 2)

### Qué hace y qué no
Hace: responde dudas de pólizas vigentes del cliente (importe y fecha del próximo recibo, referencia de pago, vigencia, coberturas y deducibles citando la póliza), entrega documentos, agenda llamadas, confirma recepción de documentos, recoge datos para cotizar (WhatsApp Flows o preguntas guiadas).
No hace: afirmar si un siniestro concreto está cubierto sin cita, procesar siniestros, cancelar pólizas, cambiar beneficiarios, hablar de datos médicos, prometer pagos.

### Arquitectura
1. **Clasificador de intención** (Haiku): `siniestro | pago | cotizacion | documento | renovacion | queja | cancelacion | datos_sensibles | otro` + sentimiento.
2. **Handoff inmediato** si siniestro, queja, cancelación, cambio de beneficiarios, reclamación, datos médicos, petición explícita de persona, sentimiento muy negativo o 2 fallos de recuperación. Respuesta de contención + teléfono 24 h de la aseguradora + alerta a la agente + `conversaciones.modo = HUMANO`.
3. **Contexto estructurado por SQL** (no por vector): pólizas vigentes del contacto, recibos pendientes, últimas actividades.
4. **RAG** en pgvector: condiciones generales por (aseguradora, producto, versión), FAQs, guías de siniestro; chunk por cláusula con prefijo de contexto; búsqueda híbrida (full-text `spanish` + coseno) con RRF.
5. **Generación** con Haiku (Sonnet en preguntas de cobertura) y salida JSON `{respuesta, citas[], requiere_humano, motivo}`; se rechaza una respuesta de cobertura sin citas.
6. **Memoria**: últimos 10–20 mensajes por número (tabla `mensajes`), resumen en `conversaciones.resumen_ia`; purga > 90 días.
7. **Voz**: transcripción con `gpt-4o-mini-transcribe` o Deepgram (≈ US$0.003–0.008/min).

### Guardrails en el system prompt
- Identificarse como asistente automático de [Agente], cédula CNSF No. ___, y ofrecer siempre "escribe AGENTE para hablar con ella".
- Nunca revelar datos de póliza sin que el número de WhatsApp coincida con el del contacto; ante duda, pedir un dato de control (últimos 4 dígitos de la póliza).
- Toda afirmación de cobertura cierra con "la cobertura definitiva la determina la aseguradora conforme a tus condiciones generales".
- No solicitar ni repetir datos médicos, números de tarjeta ni CLABE completa.
- Respuestas de máximo 6 líneas; una pregunta a la vez.

### Costo
200 conversaciones × 6 turnos al mes: Haiku ≈ US$0.60; híbrido ≈ US$3; todo Sonnet ≈ US$12. Embeddings e indexación: centavos.

### Evaluación antes de encender el bot
Set de 60 conversaciones de prueba (20 por intención crítica) escritas con la agente; criterio de paso: 100 % de handoffs correctos en siniestro/queja/cancelación, 0 afirmaciones de cobertura sin cita, ≥ 90 % de respuestas de pago/vigencia correctas. Repetir el set en cada cambio de prompt.

## 3. Otros usos de IA de bajo costo
- **Resumen diario** para la agente (WF-12): "Hoy: 3 recibos vencen, 2 renovaciones a 15 días, 1 siniestro sin movimiento 6 días".
- **Redacción asistida** de mensajes a clientes desde la PWA (tono, ortografía), siempre con envío manual.
- **Detección de duplicados** y de pólizas faltantes: si el estado de cuenta de comisiones trae una póliza que el CRM no tiene, se crea una tarea.
- **Generación de cuadros comparativos** en PDF a partir de 2–3 cotizaciones capturadas (Fase 3).
