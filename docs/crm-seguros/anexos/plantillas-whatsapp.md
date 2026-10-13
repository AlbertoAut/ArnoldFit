# Anexo · Plantillas de WhatsApp (borradores para someter a Meta)

Idioma `es_MX`. Pie obligatorio en todas: nombre de la agente, tipo y número de cédula CNSF y "Responde BAJA para dejar de recibir avisos". Sin palabras promocionales en las de utilidad. Las variables se resuelven desde `polizas`, `recibos` y `contactos`.

## Utility

**poliza_emitida** (cabecera DOCUMENT = carátula PDF)
> Hola {{1}}, tu póliza {{2}} de {{3}} quedó emitida con vigencia del {{4}} al {{5}}. Te comparto la carátula. Si algo no coincide con lo que acordamos, respóndeme por aquí.
> {{6}} · Cédula CNSF {{7}} · Responde BAJA para no recibir avisos.

**recibo_por_vencer**
> Hola {{1}}, el recibo {{2}} de tu póliza {{3}} ({{4}}) por {{5}} vence el {{6}}. Forma de pago registrada: {{7}}. Si ya lo cubriste, ignora este mensaje; si necesitas la referencia, responde REFERENCIA.
> {{8}} · Cédula CNSF {{9}} · Responde BAJA para no recibir avisos.

**recibo_vencido_gracia**
> Hola {{1}}, el recibo {{2}} de tu póliza {{3}} venció el {{4}}. Tu cobertura continúa hasta el {{5}} (periodo de gracia). Para evitar la cancelación automática, el pago debe aplicarse antes de esa fecha. ¿Te ayudo con la referencia?
> {{6}} · Cédula CNSF {{7}} · Responde BAJA para no recibir avisos.

**renovacion_30d**
> Hola {{1}}, tu póliza {{2}} de {{3}} vence el {{4}}. En los próximos días te comparto las condiciones de renovación para que las revises con calma. Si cambió algo (vehículo, domicilio, integrantes), avísame por aquí.
> {{5}} · Cédula CNSF {{6}} · Responde BAJA para no recibir avisos.

**renovacion_7d**
> Hola {{1}}, tu póliza {{2}} vence el {{3}}. Para que no quedes sin cobertura, confirma si deseas renovarla respondiendo SÍ, o escríbeme si tienes dudas.
> {{4}} · Cédula CNSF {{5}} · Responde BAJA para no recibir avisos.

**confirmacion_cita**
> Hola {{1}}, confirmo nuestra cita el {{2}} a las {{3}} ({{4}}). Si necesitas moverla, responde CAMBIAR.
> {{5}} · Cédula CNSF {{6}}.

**documento_recibido**
> Hola {{1}}, recibí tu documento ({{2}}) y ya quedó en tu expediente. Te aviso en cuanto tenga respuesta de {{3}}.
> {{4}} · Cédula CNSF {{5}}.

## Marketing (requieren opt-in de promociones)

**cumpleanos**
> ¡Feliz cumpleaños, {{1}}! Te deseo un gran día. Gracias por confiarme la protección de lo que más valoras.
> {{2}} · Cédula CNSF {{3}} · Responde BAJA para no recibir mensajes.

**oferta_proteccion**
> Hola {{1}}, muchas familias que tienen {{2}} también se protegen con {{3}}. Si quieres que te prepare una propuesta sin compromiso, responde INFO.
> {{4}} · Cédula CNSF {{5}} · Responde BAJA para no recibir mensajes.

## Mensajes de sesión (gratis dentro de la ventana de 24 h, sin plantilla)

- Presentación del asistente: "Soy el asistente automático de {{agente}}. Puedo darte información de tus pólizas y recibos. Escribe AGENTE en cualquier momento para hablar con ella."
- Contención en siniestro: "Lamento lo ocurrido. Ya avisé a {{agente}} y te contactará enseguida. Si es una emergencia llama ahora a {{aseguradora}}: {{telefono_cabina}}."
- Verificación: "Para darte datos de tu póliza, confírmame los últimos 4 dígitos del número de póliza."
