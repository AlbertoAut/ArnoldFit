# Investigación · Dominio operativo del agente y benchmark competitivo

**Fecha: 2026-10-13.** [C] = confirmado en fuente citada · [I] = inferido de práctica de mercado, pendiente de verificar. Limitación: no se pudieron abrir winsef.com/paquetes, softseguros.com/precios, sicasonline.net, ukuvi.ai/precios; cifras vía extractos de búsqueda.

## 1. Economía de comisiones por ramo (% sobre prima neta)

| Ramo / producto | 1er año | Renovación | Estado | Fuente |
|---|---|---|---|---|
| Autos individual | 10–25 % | 10–25 % (frecuentemente igual) | [C] | figuro.la; goagentes.mx/blog/tabla-de-comisiones-agentes-de-seguros/ |
| Vida individual | 30–50 % (anuncios de promotoría MetLife: "desde 56 %") | 2–10 % | [C] | segurosmexico.mx (2026); mx.indeed.com |
| Vida temporal | 25–40 % | 5–10 % años 2–5 | [I] | |
| Vida ordinario / entera | 40–90 % de la prima objetivo del 1er año | 2–10 % | [I] | |
| Dotal / educacional | 20–35 % | 2–5 % | [I] | |
| Inversión / PPR | 2–10 % de la aportación | 1–3 % | [I] | |
| GMM individual | 15–25 % (blogs dicen 30–50 % agrupando vida+GMM) | 10–15 %, casi permanente | [C]/[I] | goagentes.mx |
| Daños hogar | 15–25 % | igual | [I] | |
| Daños PyME | 10–20 % | igual | [I] | |
| Fianzas | 20–30 % (administrativas 25–35 %, fidelidad 15–25 %) | igual | [I] | |

Marco [C]: la LISF no establece topes; cada aseguradora fija porcentajes confidenciales. Los bonos pueden ser hasta un tercio del ingreso anual.

**Mecánica de pago:** comisión por **recibo pagado** (no al emitir) → `Comisión` cuelga de `Recibo`/`Pago`. LISF art. 99 [C]: el agente solo cobra primas contra recibo oficial y entrega en 10 días hábiles. Estados de cuenta semanales/quincenales; pago 7–15 días tras aplicar el recibo [I]. **Clawback** [I]: al cancelar con devolución de prima no devengada, la aseguradora carga la comisión no devengada en el siguiente estado de cuenta; en vida, cancelación en 12–24 meses genera cargo proporcional. **Comisión diferida/anticipada** [I] en vida: modelar `tipo` ∈ {primer_año, renovación, diferida, bono, cargo}.

**Bonos [I salvo indicación]:** producción (2–10 % extra por escalones de prima nueva pagada), conservación (≥80–85 % autos; ≥85–90 % vida 13º/25º mes), crecimiento (+10–20 %), siniestralidad (<50–60 %), convención (p. ej. 120 % de cuota [C estoytranqui.mx]). Fiscalmente son ingresos del mes de cobro [C]. ⇒ El CRM necesita metas configurables por aseguradora/ramo y un tablero "¿cuánto me falta para el bono?".

## 2. Ciclo de vida de la póliza

| Tema | Regla | Estado |
|---|---|---|
| Forma de pago | anual/semestral/trimestral/mensual; recargo por pago fraccionado 3–8 % [I]; medios: cargo recurrente TDC/TDD, referencia/ventanilla, transferencia, conducto agente | |
| **Periodo de gracia** | LCS art. 40: si no se paga la prima o la primera fracción dentro del plazo convenido, los efectos cesan automáticamente a las 12:00 h del último día del plazo; plazo pactado entre 3 y 30 días naturales; a falta de pacto, 30. **SCJN 2010:** la gracia aplica también a las fracciones subsecuentes. | [C] ordenjuridico.gob.mx; internet2.scjn.gob.mx/red2/comunicados/comunicado.asp?id=1957 |
| Cancelación por falta de pago | automática al vencer la gracia; endoso de cancelación; cargo de comisión | [C]/[I] |
| Rehabilitación | autos/daños: se emite póliza nueva; vida: solicitud con primas vencidas + intereses + nueva declaración de salud (hasta 2–5 años); GMM: 30–60 días, con pérdida de antigüedad si excede | [I] |
| Renovación | autos: renovación automática ~30 días antes con recibo nuevo; GMM: renovación garantizada con nueva prima por edad (aumento exponencial desde los 40); vida: vigencia plurianual con recibos anuales; hogar: automática; PyME/fianzas: requiere cotización | [I]/[C] |
| Endosos | **A** aumenta prima; **B** disminuye prima/devolución; **C** corrección de datos sin cambio de prima (o cancelación según guía); **D** disminución por cambio de condiciones | [C] ahorraseguros.mx; dorama.mx |
| GMM | deducible fijo (MXN/UDI/USD), coaseguro 10–20 % con **tope**, nivel hospitalario (+30 % coaseguro en nivel superior) | [C] segurosatlas.com.mx; bbva.mx |
| Moneda | MXN, USD, UDI | [I] |
| Roles | Contratante (paga) · Asegurado (titular + dependientes) · Beneficiario (% y revocable/irrevocable) · Conductor · Fiado/Beneficiario/Obligado solidario | [I] |
| Prescripción | LCS art. 81: 2 años; 5 años en fallecimiento de vida. Pago: art. 71, 30 días tras documentación completa | [C] |

## 3. Siniestros por ramo

| Ramo | Rol del agente | Documentos | Tiempos | Fuente |
|---|---|---|---|---|
| **Autos** | Reporte a cabina; ajustador (SURA 30–45 min [C]); no reconocer responsabilidad (AXA [C]); Declaración Universal de Accidente AMIS; orden a taller (AXA: ≤2 años → agencia); deducible % en carátula; pérdida total si reparación > 50 % SA [C]; robo: acta MP | Carátula, licencia, tarjeta de circulación, INE, factura original (PT/robo), tenencias, baja de placas, finiquito, CLABE | PT/robo 15–30 días tras expediente [I]; LCS 71: 30 días [C] | axa.mx; segurossura.com.mx; tumomento.com |
| **GMM** | Cirugía programada: solicitar ≥8 días hábiles antes; respuesta 5 días hábiles con **carta pase** enviada al agente [C]; carta vence a 30 días; pago directo solo en convenio; urgencia: notificar en 48 h; reembolso para consultas/estudios/medicamentos | Informe médico (≤3 meses), formato de reclamación, aviso de accidente/enfermedad, INE, CFDI a nombre del titular, recetas, estudios, CLABE | Carta pase 5 d.h.; reembolso 10–20 d.h. [I] | zurich (guía 03/2024); bbva.mx; segurosbanorte; segurosatlas; aig.com.mx |
| **Vida** | Localizar póliza y beneficiarios, armar expediente, acompañar; si no se ubica póliza → SIAB-Vida CONDUSEF (~30 d.h.); rechazo → CONDUSEF | Acta de defunción, INE y CURP del beneficiario, comprobante de domicilio, formato de reclamación, acta de nacimiento, certificado médico, actuación MP si violenta | 30 días (art. 71); prescripción 5 años | adn40.mx; bbva.mx |
| **Daños** | Reporte, ajustador, inventario, cotizaciones, deducible por cobertura | Facturas, fotos, acta MP, dictamen, presupuestos | 30 días | [I] |
| **Fianzas** | Reclamación del beneficiario; coordinar respuesta del fiado; recuperación | Contrato, requerimiento, evidencia | — | [I] |

Diseño del módulo: checklist por tipo editable por aseguradora; estados reportado → ajustador → valuación/hospital → documentación → dictamen → pagado/rechazado → CONDUSEF; recordatorios de SLA (5 d.h. carta pase, 30 días art. 71); registro de deducible/coaseguro; bitácora.

## 4. Flujo de trabajo diario
- **Hoy:** Excel/Google Sheets; "se rompe con el volumen" (xpertix.com); Excel "no emite alertas ni centraliza comunicación" (neopoliza.com); sistema 30-60-90 de figuro.la para hasta 100–150 renovaciones/mes [C].
- **Columnas típicas del Excel [I]:** Cliente | Teléfono | Email | Aseguradora | Ramo | No. póliza | Inicio | Fin | Forma de pago | Prima total | Prima neta | Próximo recibo | Estatus pago | Comisión % | Comisión $ | Cumpleaños | Observaciones | Renovó | Fecha de contacto.
- **Rutina:** 30 días (llega renovación; revisar incremento; recotizar si > 15–20 %), 15 días (envío por WhatsApp), 7 días (recordatorio), vencimiento/gracia (llamada). Cobranza mensual de cargos rechazados. Cumpleaños y aniversario como pretexto de cross-sell (autos → GMM/hogar; GMM → vida; vida → PPR; PyME → fianzas). Referidos tras entregar póliza o resolver siniestro.
- **KPIs:** conservación = renovadas ÷ vencidas (agentes reactivos 40–60 % [C figuro]); prima emitida vs pagada; pólizas vigentes; comisiones por aseguradora/ramo; pólizas por cliente; siniestralidad; pipeline; avance a convención.
- **Dolores [C]:** renovaciones perdidas por falta de proceso; información dispersa en correo/Excel/WhatsApp; conciliar comisiones. AMASFAC: ~65,000 agentes en México, ~3,500 asociados.

## 5. Benchmark competitivo 2026

| Producto | Precio | Estado | Fuente |
|---|---|---|---|
| **Softseguros** | USD 380/usuario/año, **mínimo 2 usuarios (USD 760/año)**; <3 usuarios: 1 línea WA, 100 PDF, 10 GB; ≥3 usuarios: marca blanca + módulo Comercial (agentes IA) sin costo extra; lector de pólizas con IA anunciado sin precio | [C] | softseguros.com/precios-softseguros/ ; /preguntas-frecuentes/ |
| **Winsef** | Startup/Advance/Ultra; **montos no visibles en extracto**; Startup incluye pólizas y endosos (1 GB), cobranza, clientes, siniestros, conciliación de comisiones, WhatsApp, dashboard; sin plazo forzoso | [C] módulos / **precio NO verificado** (investigación previa: MXN 650–5,000/mes) | winsef.com/paquetes/ |
| **SICAS Online** | Corredor: semestral $3,995.04, anual **$7,990.08**; Corredor/Máster/Multipromotor: anual **$9,765.00** (IVA incl.); licencia Agente adicional $484/mes | [C] (moneda MXN [I]) | sicasonline.net |
| SICAS Lite | app iOS/Android; precio no obtenido | — | sicaslite.net |
| **Ukuvi** | CRM, multicotizador, cartera, app, landing, conectividad; enfoque promotorías; precio no obtenido | — | ukuvi.ai |
| Clericot | sin resultados | — | |
| Mercadito Software | licencia anual ≈ $3,700 MXN | [C] | mercaditosoftware.com |
| Figuro | gratis para empezar; planes desde USD 5/mes | [C] autopromoción | figuro.la |
| YoAgente, Neopoliza, Renova, Xpertix | alternativas 2026; precios no obtenidos | — | |

**Matriz (✔ confirmado · ◐ probable · ? sin dato · ✖ no):**

| Funcionalidad | Softseguros | Winsef | SICAS | Ukuvi | Mercadito |
|---|---|---|---|---|---|
| Clientes 360 | ✔ | ✔ | ✔ | ✔ | ✔ |
| Pólizas multirramo | ✔ | ✔ | ✔ | ✔ | ✔ |
| Recibos / cobranza | ✔ | ✔ | ✔ | ◐ | ✔ |
| Comisiones y conciliación | ✔ | ✔ | ✔ | ◐ | ◐ |
| Renovaciones / alertas | ✔ | ✔ | ✔ | ◐ | ◐ |
| Siniestros | ✔ | ✔ | ✔ | ? | ? |
| WhatsApp | ✔ | ✔ | ◐ | ◐ | ✖ |
| OCR / IA carátulas | ✔ (anunciado) | ? | ? | ? | ✖ |
| Multicotizador | ? | ? | ? | ✔ | ✖ |
| Portal cliente | ◐ | ? | ✔ | ◐ | ✖ |
| App móvil | ◐ | ◐ | ◐ | ✔ | ✖ |
| Importación Excel | ◐ | ◐ | ◐ | ◐ | ◐ |
| API | ? | ? | ? | ◐ | ✖ |
| **MXN/mes, 1 usuario** | ≈ $1,170 (mín. 2 usuarios) | n/d | ≈ $666–814 | n/d | ≈ $308 |

**Buy vs build para 150 clientes:** comprar cuesta entre **$3,000 y $14,000 MXN/año**. El valor de construir está en (a) conciliación de comisiones y bonos por aseguradora, (b) ingestión automática de carátulas por correo + IA, (c) WhatsApp integrado a cobranza/renovación, funciones que los productos existentes cobran como add-on o restringen por usuarios; y en la opción de convertirlo en SaaS.

## 6. Obligaciones regulatorias que el CRM debe soportar
| Obligación | Detalle | Fuente |
|---|---|---|
| Marco | Reglamento de Agentes de Seguros y de Fianzas; LISF arts. 91–105; CUSF Título 31; sanciones art. 506 LISF | revistasiniestro.com.mx (2022-01-07); goagentes.mx |
| Cédula vigente | Identificarse con cédula CNSF vigente (digital); **refrendo dentro de los 60 días naturales previos** al vencimiento | cnsf.gob.mx FAQ SICREP; infobae 2025-03-26 |
| Seguro de RC E&O | Contratar y mantener vigente | cnsf.gob.mx |
| Fianza de fidelidad / contrato de intermediación | Requisito de alta con aseguradoras | servicios.metlife.com.mx (checklist) |
| Conducta | Evaluar necesidades del interesado; no cobrar primas sin recibo oficial; entregar primas en 10 días hábiles | LISF 99 |
| Aviso de privacidad | El agente es responsable del tratamiento (incl. datos de salud) | [I] |
| Conocimiento del cliente / PLD | LISF 492 obliga a instituciones; las aseguradoras trasladan al agente el formato de conocimiento del cliente (identificación, actividad, origen de recursos, PEP, propietario real) en vida/inversión y primas altas | [C]/[I] |
| CONDUSEF | SIAB-Vida; reclamaciones; Buró de Entidades Financieras | adn40.mx |

**Implicación CRM:** checklist de expediente por cliente (INE, CURP, comprobante de domicilio, aviso de privacidad firmado, formato de conocimiento del cliente); alertas de cédula/refrendo/E&O; registro de entrega de documentos al cliente.

## 7. Pendientes de segunda ronda
1. Montos de Winsef, SICAS Lite, Ukuvi, Clericot, Alogestor Hub, Dora, Segurify, Polizas.app.
2. Tarifarios de comisión por aseguradora (manuales de agente) y reglas de bonos.
3. Condiciones generales de GMM individual y vida (rehabilitación, antigüedad).
4. Foros de agentes para columnas reales de Excel.
