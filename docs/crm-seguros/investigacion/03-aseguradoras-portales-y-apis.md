# Investigación · Portales y APIs de aseguradoras mexicanas

**Fecha: 2026-10-13.** Marcas: ✅ CONFIRMADO (fuente con URL) · 🟡 INFERIDO (fuente secundaria o práctica habitual, verificar) · ❓ DESCONOCIDO (sin información pública). Limitación: el entorno de investigación no pudo abrir los sitios oficiales; muchas descripciones de portales provienen de un comparador no oficial (ahorraseguros.mx). **La verificación final la hace la agente desde sus propios portales (checklist en §7).**

## 1. Puntos de contacto digitales para agentes

| Aseguradora | Ramos | Portal de agentes | Descarga PDF/Excel | Email al agente | API | Notas |
|---|---|---|---|---|---|---|
| **Quálitas** | Autos | ✅ "Portal Agentes 360" | 🟡 pólizas y recibos sí; edo. cta. comisiones ❓ | 🟡 copia de emisión | 🟡 WS de cotización/emisión usado por multicotizadores con contrato; sin doc pública | Apps ✅ "Soy Agente Q" y "QSuscripción" (iOS); QMóvil es para clientes. Fuente: ahorraseguros.mx/blog/qualitas-portal-agentes-360/ |
| **GNP** | Autos, Vida, GMM, Daños | ✅ Portal de intermediarios (cotizador, objetivos) `intermediarios.gnp.com.mx` 🟡 | ❓ | ❓ | ❓ | ✅ "App de Agentes GNP" citada en 2024 (anuariolatamseguros.com). "Soy Cliente GNP" (ex GNP Conecta) es de clientes |
| **AXA México** | Autos, GMM, Vida, Daños | ✅ `distribuidores.axa.com.mx` (aloja "Oferta de Valor 2024" con bandas de bonos) | ❓ | ❓ | ❓ | |
| **HDI Seguros** | Autos, Daños, GMM | 🟡 hdi.com.mx → "Ingreso Agentes": cartera, formatos, cotizadores, descargas, circulares | 🟡 sí | ❓ | ❓ | ✅ May-2026: HDI acordó adquirir Afirme Seguros → el portal de Afirme puede migrar |
| **MetLife México** | Vida, GMM, AP | ✅ Portal de fuerza de ventas "Acceso a Agentes" (manual 2009) | ❓ | ❓ | ❓ | |
| **Seguros Monterrey NYL** | Vida, GMM | ❓ | ❓ | ❓ | ❓ | |
| **MAPFRE** | Autos, Daños, Vida, GMM | ❓ (🟡 oficina virtual tipo Tronweb) | ❓ | ❓ | ❓ | |
| **Chubb** | Daños, Autos, AP, Caución | ✅ **Chubbnet** (chubb.com/mx-es/brokers-agents-agencies.html) | ❓ | ❓ | ❓ | |
| **Zurich** | Autos, Daños, Vida | ✅ `agentes.zurich.com.mx` con T&C publicados | ❓ | ❓ | ❓ | ✅ sección "DatosFiscalesCFDI" → captura de datos fiscales en línea 🟡 |
| **Allianz** | Vida, Daños, GMM | ✅ **MyAllianz** con "Cuaderno de comisiones" | 🟡 | ❓ | ❓ | ✅ App Allianz DAF para agentes; correos @allianz.com.mx |
| **Banorte** | Autos, Vida, GMM, Daños | ❓ | ❓ | ❓ | ❓ | |
| **Inbursa** | Autos, Vida, GMM, Daños | 🟡 Portal de intermediarios: cartera, calendario de vencimientos, cotizadores | ❓ | ❓ | ❓ | |
| **Atlas** | Autos, Daños, GMM, Vida | 🟡 "Acceso Agentes": cotizador, siniestros, Atlas Digital | ❓ | ❓ | ❓ | |
| **SURA** | Autos, Daños, GMM, Vida | ❓ | ❓ | ❓ | ❓ | |
| **Plan Seguro** | GMM | ❓ | ❓ | ❓ | ❓ | |
| **Bupa** | GMM | ✅ "Manual del Agente Bupa México V8-ene-2024" con secciones de pago de comisiones y portal de servicios en línea | 🟡 | ❓ | ❓ | Leer el manual: bupasalud.com.mx/system/files/2025-04/documentos/privados/Manual_Agente_BUPA_2024_vf.pdf |
| **ANA Seguros** | Autos | 🟡 Portal con "Honorarios y comisiones del mes", línea de captura, reportes | 🟡 | ❓ | ❓ | |
| **Afirme** | Autos, Daños, Vida | 🟡 Portal: trámites, cartera, cotizadores, incentivos | ❓ | ❓ | ❓ | En adquisición por HDI |
| General de Seguros, El Potosí, Sofimex, Aserta/Insurgentes, Liberty Fianzas | varios / fianzas | ❓ | ❓ | ❓ | ❓ | Aserta e Insurgentes operan como aseguradoras de caución desde 2017/18 |

**Conclusiones:**
1. **Ninguna aseguradora mexicana publica una API abierta para agentes individuales.** Existen web services B2B (Quálitas, GNP, AXA, HDI…) expuestos a multicotizadores, promotorías y brokers con contrato.
2. Los portales son casi todos usuario/contraseña; no hay evidencia pública sobre 2FA/captcha (❓). La agente puede verificarlo en 5 minutos por portal.
3. **Lo que define el parser del CRM son los documentos reales:** descargar un ejemplo de cada tipo (carátula, recibo, estado de cuenta de comisiones) por aseguradora.

## 2. Multicotizadores / agregadores con API para agentes

| Plataforma | Confirmado | API / white-label | Costo | ¿Claves propias? |
|---|---|---|---|---|
| **Dora (dora.com.mx)** | ✅ Cotizador y gestor de autos; white-label con API de catálogo, cotización y emisión (perfil Dealroom) | Sí | ❓ | 🟡 normalmente sí |
| **Guros** | ✅ Insurtech MX que compara 8 aseguradoras; API para socios en desarrollo | Partner API | ❓ | ❓ |
| **BBVA API Market – Auto Insurance MX** | ✅ API para cotizar y emitir auto; "solo pueden emitir agentes" (bbvaapimarket.com/en/banking-apis/mx-auto-insurance) | Sí | ❓ | Sí |
| Agentemotor | ✅ cotizador + CRM; ficha dice "no disponible en México" (contradictorio) | ❓ | ❓ | ❓ |
| Rastreator.mx | ✅ directo al consumidor, sin agentes | No | — | — |
| Interprotección | ✅ broker; plataforma para externos ❓ | ❓ | ❓ | ❓ |
| Kipo, Zenda, Segurify, Wibe, AutoCompara, Cotizador Mexicano, BrokerPlace | ❓ sin resultados útiles | | | |

Dos modelos en México: (a) **con las claves propias de la agente** (cobra comisión completa; p. ej. SICAS, Cotizador Mexicano, Dora modo agencia) y (b) bajo la clave del multicotizador (comparte comisión). Para el CRM conviene (a). Preguntar a cada proveedor: "¿puedo cargar mis claves de Quálitas/GNP/AXA/HDI?" y "¿exponen API o solo UI?". Precios: ninguno público; pedir cotización.

## 3. Comisiones: estado de cuenta, CFDI y conciliación

### Marco fiscal (✅ fuentes secundarias especializadas)
- Las comisiones son ingresos por actividad empresarial: **RESICO** o **Actividad Empresarial**, o **asimilados a salarios** si el agente lo comunica por escrito (LISR 94-VI); en asimilados la aseguradora retiene ISR con tarifa de sueldos y el agente **no emite CFDI ni causa IVA**. praxiumconsultores.com/blog/comisiones-de-agentes-de-seguros-retencion-y-regimen
- **IVA por ramo:** comisiones de **vida, agropecuarios, crédito a la vivienda y garantía financiera están exentas**; **autos, GMM, daños y RC causan 16 %** y la aseguradora retiene dos terceras partes (10.6667 %). edifact.com.mx/masinfo/retencion-de-comisiones.html
- 🟡 En RESICO PF la persona moral retiene 1.25 % de ISR.
- "Autofactura": el criterio SAT 5/IVA/NV aplica a indemnizaciones, no a comisiones (idconline.mx 2025-01-31).

### Flujo operativo (🟡 inferido; verificar en el menú "Facturación / Datos fiscales" de cada portal)
1. **El agente emite su CFDI** a la aseguradora y lo carga en el portal; la aseguradora paga contra CFDI validado (reportado en Quálitas y otras).
2. **La aseguradora timbra por cuenta del agente**: el agente sube su CSD al portal y la aseguradora genera el CFDI en cada corte (reportado en GNP, AXA, MetLife, SMNYL; consistente con `zurich.com.mx/DatosFiscalesCFDI`).
3. En asimilados: CFDI de nómina (tipo N) emitido por la aseguradora.

El **estado de cuenta de comisiones** (detalle por póliza/recibo, prima, %, retenciones, saldo) se publica en el portal en PDF y a veces XLS (ANA: "Honorarios y comisiones del mes"; Allianz: "Cuaderno de comisiones").

### Descarga de CFDI desde el SAT para conciliar
- **Servicio Web de Descarga Masiva del SAT:** requiere **e.firma (FIEL)**; ≈200,000 XML por solicitud; código 5002 por solicitudes repetidas. Librería abierta **`satcfdi`** (Python; Descarga Masiva + PACs SW Sapien y Facturama): pypi.org/project/satcfdi.
- **Viabilidad:** ✅ práctica. Job semanal con la FIEL de la agente que descargue CFDI emitidos y recibidos y los cruce contra el estado de cuenta.
- **Proveedores (precios ❓):** SW sapien/Efisco (developers.sw.com.mx), Edifact (edifact.com.mx), EDICOM, Facturama, Syncfy, Finkok, Contalink, sat.ws. Orden de magnitud habitual: cientos de MXN/mes por RFC o cobro por CFDI. Alternativa gratuita: `satcfdi` + FIEL.

## 4. Correo electrónico como canal de integración
- ❓ No hay documentación pública de los correos que recibe el **agente** ni patrones de asunto.
- 🟡 Autos (Quálitas, HDI, GNP, AXA, Zurich): carátula en PDF al asegurado con copia o aviso al agente; los XML adjuntos son del CFDI de la prima. Vida/GMM: avisos con liga al portal. Renovaciones: avisos 30–45 días antes.
- **Diseño robusto:** (1) la agente etiqueta durante 2–3 semanas todo correo de `@qualitas.com.mx`, `@gnp.com.mx`, `@axa.com.mx`, `@hdi.com.mx`, `@metlife.com.mx`, `@mnyl.com.mx`, `@allianz.com.mx` (✅), etc.; (2) trigger de n8n por remitente/dominio + adjunto PDF, no por asunto; (3) extracción LLM de aseguradora, póliza, asegurado, vigencia, prima, forma de pago, ramo, tipo de evento; (4) guardar el asunto original para aprender patrones.

## 5. Fuentes regulatorias y datos públicos
| Fuente | Qué ofrece | Estado |
|---|---|---|
| CNSF – cédulas | Consulta pública de agentes en cnsf.gob.mx / gob.mx/cnsf ("SEAC" no confirmado) | ❓ URL exacta |
| CONDUSEF – SIPRES | Registro de aseguradoras (webapps.condusef.gob.mx/SIPRES 🟡); sin API; ~100 entidades, captura manual | 🟡 |
| AMIS – catálogo de vehículos | No es dato abierto; obtenerlo vía multicotizador/API | ❓ |
| SEPOMEX – códigos postales | ✅ Catálogo oficial TXT/XLS/XML; disponibilidad intermitente en 2026; alternativas comunitarias (github.com/eclipxe13/sepomexphp, github.com/d3249/mexico_zipcodes) | ✅ con advertencia |

## 6. Consideraciones de scraping/RPA (fase posterior)
- ✅ Zurich publica T&C del portal de agentes (zurich.com.mx/PortalAgentes/pda_static/documentos/condicionesGenerales/TerminosyCondicionesdeUso.pdf): leerlo para cláusulas de acceso automatizado.
- ❓ Sin información pública sobre Cloudflare/reCAPTCHA/OTP en GNP, Quálitas, AXA, MetLife, SMNYL. 🟡 GNP y AXA han incorporado código por correo/SMS en inicios desde dispositivos nuevos; **esto bloquea RPA desatendido** salvo perfil de navegador persistente y captura del OTP desde el mismo buzón Gmail vía n8n.
- Asumir que los T&C prohíben el acceso automatizado hasta leerlos. Riesgo práctico: bloqueo de la clave de agente.
- Ukuvi "Conector": sin resultados. Softseguros: colombiana, sin función confirmada de sincronización con aseguradoras mexicanas. 🟡 El referente mexicano con descarga automática desde portales es **SICAS**; su lista de aseguradoras soportadas es el mejor indicador de factibilidad.

## 7. Checklist de verificación para la agente (10–15 min por aseguradora)
Para cada una de sus 6+ aseguradoras: URL del portal · ¿pide OTP/captcha al entrar? · menú de comisiones (formato PDF/XLS y periodicidad) · menú de facturación (¿quién timbra el CFDI?) · descarga de póliza/recibo · preferencias de notificación por correo · conservar 3 correos de muestra por tipo de evento (emisión, recibo, renovación, cancelación) · descargar un ejemplo de carátula, recibo y estado de cuenta.

## 8. Recomendaciones derivadas
1. **Fase 1 sin dependencia de aseguradoras:** Gmail → n8n → LLM + carga manual de PDFs + conciliación vía Descarga Masiva SAT con FIEL + estado de cuenta del portal.
2. **Fase 2:** multicotizador con API que acepte claves propias (Dora, BBVA API Market, Guros, Cotizador Mexicano/SICAS).
3. **Fase 3 (RPA):** solo portales sin OTP, perfil de navegador persistente, respetar T&C, priorizar la aseguradora de mayor volumen.
