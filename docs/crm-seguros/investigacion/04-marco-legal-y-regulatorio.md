# Investigación · Marco legal y regulatorio (México, 2026)

**Fecha: 2026-10-13.** Leyenda: **[P]** fragmento de fuente primaria (DOF, INEGI, texto de ley) · **[S]** fuente secundaria con URL · **[C]** conocimiento previo no verificado en esta sesión; validar con el texto vigente y con abogado/contador. **Nada de esto es asesoría legal**; son requisitos a validar.

## 1. Protección de datos personales: nueva LFPDPPP (DOF 20-03-2025)

### Hechos básicos
- Nueva Ley Federal de Protección de Datos Personales en Posesión de los Particulares publicada en DOF el **20-03-2025**, en vigor el **21-03-2025**, **abroga la ley de 2010**. [S] EY https://www.ey.com/es_mx/technical/tax/boletines-fiscales/nueva-ley-federal-proteccion-datos-personal-posesion-particulares ; Garrigues; Hogan Lovells.
- Texto vigente: https://www.diputados.gob.mx/LeyesBiblio/pdf/LFPDPPP.pdf (la ficha reporta "última reforma DOF 14-11-2025" [S, verificar]).
- La reforma constitucional de diciembre 2024 extinguió al INAI. [S] GT Law.

### Autoridad competente (sector privado)
- **Secretaría Anticorrupción y Buen Gobierno (SABG)** asume supervisión, vigilancia y sanción en datos personales de particulares. [S] idconline 02-04-2025 https://idconline.mx/corporativo/2025/04/02/que-asumio-la-secretaria-anticorrupcion-tras-la-desaparicion-del-inai ; Littler; KPMG.
- "Transparencia para el Pueblo" es para sujetos obligados (sector público); una empresa privada no acude ahí. Incierto en algunos recursos.
- **2026:** Infobae (29-01-2026) reporta que la SABG arrancó proceso para actualizar la ley; monitorear DOF y sitio SABG.

### Qué cambió vs 2010
- Consentimiento "libre, específico e informado"; obligación más estricta de **recabar nuevo consentimiento** para finalidades distintas. [S] EY, Garrigues, KPMG.
- Definición de dato personal sin la palabra "física" (riesgo interpretativo sobre personas morales). [S] EY.
- Sanciones conservan el rango 100–320,000 UMA, duplicable con datos sensibles. [S] KPMG/EY.
- **Reglamento y Lineamientos:** no se encontró Reglamento nuevo; el Reglamento de 2011 sigue aplicándose en lo que no se oponga, entendiendo las referencias al INAI hechas a la SABG; los Lineamientos del Aviso de Privacidad (DOF 17-01-2013) siguen como referencia práctica. **Verificar transitorios.** [S] legiscope https://www.legiscope.com/blog/lfpdppp-mexico-guia-cumplimiento.html

### Obligaciones relevantes para el software
**Aviso de privacidad** [C, Lineamientos 2013]: *Integral* (identidad y domicilio del responsable; datos tratados señalando los **sensibles**; finalidades primarias y secundarias separadas con mecanismo para negar las secundarias; transferencias; medios ARCO y revocación; limitación de uso; cookies; cambios al aviso). *Simplificado* y *corto* para formularios y WhatsApp. Versionar el aviso y registrar qué versión aceptó cada titular, fecha/hora, canal y evidencia.

**Consentimiento para datos sensibles (salud, GMM)** [C+S]: **expreso y por escrito**, "a través de su firma autógrafa, firma electrónica o cualquier mecanismo de autenticación"; el Reglamento 2011 admite medios electrónicos. **Un checkbox anónimo o un "sí" por WhatsApp no equivale por sí solo a firma electrónica.** Flujo defendible: OTP al teléfono/correo del titular + aceptación explícita del aviso integral + registro de IP, fecha/hora, versión y hash; mejor aún con constancia NOM-151. La foto del formato firmado también sirve. Validar con abogado.

**Derechos ARCO** [C]: respuesta en **20 días** y ejecución en los **15 días** siguientes; ampliables una vez; acreditar identidad. Bitácora con fechas límite.

**Medidas de seguridad** (art. 19; Reglamento 57-62 [C]): inventario de datos, análisis de riesgo, análisis de brecha, plan de trabajo, capacitación, control de accesos, bitácora de vulneraciones. Para el CRM: cifrado en reposo y tránsito, RBAC, MFA, logs de acceso a datos sensibles, respaldos, segregación por tenant.

**Vulneraciones** (art. 20; Reglamento 63-66 [C]): informar **de inmediato al titular** las que afecten significativamente sus derechos, con naturaleza, datos comprometidos, recomendaciones, acciones correctivas. Incierto si la ley 2025 añade notificación a la SABG o plazo fijo.

**Proveedores en el extranjero (Supabase/AWS en EE. UU.)** [C]: entrega a un **encargado** es una *remisión*, no transferencia; no requiere consentimiento pero sí contrato (DPA) y mención en el aviso. Transferencias a terceros responsables (la aseguradora para emitir) encajan en la excepción de necesidad contractual, pero listarlas. Cómputo en la nube (Reglamento art. 52): usar solo proveedores con políticas acordes, que transparenten subcontrataciones, no se apropien de datos y permitan supresión al término. No hay prohibición general de alojar datos sensibles fuera de México.

**Responsable vs encargado (fase SaaS)** [C]: el agente = responsable; el SaaS = encargado. Cláusulas mínimas: tratar solo por instrucciones; no fines distintos; medidas de seguridad; confidencialidad; suprimir/devolver al terminar (portabilidad); subcontratar solo con autorización; comunicar vulneraciones.

**Cancelación y bloqueo** [C]: tras la finalidad, los datos pasan a **bloqueo** por el plazo de prescripción y luego supresión. Plazos relevantes: LSCS 2/5 años, fiscal 5 años (CFF 30), PLD 10 años. Estados: activo → bloqueado → suprimido.

**Sanciones** (UMA 2026 = **$117.31** diario; INEGI 08-01-2026 [P] https://www.inegi.org.mx/contenidos/saladeprensa/boletines/2026/uma/uma2026.pdf): multa 100–160,000 UMA (≈ $11,731 a $18.8 M MXN) en infracciones menores; 200–320,000 UMA (≈ $23,462 a $37.5 M MXN) en graves; **hasta el doble con datos sensibles** (≈ $75 M MXN máximo). Delitos: prisión 3 meses–3 años / 6 meses–5 años [C].

## 2. Regulación de seguros aplicable al agente

### LISF (arts. 91–104 aprox.)
- Actividad sujeta a inspección y vigilancia de la CNSF. [P-mirror] https://sdv.com.mx/compendio/ley-de-instituciones-de-seguros-y-de-fianzas/articulo-94/
- Art. 96: proporcionar información detallada sobre coberturas y riesgos; apegarse a tarifas. [P-mirror] https://mley.mx/LISF/articulo/96/
- Art. 99: solo cobrar primas contra recibo oficial; entregar en 10 días hábiles.
- [C] Tipos de agente (persona física con relación laboral, independiente por contrato mercantil, persona moral); autorización por ramos; informar exclusiones y, a petición, comisiones.

### Reglamento de Agentes de Seguros y de Fianzas (DOF 18-05-2001)
- Art. 5: identificarse con nombre completo, tipo de autorización, número y vigencia de la cédula. [S] copia https://www.dorama.mx/assets/pdf/agentes/12_ReglamentodeAgente_de_Seguros_y_de_Fianzas.pdf
- Arts. 14–15: cédula y refrendo (plazos reanudados con Circular 7/22). [S] PwC.
- [C] Vigencia 3 años, refrendable con capacitación (CUSF Título 32). Obligaciones: información veraz, informar alcance real de la cobertura, entregar recibos, **guardar reserva** de la información de clientes. Prohibiciones: firmar por el cliente, retener primas, ceder comisiones.
- **Tipos de cédula:** uso común reportado [C, incierto]: A = personas (vida, accidentes y enfermedades), B = daños, C = todas las operaciones, F = fianzas. Validar en padrón CNSF.

### CUSF 3.6 y nube
- [C] El Capítulo 3.6 regula contratación de terceros por **Instituciones**, no agentes; los agentes están en el Título 32. No hay norma CNSF/SHCP sobre software en la nube para agentes. **Pero** los contratos de comisión mercantil de cada aseguradora trasladan cláusulas de confidencialidad y protección de datos al agente; revisarlos. Ejemplo: https://www.dorama.mx/assets/pdf/agentes/01_ContratoComisionMercantil.pdf

### PLD/AML
- **LISF art. 492**: instituciones **y agentes** deben cumplir obligaciones de conocimiento del cliente e identificación documental conforme a DCG de la SHCP. [P-mirror] https://sdv.com.mx/compendio/ley-de-instituciones-de-seguros-y-de-fianzas/articulo-492/
- **LFPIORPI**: la intermediación de seguros no está en el catálogo de actividades vulnerables del art. 17 [C]; verificar reforma de julio 2025.
- [C] La aseguradora es el sujeto obligado y conserva 10 años; el agente recaba. Datos que el CRM debe capturar: PF: nombre, fecha y país de nacimiento, nacionalidad, RFC y CURP, domicilio, ocupación, teléfono, correo, identificación vigente, comprobante de domicilio, **PEP**, origen de recursos en vida/ahorro, beneficiarios; PM: denominación, RFC, acta, poderes, representante, **propietario real**. Guías SMNYL: https://www.mnyl.com.mx/sharedassets/pdf/normatividad/integridad-y-cumplimiento/2026/guia-para-prevenir-riesgo-actividad-intermediacion.pdf

## 3. Ley sobre el Contrato de Seguro (LSCS)
- **Art. 40** [C]: sin pago de la prima o fracción en el plazo convenido, los efectos cesan automáticamente a las 12:00 h del último día; sin plazo convenido, **30 días naturales**; no aplica a seguros obligatorios salvo pacto. El CRM calcula `vencimiento + plazo (default 30)` y alerta T-15, T-7, T-1 y día de cese.
- **Rehabilitación**: cláusula contractual (vida/GMM). Estado "cancelada por falta de pago → rehabilitable hasta fecha".
- **Renovación**: la LSCS no exige aviso previo; es práctica comercial.
- **Siniestros**: aviso en 5 días (art. 66); pago en 30 días tras documentación completa (art. 71).
- **Prescripción**: art. 81: **5 años** fallecimiento en vida, **2 años** demás; art. 82 beneficiarios; art. 84 interrupción; CONDUSEF interrumpe. [S] idconline. Alerta de prescripción en siniestros abiertos.
- **CONDUSEF** [C]: el agente persona física no es "Institución Financiera" bajo la LPDUSF; **no requiere UNE ni RECA**. Sí: entregar póliza/carátula y condiciones, explicar coberturas (LISF 96) y entregar **su propio aviso de privacidad**. Registrar entrega de documentos.
- Marketing: REPEP (PROFECO) y REUS (CONDUSEF) de aplicabilidad dudosa a agentes; ofrecer opt-out.

## 4. Fiscal: comisiones del agente persona física
- **Regímenes**: Actividad Empresarial y Profesional; **RESICO** PF (≤ $3.5 MDP); asimilados a salarios (la aseguradora retiene ISR, el agente no emite CFDI ni causa IVA). [S] Praxium https://praxiumconsultores.com/blog/comisiones-de-agentes-de-seguros-retencion-y-regimen
- **Retenciones**: en Actividad Empresarial la comisión mercantil no es servicio profesional → **no aplica la retención de ISR del 10 %** según Praxium; sí 2/3 del IVA (LIVA 1-A II d). En RESICO: **1.25 % ISR** + 2/3 IVA. En la práctica algunas aseguradoras retienen 10 % [C] → **parametrizar tasas por aseguradora**.
- **IVA**: exentas vida, agropecuarios, crédito a la vivienda y garantía financiera (LIVA 15-IX); gravadas al 16 % autos, GMM, daños, RC. [S] idconline 2025-02-18.
- **CFDI 4.0** [C]: CFDI de Ingreso a la aseguradora por cada pago, con Traslado IVA y Retenciones, régimen 612 o 626, uso G03, PUE/PPD + complemento de pago. "Autofacturación" por PAC a nombre del agente: arreglo privado de algunas aseguradoras (el agente timbra con su CSD en el portal), no autofactura legal [C, incierto].
- **Qué guarda el CRM para el contador**: por pago: aseguradora (RFC), póliza/recibo, ramo (exención), periodo, base, %, comisión, IVA trasladado, IVA retenido, ISR retenido, neto, fecha, UUID del CFDI y complemento; estado de cuenta adjunto; constancias anuales; totales mensuales por régimen.

## 5. WhatsApp / Meta
- Business Messaging Policy (https://business.whatsapp.com/policy): solo escribir a quien dio **opt-in**; el negocio es responsable del método y de la ley local; respetar **opt-out**; el opt-in debe indicar que acepta mensajes y el nombre del negocio; desde nov-2024 puede ser general si cumple la ley local. [S]
- Seguros: sin restricción específica en la Messaging Policy; la Commerce Policy restringe productos financieros en catálogos [C].
- **Datos de salud por WhatsApp** [C]: no enviar ni solicitar información médica detallada; usar WhatsApp para avisos y enlaces a un portal autenticado. Documentar a Meta como encargado con datos en EE. UU.
- **Evidencia de opt-in**: número, fecha/hora, canal, texto exacto, versión del aviso, IP/sesión, opt-outs. Lenguaje sugerido: "Acepto que [Nombre, cédula CNSF No. ___] me envíe mensajes por WhatsApp al número ___ sobre mis pólizas (renovaciones, pagos, siniestros) y, si lo marco, promociones. Puedo cancelar respondiendo BAJA. Aviso de privacidad: [enlace]". Casilla separada para promociones.

## 6. Fase SaaS
- **Contrato SaaS** [C]: objeto y SLA (disponibilidad, RTO/RPO, soporte); precio e IVA; **anexo de encargado** (instrucciones, finalidad, seguridad, subencargados —Supabase, AWS, Meta, PAC—, notificación de vulneraciones, supresión/devolución); **portabilidad** (exportación CSV/JSON y ventana de descarga); **propiedad**: datos y cartera del agente, el proveedor no contacta a sus clientes; límites de responsabilidad; jurisdicción.
- **PROFECO/LFPC** [C]: agentes B2B no son consumidores en principio; términos claros sin cláusulas abusivas.
- **Persona física vendiendo SaaS en RESICO** [C]: posible mientras ingresos totales ≤ $3.5 MDP y sin exclusiones del 113-E.
- **IVA en SaaS** [C]: 16 % (LIVA 14) a clientes en México.
- **NOM-151-SCFI-2016** [P] https://platiica.economia.gob.mx/wp-content/uploads/sites/2/PDF_Normas_Publicas/151scfi2016.pdf : conservación de mensajes de datos; la constancia (sello de tiempo + hash) la emiten PSC acreditados. No obligatoria para validez del log de consentimiento, pero **fortalece la prueba**. Comerciante conserva mensajes de datos **10 años** (CCom 49) [C]. Nice-to-have MVP; must-have SaaS.

## 7. Checklist de cumplimiento

### Must-have (MVP de un solo agente)
1. **Aviso de privacidad integral** del agente (y simplificado/corto), versionado, con datos sensibles de salud, finalidades, transferencias a aseguradoras, encargados (hosting EE. UU., WhatsApp), medios ARCO.
2. **Registro de consentimiento por titular**: versión, fecha/hora, canal, método de autenticación, evidencia; consentimiento **separado y expreso** para datos de salud y para marketing. Bloquear captura de datos de salud sin consentimiento registrado.
3. **Módulo ARCO**: solicitudes, cómputo 20/15 días hábiles, prórrogas, identidad, respuesta; revocación y opt-out.
4. **Seguridad mínima**: cifrado en tránsito y reposo, MFA, RBAC, bitácora de accesos a datos sensibles, respaldos cifrados, borrado seguro; documento de medidas y bitácora de vulneraciones con plantilla de notificación.
5. **DPAs** de Supabase, AWS y Meta archivados; subencargados listados en el aviso.
6. **Ciclo de vida del dato**: activo/bloqueado/suprimido con plazos configurables (2/5 años LSCS, 5 fiscal, 10 PLD).
7. **Datos del agente**: cédula, tipo, ramos, vigencia/refrendo (alerta), RFC y régimen; mostrar nombre, tipo, número y vigencia de cédula en comunicaciones (Reglamento art. 5).
8. **Pólizas y recibos**: vigencia, forma de pago, vencimiento por recibo, gracia configurable (default 30 días naturales), fecha de cese, alertas, renovación, rehabilitación.
9. **Siniestros**: fecha del evento, aviso (5 días), documentación, pago (30 días), **alerta de prescripción** 2/5 años.
10. **Expediente KYC** por cliente (identificación, RFC/CURP, domicilio, ocupación, PEP, beneficiarios; PM: representante y propietario real) con vigencias.
11. **Comisiones**: base, %, IVA trasladado/retenido, ISR retenido parametrizable por aseguradora y régimen, ramo, UUID CFDI; exportación para el contador.
12. **WhatsApp**: opt-in/opt-out con texto exacto; plantillas sin datos médicos; enlaces a portal autenticado para datos sensibles.
13. **Registro de entrega de documentos** al cliente con fecha, canal y acuse.

### Nice-to-have MVP / Must-have SaaS
- Constancia NOM-151 sobre consentimientos y acuses; firma electrónica simple con autenticación robusta.
- Bloqueo de operaciones fuera de los ramos de la cédula.
- Exportación completa y supresión por tenant; contrato SaaS con anexo de encargado, SLA y propiedad de cartera.
- Panel de cumplimiento: vencimientos ARCO, KYC por vencer, refrendo, prescripciones.
- Verificación REPEP/REUS antes de campañas.

## 8. Puntos abiertos (verificar en fuente primaria)
1. Texto 2025 de la LFPDPPP: consentimiento sensible, plazos ARCO, vulneraciones, encargados, transitorios, reforma 14-11-2025.
2. Unidad de la SABG que recibe denuncias y criterios 2025-2026.
3. Reglamento de Agentes: artículos exactos y tabla de tipos de cédula.
4. CUSF 3.6 y Título 32.
5. DCG art. 492 LISF: datos de identificación exactos.
6. LSCS arts. 40, 66, 71, 81–84 texto vigente: https://www.diputados.gob.mx/LeyesBiblio/pdf/LSCS.pdf
7. LISR 106, 113-J, 94-VI; LIVA 1-A, 15-IX; RMF 2026.
8. WhatsApp Business Messaging Policy, Commerce Policy y Data Processing Terms vigentes.
9. LFPC aplicabilidad a SaaS B2B; LFPIORPI tras reforma 2025.
