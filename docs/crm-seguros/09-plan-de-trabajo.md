# 09 · Plan de trabajo

Horizonte: **20 semanas** en tres fases más una fase 0 de preparación. El MVP útil para la agente se entrega en la **semana 8**. Cada semana tiene entregables verificables; si una semana se atrasa, se recorta alcance de la siguiente, no calidad del núcleo.

Supuestos: trabajas tú solo, 12–20 horas semanales; la agente dedica 1–2 horas semanales a validar, probar y dar retroalimentación; asistentes de código IA para el frontend.

## Fase 0 · Preparación (semana 1)

**Objetivo:** cuentas, repositorio, decisiones cerradas, muestrario de documentos.

| # | Tarea | Responsable | Entregable |
|---|---|---|---|
| 0.1 | Sesión de descubrimiento con la agente (2 h): sus 6+ aseguradoras, ramos por aseguradora, cómo cobra comisiones, cómo lleva hoy la cartera (Excel), qué correos recibe, qué portales usa, dolores principales | Tú + agente | Acta con prioridades y lista de aseguradoras/claves |
| 0.2 | Entregarle el `anexos/checklist-agente.md`: por aseguradora anotar portal, OTP sí/no, formato de estado de cuenta, quién timbra CFDI, guardar 3 correos de muestra por tipo y un PDF de cada documento | Agente | Carpeta `muestras/` con ≥ 20 documentos reales |
| 0.3 | Exportar su Excel actual y mapearlo a `anexos/plantilla-importacion-excel.csv` | Tú + agente | CSV listo para importar |
| 0.4 | Crear cuentas: Supabase (dev + prod), Cloudflare (dominio, Pages, R2, Tunnel), VPS, Anthropic (org dedicada + BAA), Resend, Bitwarden (organización de 2), Better Stack, Sentry, Meta Business (portafolio, método de pago), Kapso | Tú | Credenciales en Bitwarden; `.env` de dev |
| 0.5 | Repositorio monorepo con la estructura de `02-arquitectura.md`; CI mínimo (lint + `supabase db lint`) | Tú | Repo con `main` protegido |
| 0.6 | Verificar elegibilidad de coexistencia de WhatsApp: ¿su número está en WhatsApp Business App actualizada? ¿Cuánto tiempo lleva? Si está en WhatsApp personal, migrar a Business App esta semana | Agente | Decisión: coexistencia o segundo número |
| 0.7 | Verificar precios marcados ⚠️ en `08-costos.md` (15 minutos abriendo páginas oficiales) | Tú | Tabla de costos actualizada |

**Criterio de salida:** muestrario recibido, CSV mapeado, cuentas creadas, decisión de WhatsApp tomada.

## Fase 1 · MVP núcleo (semanas 2–8)

**Objetivo:** que la agente deje el Excel. Clientes, pólizas, recibos, renovaciones y cobranza con recordatorios por WhatsApp; ingesta de carátulas por correo con IA; PWA móvil.

### Semana 2 · Base de datos y catálogos
- Migración `0001_inicial` (= `anexos/schema.sql`) en dev; políticas RLS; función `current_tenant_id()`.
- Semillas: aseguradoras (con dominios de correo y teléfonos), productos de sus 6+ aseguradoras, ramos, reglas de recordatorio por defecto, plantillas.
- Test de aislamiento: dos tenants, dos usuarios, consultas cruzadas deben devolver 0 filas.
- Borrador del aviso de privacidad (integral/simplificado/corto) a partir de los Lineamientos; enviar a revisión legal.
- **Entregable:** BD en dev con datos semilla y test RLS pasando.

### Semana 3 · Importación desde Excel y PWA v0
- WF-11 importación: validación fila por fila, reporte de errores, vista previa, upsert silencioso, generación de recibos.
- Importar la cartera real de la agente en dev; revisar juntos 20 pólizas al azar.
- PWA v0 (Next.js + Supabase Auth con MFA): login, lista de clientes con búsqueda, ficha de cliente con pólizas, ficha de póliza con recibos. Solo lectura.
- Someter plantillas de WhatsApp a aprobación en Meta (tarda minutos a 48 h).
- **Entregable:** su cartera completa visible desde el celular.

### Semana 4 · Ingesta por correo e IA (parte 1)
- WF-00 error handler; WF-01 Gmail → Storage → `documentos`.
- WF-03 clasificador + extractor con los esquemas de carátula de autos y GMM (sus ramos de mayor volumen) y recibo; validaciones; matching de contacto.
- Pantalla de revisión en la PWA (PDF + campos + semáforo de confianza + botón Aprobar).
- Probar con las ≥ 20 muestras reales; medir precisión por campo; ajustar prompts/few-shots.
- **Entregable:** 20 documentos reales procesados con ≥ 90 % de campos correctos antes de revisión.

### Semana 5 · Alta de pólizas, recibos y recordatorios
- WF-04 alta de póliza al aprobar (encadenar renovaciones, recibos según forma de pago, comisiones esperadas, envíos programados).
- WF-05 motor de recordatorios + WF-06 envío de plantillas + WF-07 estados de entrega.
- Conectar WhatsApp (coexistencia vía Kapso o número dedicado); mandar los primeros recordatorios **solo a la agente** (modo ensayo) durante una semana.
- Pantalla "Hoy": renovaciones próximas, recibos por vencer, en gracia, tareas.
- **Entregable:** recordatorios reales llegando al teléfono de la agente con los datos correctos.

### Semana 6 · Cobranza, consentimientos y seguridad
- Pantalla Cobranza (`v_cobranza` con semáforo), marcar recibo pagado desde el celular (con foto del comprobante opcional), reprogramar.
- Flujo de consentimiento con OTP y campaña de opt-in a la cartera desde su teléfono; registro de evidencias.
- Respaldos (WF-15) + prueba de restauración; Cloudflare Tunnel + Access para n8n; Sentry y Better Stack conectados; documento de medidas de seguridad.
- Esquemas de carátula de vida, daños y fianzas; endosos.
- **Entregable:** go-live técnico en prod con datos reales; opt-ins recibidos.

### Semana 7 · Operación asistida
- La agente usa el sistema a diario con tu acompañamiento; los recordatorios a clientes se activan por ramo conforme aprueba las plantillas (empezar por recibos de autos).
- WF-12 resumen diario y semanal.
- Correcciones de UX a partir de su uso real (lista corta, máximo 10 cambios).
- Cargar condiciones generales de sus productos principales en Storage (insumo del asistente de Fase 2).
- **Entregable:** 5 días consecutivos de uso sin bloqueos.

### Semana 8 · Cierre del MVP
- Checklist de go-live de `07-legal-y-cumplimiento.md` completado.
- Subir Supabase a Pro si ella ya depende del sistema.
- Retrospectiva: qué automatización le ahorró más tiempo, qué falta.
- **Criterio de éxito del MVP:** cero pólizas gestionadas fuera del CRM; 100 % de recibos del mes con recordatorio enviado; ≥ 80 % de carátulas nuevas entrando por correo sin captura manual; tiempo de alta de póliza < 2 minutos.

## Fase 2 · Operación completa (semanas 9–14)

**Objetivo:** comisiones conciliadas, asistente de WhatsApp, siniestros, pipeline de ventas.

| Semana | Entregables |
|---|---|
| 9 | **Comisiones**: esquema de estado de cuenta por aseguradora; WF-10 conciliación; parámetros de retención por aseguradora (con el contador); tablero esperado vs pagado vs diferencia; exportación mensual CSV + XML. Decisión: Descarga Masiva SAT con `satcfdi` o ZIP del contador. |
| 10 | **Siniestros**: alta desde la PWA y desde WhatsApp (handoff), checklist por tipo y aseguradora, estados, alertas de SLA (carta pase 5 d.h., pago 30 días) y de prescripción; WF-14 sin movimiento. Catálogo de teléfonos de cabina por aseguradora. |
| 11 | **Asistente IA v1**: WF-08 bandeja/enrutador, WF-09 RAG; indexar condiciones generales de 5–10 productos; set de evaluación de 60 conversaciones con la agente; intenciones críticas con handoff. Encender solo para 10 clientes de confianza. |
| 12 | **Asistente IA v2**: voz (transcripción), documentos entrantes por WhatsApp (WF-02 → pipeline IA → acuse), WhatsApp Flows o guion para recopilar datos de cotización; ampliar a toda la cartera con opt-in. Chatwoot si hace falta bandeja. |
| 13 | **Ventas**: oportunidades (Kanban), cotizaciones con comparativo PDF simple, referidos, cumpleaños (WF-13), cross-sell sugerido por reglas (autos sin GMM, GMM sin vida). Google Calendar. |
| 14 | **Cumplimiento y datos**: módulo ARCO completo (WF-17), bloqueo/supresión programada, exportación total del tenant (WF-18), alertas de cédula (WF-16), expediente KYC con vigencias. Revisión legal final. |

**Criterio de éxito Fase 2:** diferencias de comisión detectadas y reclamadas en el mes; ≥ 60 % de mensajes entrantes resueltos por el asistente sin intervención; ningún siniestro sin seguimiento > 5 días.

## Fase 3 · Pilotos de expansión (semanas 15–20)

Se eligen según lo que más tiempo le siga quitando a la agente; no se hacen los tres a la vez.

| Piloto | Alcance | Criterio para continuar |
|---|---|---|
| **RPA acotado (WF-19)** | 1–2 aseguradoras sin OTP, con términos de uso revisados; Playwright con perfil persistente; solo descarga de pólizas y estados de cuenta de su clave; se detiene ante cualquier reto de seguridad y crea tarea manual | 4 semanas sin bloqueos ni cambios de DOM que requieran más de 1 h/mes de mantenimiento |
| **Multicotizador autos (WF-20)** | Contactar Dora / BBVA API Market / Guros: claves propias, costo por emisión, PDF de carátula; integrar el que acepte | Cotizar en < 3 minutos con ≥ 3 aseguradoras y comisión completa para ella |
| **Portal de cliente** | Página pública por cliente con liga firmada: sus pólizas, recibos, descargar carátulas, reportar siniestro, actualizar datos | ≥ 30 % de clientes lo usan en 60 días |
| **Preparación SaaS** | Segundo tenant de prueba (un colega agente), onboarding self-service, página de marketing, contrato SaaS con anexo de encargado, facturación con Stripe/Conekta, carta a license@n8n.io | Un agente externo operando 30 días pagando |

## Cadencia y gobierno

- **Diario (tú):** revisar WF-00 (errores) y la cola de revisión.
- **Semanal (tú + agente, 30 min):** qué falló, qué le quitó tiempo, qué sigue; actualizar este plan.
- **Mensual:** costo real vs presupuesto (`08-costos.md`), precisión de extracción por aseguradora, conservación de cartera, comisiones conciliadas.
- **Trimestral:** prueba de restauración de respaldo, rotación de tokens, revisión de prompts y plantillas, revisión de cambios regulatorios (SABG, Meta pricing).

## Definición de "hecho" para cualquier entregable

1. Migración o workflow en el repositorio.
2. Probado con datos reales de la agente (anonimizados en dev).
3. Filtra por `tenant_id`; pasa el test de aislamiento.
4. Registra en `auditoria` si toca datos personales o dinero.
5. Tiene manejo de error hacia WF-00.
6. Documentado en una línea en el README del módulo.
