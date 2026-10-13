# 10 · Riesgos y camino a SaaS

## 1. Riesgos y mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| El número de WhatsApp no es elegible para coexistencia o la conexión es inestable | Media | Alto (sin WhatsApp el CRM pierde la mitad del valor) | Verificar en semana 1; contingencia con número dedicado; nunca borrar la cuenta de la app |
| Meta reclasifica plantillas utility a marketing o pausa una plantilla | Media | Bajo (costo) / Medio (entregabilidad) | Texto neutro con datos de póliza; monitoreo de calidad en `plantillas_mensaje`; versión B lista |
| La extracción IA falla en alguna aseguradora (diseños atípicos, escaneos) | Media | Medio | Cola de revisión obligatoria; few-shots por aseguradora; escalado a Sonnet; fallback OCR; medir precisión por aseguradora |
| Bloqueo de la clave de agente por acceso automatizado a portales | Baja si se respeta el plan; alta si se hace scraping agresivo | Muy alto | Correo y API primero; RPA solo sin OTP y dentro de términos; sin evasión de controles; detener ante cualquier reto |
| Pausa del proyecto Free de Supabase o pérdida de datos | Baja | Alto | Cron anti-pausa; `pg_dump` diario a R2; pasar a Pro al go-live |
| Dependencia de n8n y su licencia en fase SaaS | Media | Medio | Lógica en Postgres; workflows exportados; consulta a license@n8n.io; posibilidad de migrar flujos críticos a Edge Functions o un worker propio |
| Fuga de datos sensibles (salud) | Baja | Muy alto (multas hasta el doble; reputación) | RLS, MFA, buckets privados, minimización hacia el LLM, BAA, auditoría, plan de respuesta a incidentes |
| Cambios regulatorios (SABG actualiza la ley, Meta cambia precios/políticas) | Alta | Bajo-medio | Revisión trimestral; parámetros configurables (gracia, retenciones, plazos) |
| Falta de adopción por la agente (vuelve al Excel) | Media | Alto | Móvil primero; importación completa; recordatorios que funcionen desde la semana 5; sesión semanal; recortar funciones antes que agregar |
| Tu tiempo disponible se reduce | Alta | Medio | Fases con valor entregado en cada corte; semana 8 ya es un producto útil; mantenimiento mensual acotado |
| Precios no verificados (⚠️) resultan distintos | Media | Bajo | Todos los rubros variables son < USD 10/mes; verificar en semana 1 |

## 2. Lo que este plan deliberadamente no hace

- Evasión de CAPTCHA, enmascaramiento de huellas de navegador o uso de servicios de resolución de retos de seguridad.
- WhatsApp no oficial (Baileys, Evolution API) con el número de la agente.
- Guardar credenciales de portales de aseguradoras en la base de datos del CRM.
- Enviar o solicitar información médica por WhatsApp.
- Prometer precios de terceros sin verificación (todo ⚠️ se revisa en la semana 1).

## 3. Camino a SaaS multi-tenant

Lo que ya queda hecho desde el MVP: `tenant_id` en todas las tablas, RLS, catálogos globales separados de datos del tenant, exportación por tenant, auditoría, consentimientos y ARCO por tenant, workflows parametrizados por `tenant_id`.

Lo que falta para vender (orden sugerido, después de la semana 20):

1. **Validación comercial:** 5 entrevistas con agentes de la red de tu esposa (AMASFAC local, promotoría). Pregunta clave: ¿pagarían MXN 400–600/mes por esto y qué les falta?
2. **Onboarding self-service:** registro, creación de tenant, importación desde Excel guiada, conexión de Gmail y WhatsApp con Embedded Signup propio (requiere que tú te registres como **Tech Provider** de Meta: verificación de negocio + app review).
3. **Facturación:** Stripe o Conekta (MXN, CFDI automático vía Facturama); planes por volumen de pólizas, no por usuario.
4. **Legal:** contrato SaaS con anexo de encargado, SLA, portabilidad y propiedad de cartera; aviso de privacidad propio del SaaS; términos; NOM-151 para evidencias; alta de actividad en SAT (RESICO sigue siendo viable bajo MXN 3.5 M).
5. **Operación:** Supabase Pro + compute Small; cola de trabajos en n8n (modo queue con workers) o migración de WF-03/05/06 a workers propios; Chatwoot multi-cuenta; monitoreo por tenant; soporte (WhatsApp + base de conocimiento).
6. **Seguridad:** pentest ligero, política de retención por tenant, ZDR con Anthropic por organización, revisión de RLS automatizada en CI.
7. **Producto diferenciador:** conciliación de comisiones multi-aseguradora, ingesta por correo con IA y asistente de WhatsApp incluidos en el plan base; sin mínimo de usuarios; exportación total en un clic. Es exactamente lo que la competencia cobra aparte o no tiene.

Hito de decisión: cuando 3 agentes externos lleven 60 días pagando y la conservación de cartera de tu esposa haya subido de forma medible, invertir en marca, página y canal de ventas. Antes de eso, no.
