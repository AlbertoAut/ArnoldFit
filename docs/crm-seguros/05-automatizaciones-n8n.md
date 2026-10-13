# 05 · Catálogo de automatizaciones (n8n)

n8n es el "sistema nervioso" del CRM: todo lo que ocurre sin que nadie dé clic pasa por aquí. La app web (Next.js + Supabase) es la cara; n8n son las manos. Cada flujo se versiona exportado como JSON en `n8n/workflows/` dentro del repositorio.

Principios de diseño que aplican a todos los flujos:

1. **Idempotencia.** Cada flujo que escribe en la BD lo hace con `upsert` sobre una clave natural (número de póliza + renovación, sha256 del documento, `wamid` del mensaje). Si el flujo se reejecuta, no duplica.
2. **Filtro de tenant explícito.** n8n usa la `service_role` key y por lo tanto salta RLS. Todo query lleva `where tenant_id = {{$env.TENANT_ID}}`. Cuando haya varios tenants, el flujo recibe el `tenant_id` como parámetro.
3. **Cola de revisión humana.** Nada extraído por IA entra como "aprobado". Entra como `POR_REVISAR` y la agente lo confirma en la app con un clic (o lo corrige). Cuando la precisión por aseguradora supere 98 % en 50 documentos consecutivos, ese tipo de documento puede pasar a auto-aprobación.
4. **Un workflow de errores.** `WF-00 Error Handler` recibe toda falla, la guarda en la tabla `auditoria` (acción `ERROR`) y avisa a la agente por WhatsApp/Telegram con el nombre del flujo y el registro afectado.
5. **Sin secretos en nodos.** Credenciales en el gestor de n8n; el `TENANT_ID`, URLs y tokens en variables de entorno.

## Mapa de flujos

| ID | Flujo | Disparador | Fase |
|----|-------|-----------|------|
| WF-00 | Error Handler global | Error de cualquier flujo | 1 |
| WF-01 | Ingesta de correo de aseguradoras | Gmail Trigger (etiqueta/filtro) | 1 |
| WF-02 | Ingesta de documentos por WhatsApp | WhatsApp Trigger (tipo document/image) | 2 |
| WF-03 | Clasificador + extractor IA de documentos | Webhook interno desde WF-01/02/app | 1 |
| WF-04 | Generador de recibos al aprobar una póliza | Supabase Database Webhook (`documentos.extraccion_estatus = APROBADA`) | 1 |
| WF-05 | Motor de recordatorios diario | Cron 08:00 America/Mexico_City | 1 |
| WF-06 | Envío WhatsApp (plantillas) + registro | Llamado por WF-05 y la app | 1 |
| WF-07 | Webhook de estados WhatsApp (sent/delivered/read/failed) | WhatsApp Trigger (statuses) | 1 |
| WF-08 | Bandeja de entrada WhatsApp + enrutador bot/humano | WhatsApp Trigger (messages) | 2 |
| WF-09 | Asistente IA (RAG) | Llamado por WF-08 | 2 |
| WF-10 | Conciliación de comisiones | Cron semanal + carga manual de estado de cuenta | 2 |
| WF-11 | Importación masiva desde Excel/CSV | Webhook desde la app (subida de archivo) | 1 |
| WF-12 | Resumen diario y semanal para la agente | Cron 07:30 y lunes 07:30 | 1 |
| WF-13 | Cumpleaños y fechas especiales | Cron 09:00 | 2 |
| WF-14 | Seguimiento de siniestros sin movimiento | Cron diario | 2 |
| WF-15 | Respaldo de BD y documentos | Cron 03:00 | 1 |
| WF-16 | Vencimiento de cédula y claves | Cron mensual | 2 |
| WF-17 | Solicitudes ARCO: acuse y recordatorio de plazo | Supabase webhook en `solicitudes_arco` | 2 |
| WF-18 | Exportación de datos del tenant (portabilidad) | Webhook desde la app | 3 |
| WF-19 | Descarga desatendida desde portales (RPA) | Cron nocturno por aseguradora | 3 (piloto) |
| WF-20 | Multicotizador autos (API/aggregador) | Webhook desde la app | 3 |

## Detalle de los flujos críticos

### WF-01 · Ingesta de correo de aseguradoras

La forma más barata y estable de recibir pólizas, recibos y estados de cuenta es el correo que las aseguradoras ya le mandan a la agente. No requiere scraping ni permiso de nadie.

1. **Gmail Trigger** (polling cada 5 min) sobre la etiqueta `CRM/Entrada`. Un filtro de Gmail etiqueta automáticamente todo correo cuyo remitente pertenezca a los dominios del catálogo `aseguradoras.dominios_email`.
2. **Switch por remitente** → asigna `aseguradora_id` provisional.
3. **Por cada adjunto** PDF/XML/XLSX: calcular `sha256`; `select` en `documentos`; si existe, terminar (idempotencia).
4. Subir a Supabase Storage (`documentos/{tenant}/{yyyy}/{mm}/{sha256}.pdf`), insertar en `documentos` con `origen = EMAIL`, `origen_ref = message-id`, `extraccion_estatus = PENDIENTE`.
5. Llamar a WF-03 con el `documento_id`.
6. Etiquetar el correo como `CRM/Procesado`.

Caso especial: correos sin adjunto pero con liga de descarga (algunas aseguradoras mandan "descarga tu póliza aquí"). En Fase 1 se crea una tarea manual para la agente; en Fase 3 lo resuelve WF-19.

### WF-03 · Clasificador + extractor IA

Dos llamadas al modelo, no una:

1. **Clasificación** (modelo barato, imagen de la página 1 o texto de la página 1): devuelve `{aseguradora, tipo_documento, ramo, confianza}`. Si la aseguradora del remitente y la detectada difieren, se marca para revisión.
2. **Extracción** con el JSON Schema del par `(tipo_documento, ramo)` usando salidas estructuradas. Prompt con 1-2 ejemplos reales de esa aseguradora (few-shot) almacenados en `prompts/{aseguradora}/{tipo}.md`.
3. **Validaciones deterministas** en un nodo Code: RFC (regex + fecha embebida), CURP, código postal de 5 dígitos, `vigencia_fin > vigencia_inicio`, `prima_total ≈ prima_neta + derecho + recargo + iva` (tolerancia 1 %), número de póliza con el patrón conocido de la aseguradora.
4. **Matching de contacto**: por RFC → por nombre normalizado (trigram ≥ 0.6) → si no hay match, se propone "crear contacto nuevo".
5. Guardar `extraccion` + `extraccion_confianza`; si todas las validaciones pasan y confianza ≥ 0.9 → `POR_REVISAR` con bandera "revisión rápida"; si no → `POR_REVISAR` con los campos dudosos resaltados.
6. Notificar a la agente: "Llegó la póliza 0123456 de Quálitas para Juan Pérez. Revisar →".

### WF-04 · Alta de póliza y generación de recibos

Cuando la agente aprueba la extracción en la app:

1. `upsert` en `contactos` (si era nuevo) y `polizas` (clave: aseguradora + número + renovación).
2. Si hay `poliza_anterior` (misma aseguradora, mismo número o mismo riesgo), marcar la anterior como `RENOVADA` y encadenar.
3. Generar recibos según `forma_pago`: anual = 1; semestral = 2; trimestral = 4; mensual = 12. `fecha_vencimiento` del recibo 1 = `vigencia_inicio`; siguientes, cada periodo. `dias_gracia` = 30 por defecto (configurable por aseguradora/ramo; en pago fraccionado algunas aplican 30 días solo al primer recibo, verificar por aseguradora).
4. Crear la comisión `ESPERADA` por recibo: `base = prima_neta / total_recibos`, `% = comision_pct`.
5. Programar en `envios_programados` los recordatorios según `reglas_recordatorio`.
6. Mandar al cliente (si tiene opt-in) la plantilla "Tu póliza quedó emitida" con el PDF de la carátula.

### WF-05 · Motor de recordatorios diario

Un solo cron a las 08:00 que evalúa reglas, no veinte crons sueltos.

```
para cada regla activa:
  calcular fecha_objetivo = hoy - dias_offset
  seleccionar objetivos (pólizas / recibos / contactos) cuya fecha de evento = fecha_objetivo
  excluir: no_contactar, sin opt-in (si el destinatario es CLIENTE), ya enviado (envios_programados)
  insertar envios_programados PENDIENTE
para cada envío PENDIENTE de hoy:
  llamar WF-06 → actualizar estatus
```

Reglas por defecto (ajustables en la app):

| Evento | Offsets | Destinatario | Plantilla |
|--------|---------|--------------|-----------|
| Vencimiento de póliza (renovación) | −45 (solo agente), −30, −15, −7, 0 | Cliente + agente | `renovacion_30d`, `renovacion_7d`… |
| Vencimiento de recibo | −7, −1, +1 | Cliente | `recibo_por_vencer`, `recibo_vencido` |
| Fin de periodo de gracia | −5, −1 | Cliente + agente | `fin_gracia` (tono urgente) |
| Cumpleaños | 0 | Cliente | `cumpleanos` (marketing según Meta) |
| Cédula del agente | −60, −30 | Agente | interno |
| Siniestro sin movimiento | +5 días sin actividad | Agente | interno |

### WF-06 · Envío de WhatsApp con plantilla

1. Verificar que la plantilla esté `APPROVED` en `plantillas_mensaje`.
2. Resolver variables (`{{1}}` nombre, `{{2}}` póliza, `{{3}}` fecha…).
3. Si el cliente escribió en las últimas 24 h, se puede mandar texto libre (gratis); si no, plantilla (de pago).
4. Enviar con el nodo *WhatsApp Business Cloud*; guardar `mensajes` con `wamid`, categoría y costo estimado.
5. Error 131026/131047 (sin opt-in / fuera de ventana) → registrar y crear tarea para la agente.

### WF-08 / WF-09 · Bandeja y asistente IA

1. Mensaje entrante → `upsert conversaciones` (abre ventana de 24 h), `insert mensajes`.
2. Si `modo = HUMANO` o el contacto está en una conversación escalada en las últimas 2 h → solo notificar a la agente.
3. Si el mensaje es audio → transcribir primero.
4. Detección de intención (modelo barato): `siniestro`, `pago`, `cotizacion`, `documento`, `renovacion`, `queja`, `otro`.
5. `siniestro`, `queja` y cualquier cosa con tono de urgencia → **handoff inmediato**: respuesta corta de contención ("Ya avisé a {agente}, te contacta en breve. Si es emergencia llama a {cabina aseguradora}") + alerta a la agente + `modo = HUMANO`.
6. Resto → WF-09: recupera contexto del cliente (pólizas vigentes, recibos pendientes), chunks relevantes de condiciones generales (pgvector), y responde citando la póliza. Nunca afirma cobertura sin cita; si no encuentra, dice que la agente confirmará.
7. Botón "Hablar con {agente}" siempre disponible (mensaje interactivo).

### WF-10 · Conciliación de comisiones

1. Entrada: estado de cuenta de comisiones (PDF/Excel) por correo o carga manual.
2. Extracción IA a una tabla normalizada: `{numero_poliza, recibo, prima, pct, comision, fecha}`.
3. Matching contra `comisiones` esperadas por `numero_poliza` + periodo. Marca `PAGADA` cuando coincide (±1 %), `DIFERENCIA` cuando no, `NO_RECONOCIDA` cuando la aseguradora reporta algo que el CRM no tiene (señal de póliza faltante).
4. Reporte semanal: total esperado vs. pagado por aseguradora, diferencias a reclamar.

### WF-11 · Importación desde Excel

1. La agente sube el CSV con la plantilla `anexos/plantilla-importacion-excel.csv`.
2. Validación fila por fila (misma lógica que WF-03) → reporte de errores descargable.
3. Vista previa en la app → confirmación → `upsert` masivo → generación de recibos (WF-04) sin disparar mensajes a clientes (bandera `silencioso = true` en la carga inicial).

### WF-15 · Respaldos

- `pg_dump` lógico diario (Supabase Pro ya incluye respaldos; aun así se guarda una copia propia) cifrado con `age` y subido a Cloudflare R2 / Backblaze B2 en otra cuenta.
- Sincronización semanal del bucket `documentos` a R2 con `rclone`.
- Prueba de restauración trimestral (tarea calendarizada para la agente/tú).

## Convenciones del repositorio

```
n8n/
  workflows/WF-01-ingesta-correo.json
  workflows/...
  prompts/
    clasificador.md
    gnp/caratula-gmm.md
    qualitas/caratula-autos.md
    ...
  schemas/            # JSON Schema por (tipo_documento, ramo)
    caratula.autos.json
    caratula.gmm.json
    recibo.json
    estado-cuenta-comisiones.json
```
