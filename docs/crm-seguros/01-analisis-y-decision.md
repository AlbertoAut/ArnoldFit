# 01 · Análisis del punto de partida y decisión de construcción

## 1. Qué dice tu documento y qué cambia tras la investigación

Tu comparativa (Softseguros, SICAS Online, Winsef, Ukuvi, Clericot) es un buen mapa del mercado. Al contrastarla con fuentes de octubre 2026 hay ajustes que afectan el plan:

| Afirmación del documento | Qué encontramos | Efecto en el plan |
|---|---|---|
| Softseguros: USD 380/usuario/año, mínimo 2 usuarios, módulo IA USD 1,300/año adicional | Precio y mínimo confirmados (USD 760/año). El módulo Comercial con agentes IA **ya viene incluido a partir de 3 usuarios**; el "lector de pólizas con IA" se anuncia sin precio. Es empresa colombiana; su disponibilidad real en México es contradictoria entre comparadores. | El competidor "caro" sigue siéndolo para un agente individual (≈ MXN 14,000/año). |
| SICAS Online: MXN 6,990–9,765/año | Vigente: Corredor MXN 7,990 anual; Máster/Multipromotor MXN 9,765; licencia Agente adicional MXN 484/mes. Es el referente mexicano con descarga automática desde portales de aseguradoras. | Benchmark de "comprar": ≈ MXN 8,000/año. |
| Winsef: MXN 650–5,000/mes | Módulos confirmados (Startup ya incluye conciliación de comisiones y WhatsApp); **los montos no se pudieron verificar** en esta ronda. | Verificar en winsef.com/paquetes antes de citar precio. |
| Ukuvi "Conector" RPA | Sin información pública sobre aseguradoras soportadas ni precios. | No es referencia verificable; el RPA se trata como piloto en Fase 3. |
| Clericot usuarios ilimitados | Sin resultados en búsqueda. | Se descarta como referencia. |
| Marco legal: LFPDPPP, INAI | **La ley de 2010 fue abrogada.** Nueva LFPDPPP en vigor desde el 21-mar-2025; **el INAI ya no existe**; la autoridad para el sector privado es la Secretaría Anticorrupción y Buen Gobierno. Las multas se calculan con UMA 2026 ($117.31). | El módulo de cumplimiento se diseña contra la ley nueva (ver 07). |
| CUSF 3.6 aplica al CRM | El capítulo 3.6 obliga a **instituciones**, no a agentes. Lo que sí obliga al agente: Reglamento de Agentes (reserva de información), LISF 96/99/492 y los contratos de comisión mercantil de cada aseguradora. | Menos carga regulatoria directa, pero revisar cada contrato de comisión mercantil. |
| WhatsApp: ventana 24 h y plantillas utility | Vigente, con cambio importante: **desde el 1-oct-2026 Meta cobra los mensajes de servicio arriba de 1,000/mes y las plantillas utility dentro de la ventana**. Para 150 clientes el costo sigue siendo < MXN 100/mes. | Costo irrelevante; lo crítico es la **coexistencia** del número (ver 04). |
| Stealth scraping + resolución de CAPTCHA (2Captcha/CapSolver) | Técnicamente posible, pero implica evadir controles de seguridad de instituciones financieras con las credenciales de la agente; los términos de uso de los portales (Zurich los publica) suelen prohibir el acceso automatizado, y varios portales ya usan OTP por SMS/correo que lo bloquea de todos modos. El riesgo real es el **bloqueo de la clave de agente**, su activo más valioso. | **El plan no incluye evasión de CAPTCHA ni anti-bot.** El RPA de Fase 3 se limita a portales sin OTP, con sesión de navegador persistente, dentro de los términos de uso y priorizando la vía de correo y la API cuando exista. |
| Supabase + n8n + Playwright + LLM | Confirmado como el stack de mejor costo/beneficio para un constructor solo con experiencia en n8n. | Se adopta, con ajustes de costos (ver 08). |

## 2. La decisión: comprar vs construir, con números honestos

Para una agente con 150 clientes, **comprar** cuesta entre MXN 3,000 y 14,000 al año (SICAS Corredor ≈ 8,000; Mercadito ≈ 3,700; Softseguros ≈ 14,000). **Construir** cuesta, en el escenario recomendado, ≈ MXN 300–500 al mes de infraestructura (≈ 4,000–6,000/año) más tu tiempo.

Si el único objetivo fuera "que mi esposa tenga un CRM", lo racional sería contratar SICAS o Winsef mañana. Construir se justifica por tres razones que sí aplican a tu caso:

1. **Lo que ella necesita no se vende por separado:** ingesta automática de carátulas por correo con IA, conciliación de comisiones contra estados de cuenta y SAT, y WhatsApp integrado al ciclo de cobranza/renovación. Los productos existentes lo cobran como add-on, lo restringen por usuarios o no lo tienen.
2. **Soberanía de los datos:** su cartera es su patrimonio. En un sistema propio no hay lock-in, no hay precio por usuario y la exportación es un botón.
3. **Opción real de SaaS:** el mismo código, con `tenant_id` desde el día uno, se puede vender a otros agentes. El mercado es grande (≈ 65,000 agentes en México, ≈ 3,500 en AMASFAC) y los competidores mexicanos tienen interfaces envejecidas o precios por asiento.

La condición para que esto tenga sentido es **disciplina de alcance**: un MVP que resuelva renovaciones, cobranza y expediente en 8 semanas, usado a diario por ella, antes de tocar RPA, multicotizador o portal de clientes.

## 3. Qué copiar de cada competidor y qué evitar

| Competidor | Copiar | Evitar |
|---|---|---|
| Softseguros | Perfil 360 del cliente; agentes IA en WhatsApp para cobranza y citas; lector de pólizas con IA | Precio por asiento; mínimo de usuarios |
| SICAS Online | Profundidad contable (comisiones, CFDI, estados de cuenta); portal de cliente | Interfaz Web 2.0; configuraciones manuales por póliza; 25 h de capacitación |
| Winsef | OCR de carátulas; migración desde Excel con plantilla; soporte humano experto; sin plazo forzoso | Módulos de IA conversacional poco sofisticados |
| Ukuvi | Descarga desatendida como aspiración; alertas predictivas de renovación | Dependencia total del scraping |
| Clericot | Usuarios ilimitados; conciliación de lo reportado vs lo producido | Enfoque solo administrativo sin prospección |

## 4. Principios de diseño del producto

1. **Móvil primero.** Ella trabaja desde el celular; la app es una PWA instalable con cinco pantallas que se usan a diario: Hoy, Clientes, Pólizas, Cobranza, Bandeja.
2. **Cero captura cuando se pueda evitar.** Correo → IA → revisión de un clic. Excel → importación. WhatsApp → documento al expediente.
3. **Todo lo que la IA extrae pasa por un humano** hasta demostrar precisión por aseguradora.
4. **Multi-tenant desde el primer `CREATE TABLE`.**
5. **Cumplimiento integrado, no bolt-on:** consentimientos, ARCO, auditoría y bloqueo de datos son tablas y flujos, no un PDF.
6. **n8n orquesta, Postgres decide.** Las reglas de negocio (gracia, estados de recibo, cálculo de comisión) viven en SQL/funciones; n8n las invoca. Así n8n es reemplazable y la licencia no bloquea la fase SaaS.
7. **Oficial o nada en WhatsApp.** Cloud API vía coexistencia; nunca Baileys/Evolution con su número.
8. **Sin evasión de controles de seguridad de terceros.** Integración por correo, API o RPA dentro de términos de uso.
