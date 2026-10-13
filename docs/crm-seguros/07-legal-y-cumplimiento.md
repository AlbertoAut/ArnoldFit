# 07 · Legal y cumplimiento (operativo)

Resumen ejecutable del informe `investigacion/04-marco-legal-y-regulatorio.md`. **No es asesoría legal**: antes de salir a producción conviene una revisión de 2–3 horas con un abogado de datos personales (costo típico MXN 3,000–8,000) y confirmar con el contador el régimen fiscal de la agente.

## 1. Mapa normativo que sí aplica a la agente y al CRM

| Norma | Qué exige | Dónde se implementa |
|---|---|---|
| **LFPDPPP 2025** (DOF 20-mar-2025; autoridad: Secretaría Anticorrupción y Buen Gobierno) | Aviso de privacidad; consentimiento expreso y por escrito para datos sensibles (salud); ARCO en 20 + 15 días; medidas de seguridad; notificación de vulneraciones al titular; contrato con encargados (Supabase, Meta, Anthropic, tú como SaaS); bloqueo y supresión | Tablas `consentimientos`, `solicitudes_arco`, `auditoria`; flujo de consentimiento con OTP; `deleted_at` + bloqueo; DPAs archivados |
| **Reglamento de Agentes de Seguros y de Fianzas** | Identificarse con nombre, tipo, número y vigencia de cédula; reserva de la información; refrendo de cédula | Tabla `cedulas` con alerta a −60 días; pie de firma en plantillas de WhatsApp y correos |
| **LISF 96, 99, 492** | Informar coberturas y exclusiones; cobrar primas solo contra recibo oficial y entregar en 10 días hábiles; conocimiento del cliente | `recibos` con referencia oficial; expediente KYC en `contactos`/`documentos` |
| **Ley sobre el Contrato de Seguro 40, 66, 71, 81** | Gracia (30 días naturales por defecto, también en fracciones); aviso de siniestro 5 días; pago 30 días; prescripción 2/5 años | `recibos.dias_gracia`, `fecha_limite_pago`; alertas de siniestro y prescripción |
| **Contratos de comisión mercantil** de cada aseguradora | Confidencialidad, seguridad, a veces restricciones de almacenamiento | Revisar los 6+ contratos; anotar restricciones en `aseguradoras.config` |
| **Fiscal** (LISR, LIVA, CFF, RMF) | CFDI por comisión; retenciones (0/1.25/10 % ISR; 2/3 IVA); IVA exento en vida; conservar 5 años | Tabla `comisiones` y `estados_cuenta_comisiones`; parámetros por aseguradora; exportación mensual |
| **Meta Business Messaging Policy** | Opt-in con nombre del negocio; opt-out; sin datos médicos | `consentimientos` tipo `WHATSAPP_OPTIN`; palabra BAJA; plantillas sin salud |
| **NOM-151** (opcional MVP, recomendable SaaS) | Constancia de conservación de mensajes de datos | Sello de tiempo sobre consentimientos y acuses |

Lo que **no** aplica directamente: CUSF 3.6 (es para instituciones), UNE/RECA de CONDUSEF (la agente no es institución financiera), LFPIORPI como actividad vulnerable (verificar reforma 2025).

## 2. Aviso de privacidad (entregable de la semana 2)

Tres versiones, versionadas en la BD:
- **Integral** (página web del CRM `/privacidad`): identidad y domicilio de la agente; datos tratados, señalando los **sensibles** (salud, para GMM y vida); finalidades primarias (asesoría, cotización, emisión, cobranza, renovación, siniestros) y secundarias (felicitaciones, ofertas), con casilla para negar las secundarias; transferencias a aseguradoras y afianzadoras; encargados (hosting en EE. UU., WhatsApp/Meta, proveedor de IA, correo); medios ARCO (correo + formulario en la PWA); revocación; cambios al aviso.
- **Simplificado**: en formularios y en el primer mensaje de WhatsApp, con liga al integral.
- **Corto**: para la firma de la agente.

## 3. Flujo de consentimiento

1. Alta de cliente nuevo: la agente envía desde la PWA una liga única `/consentimiento/{token}`.
2. El cliente recibe OTP por WhatsApp o SMS al número registrado, lee el aviso simplificado, marca por separado: (a) tratamiento de datos para la relación de seguros, (b) **datos sensibles de salud** (solo si hay GMM/vida), (c) mensajes por WhatsApp, (d) promociones.
3. Se guarda en `consentimientos`: versión del aviso, fecha/hora, IP, OTP verificado, texto exacto mostrado, hash del documento; se genera PDF de constancia en Storage.
4. Para la cartera existente: campaña desde el teléfono de la agente ("responde SÍ para seguir recibiendo avisos de tus pólizas por aquí; aviso de privacidad: liga"); el `wamid` de la respuesta es la evidencia de opt-in de WhatsApp. El consentimiento de **datos de salud** se recaba con la liga OTP o con el formato firmado escaneado (ya suele existir en el expediente de la aseguradora; guardar copia).
5. Si no hay consentimiento de salud registrado, la PWA **bloquea** la captura de campos de salud.

## 4. Derechos ARCO

- Formulario en la PWA y correo dedicado; la agente también puede registrar una solicitud recibida verbalmente.
- `solicitudes_arco` calcula fecha límite (20 días hábiles) y la ejecución (15 días hábiles más); recordatorios a −10 y −3 días.
- **Acceso**: exportación del expediente del contacto (JSON + PDFs) con un clic.
- **Rectificación**: edición con auditoría.
- **Cancelación/Oposición**: `deleted_at` + estado `BLOQUEADO`; los datos salen de todas las vistas operativas, se conservan por el plazo de prescripción (2/5 años LSCS, 5 fiscal) y se **suprimen** o anonimizan (hash irreversible de identificadores) al vencer; no se eliminan registros contables.
- Plantilla de respuesta y acuse en PDF.

## 5. Seguridad y evidencia

- Documento de medidas de seguridad (inventario de datos, análisis de riesgo, controles, responsables): plantilla en `anexos/` que se llena en la semana 6.
- Bitácora de vulneraciones (tabla `auditoria` con acción `INCIDENTE`) y plantilla de notificación al titular.
- DPAs: descargar y archivar los términos de tratamiento de datos de Supabase, Cloudflare, Meta (WhatsApp Business), Anthropic (Commercial Terms + BAA), Resend, Kapso.
- Retención: pólizas y recibos 5 años tras fin de vigencia (fiscal) o más si hay siniestro abierto; mensajes de WhatsApp 24 meses; audios no se guardan; logs 12 meses.

## 6. Fiscal: qué pedirle al contador antes de la semana 9

1. Régimen de la agente (Actividad Empresarial, RESICO o asimilados) y, por aseguradora, quién timbra y qué retiene.
2. Confirmar la exención de IVA en comisiones de vida y el 16 % en los demás ramos.
3. Formato que quiere recibir cada mes (CSV + XML) y si necesita el detalle por recibo.

## 7. Checklist de salida a producción (go-live del MVP)

- [ ] Aviso de privacidad integral publicado y versión registrada en la BD
- [ ] Flujo de consentimiento con OTP probado; campaña de opt-in enviada a la cartera
- [ ] Datos de la agente (cédula, tipo, ramos, vigencia, RFC) cargados; pie de firma en plantillas
- [ ] MFA activado para la agente y para ti; contraseñas de portales en Bitwarden, no en la BD
- [ ] RLS probado con un segundo tenant ficticio (no debe ver nada)
- [ ] Respaldo diario funcionando y una restauración de prueba hecha
- [ ] DPAs archivados; organización de Anthropic con BAA
- [ ] Plantillas de WhatsApp aprobadas y sin contenido de salud
- [ ] Módulo ARCO con una solicitud de prueba completada
- [ ] Contratos de comisión mercantil revisados; restricciones anotadas
