# Reunión 27/04/2026: Documentación y requerimientos IV, presupuesto y rentabilidad

- Fecha: 27/04/2026, de 14:05 a unas 15:19 (duración 1 h 13 min).
- Participantes:
  - Álvaro Montero (Docenteo, consultor del proyecto; lleva la sesión).
  - Fátima Sánchez de Pazos (Tinkle, finanzas; prepara el presupuesto y el fichero de rentabilidad).
  - Josep Zoppetti (Tinkle, finanzas; mantiene los Excel de checklist y de agings).
  - Mencionados sin estar presentes: David (Tinkle; trabaja con Fátima el presupuesto y decide criterios, según se dice) y Dan (papel no se entiende en la transcripción; probablemente es David mal reconocido, sin confirmar [1:10:56]).
- Fuente: `02.Clientes/04.Tinkle/Reporting financiero/3.Reuniones/20260427_Reporting Tinkle - Documentación & Requerimientos IV - Ppto & Rentabilidad.docx` (OneDrive). Existe grabación .mp4 de la reunión.
- Advertencia: Resumen de una transcripción automática: lo que se dice es testimonio verbal, no verificado contra datos.
- Convención de referencias: las marcas [mm:ss] son las de la transcripción automática (aproximadas).

## Resumen

- Se revisaron tres bloques: aging de clientes y proveedores (con un control de riesgo de crédito nuevo), presupuesto y forecast, y fichero de rentabilidad.
- El aging se alimenta con extractos de Oracle (clientes) y de Databox (proveedores). Hoy se pegan, se cambia el separador decimal y se refrescan Excel con fórmulas manuales. La fecha de vencimiento no está en el checklist y hay que obtenerla de los módulos de cuentas a pagar y a cobrar.
- Se acuerda como punto de partida usar la pestaña de clientes del checklist como maestro de clientes, al que se añadirían los límites de crédito. No está cerrado el diseño.
- El presupuesto parte del fichero de revenue, que finanzas construye a partir de MMS y ajusta con las directoras. Los meses cerrados vienen del checklist y los abiertos se reparten por porcentajes, sin criterio fijo. Fátima lo consultará con David.
- La rentabilidad (compensación, gastos) queda pendiente para otra sesión. Álvaro propone un formulario por directora precargado con MMS. La herramienta no se decide: David debe decidirla, y Álvaro explicará opciones en mayo.
- Queda pendiente una prueba de carpeta compartida entre Docenteo y Tinkle.
- El presupuesto no se para: Álvaro pide terminar de ver en la siguiente sesión cómo entra el real y cómo se ajustan los meses [1:11:50].

## Temas tratados

### 1. Aging de clientes y proveedores

- Clientes: se descarga de Oracle el extracto tal cual sale del sistema. Los importes traen punto decimal; hay que sustituir el punto por coma para que Excel lo lea en formato español [12:08]. Se pega en la pestaña de datos, columnas de la A a la M [12:51, 14:12].
- Álvaro pide a Fátima que guarde el extracto de clientes tal como se descarga, antes de modificarlo; Fátima no lo había tocado por eso [13:05, 13:13]. Antes había dicho que lo sacaba para subir el bruto [8:21].
- Proveedores: el extracto sale de Databox, no de Oracle [15:58, 16:23]. Se copia entero salvo la última fila (total) y se pega en la pestaña de datos, columnas de la A a la O [17:02, 17:20]. No se dice si también requiere el cambio de punto a coma. Fátima añade al principio que esos datos también se podrían sacar del checklist [1:09].
- Tras pegar, se arrastran las fórmulas manuales de la derecha hasta la última fila y se hace un refresh [14:14]. No se imputa nada más [14:51].
- Pestañas: el resumen y el consolidado por fecha de vencimiento, con todas las sociedades [14:14, 15:23]. No queda claro si el resumen es la pestaña que Fátima no usa o la que considera más importante: la frase es ambigua [14:14]. Las relevantes van de resumen a Onion (o de Onion a datos) [15:14, 15:39]. Las pestañas por sociedad sirven de filtro. Las pestañas de reclamaciones las añade el equipo de clientes y se pueden ignorar [14:47, 15:14].
- Fecha de cálculo: el aging se calcula a una fecha elegida, normalmente cierre de mes. Se saca al menos dos veces al mes, a mitad y a final [18:30, 19:13]. Cambiar la fecha recalcula los tramos sin cambiar los importes [19:28].
- Tramos: por días vencidos (por ejemplo 0 a 30, más de 30, más de 60) [19:28]. Son las columnas que usa el Grupo [18:30].
- Grupo: pide aging de clientes; de proveedores, según Josep, todavía no [18:30].
- Fecha de vencimiento: no está en el checklist. Solo viene de los módulos de cuentas a pagar (AP) y a cobrar (AR) [4:58, 5:18]. Josep cree que el aging debe estar dentro de Power BI, aunque suponga subir más ficheros [6:01]. Queda sin resolver cómo incorporarla; Josep dice que "tendremos que ver cómo le damos esta info" [6:11].
- Fátima propone añadir al extracto de proveedores la fecha de factura, la fecha de vencimiento y la fecha contable. La fecha contable explica facturas de 2025 registradas en marzo de 2026 [1:09].
- Josep ofrece enseñar cómo se extraen los agings de Oracle [5:18]. Fátima pregunta si en Databox hay también datos de clientes; Josep responde de forma ambigua ("sí, pero bueno") [10:38, 10:40].
- Origen de los datos: Álvaro pregunta si se puede conectar directamente a las fuentes. Josep lo ve como un ideal poco probable, porque la información no es suya y dependen de "Abbas" (probablemente Havas, el Grupo; interpretación no segura) hasta para sacar un informe [10:57, 11:09]. Álvaro sugiere que las plataformas tendrán algún mecanismo de exportación o acceso; no se concreta [11:18].
- Álvaro plantea que el punto de partida es subir el dato bruto y que el formato lo haga el modelo [6:52, 8:07]. Josep acepta que Álvaro diga "sube el fichero aquí" y él se encarga del formato [10:40]. No queda cerrado.

### 2. Riesgo de crédito

- Nuevo control desde abril: cada cliente tiene un riesgo máximo de crédito que Tinkle le concede. Se fija a mano al dar de alta al cliente y se guarda en un Excel [3:30, 3:50, 23:46].
- Objetivo: cruzar el saldo pendiente de cada cliente con su límite [21:36].
- Ejemplo de Josep: con límite de 100.000 y saldo de 92.565, no hay problema; con límite de 50.000 y saldo de 92.000 hay exceso [22:13, 22:26].
- Propuesta: un campo o alerta de "riesgo excedido", o color distinto [22:42]. Propuesta, no decidida.
- Los límites no vienen del ERP. Se ven como un input más, que se descarga y se cruza [23:00, 23:45]. Josep y Fátima sugieren que vivan en el maestro de clientes; Fátima dice que les da igual dejarlos en Excel o en una ficha de cliente de Power BI, aunque la ficha les resultaría más sencilla y trazable [23:46, 24:09]. Josep añade que Álvaro necesitará un mapeo de clientes también para la rentabilidad de MMS (en la transcripción, "BMS") [23:07].

### 3. Maestro de clientes

- Pestaña del checklist: código de cliente de Oracle, código de MMS (normalmente el mismo, con o sin "EE" delante), nombre, empresa y sección. Las dos últimas son las más usadas. Las columnas del medio no se usan [27:03, 27:25].
- La directora asignada se pone a mano [24:38].
- Álvaro indica que hasta ahora no le han pasado ningún maestro de clientes [24:30]; Josep le remite a esa pestaña del checklist [24:38].
- Oracle tiene más datos del tercero (NIF, número de tercero, dirección fiscal, email, condiciones de pago), pero no se extraen porque no se usan [24:59, 26:11, 26:19]. Josep ofrece sacar un maestro del sistema con más información si Álvaro lo necesita; queda a la espera de que Álvaro lo diga [24:59]. MMS trae también CIF e información del cliente [25:28].
- Acuerdo de partida, no cerrado: Álvaro toma esa pestaña como maestro y se le añaden columnas, incluido el límite de crédito [27:28, 27:51]. Álvaro dice que, cuando lo presente, se hablará de qué información nueva incorporar a esa pestaña [27:28]. Fátima apunta la forma de pago del cliente y en el mismo momento lo descarta porque en proveedores nunca la tendrían [28:04].
- Álvaro plantea si el maestro debe ser una tabla separada que se cruce en varios sitios [26:26]. No se decide.

### 4. Presupuesto y forecast

- Ficheros: son cuatro. Fátima dice que los va a subir y que se apunta subir "el otro" después [28:34]. El revenue forecast en CSV y el forecast FT3 en CSV son ficheros de carga a Magnitude: Álvaro lo resume como el output del proceso, "lo que tiene que salir para subir", y Fátima lo confirma [28:34, 28:59, 29:02]. (Corrección: la versión anterior del acta decía que los CSV cargan datos en el Excel; la transcripción indica lo contrario, aunque la frase está cortada.)
- Estructura del Excel: pestaña de resumen (se salta, no interesa), consolidado de todas las sociedades y una pestaña por sociedad [29:51, 30:18].
- Sociedades citadas: Communication, Consultants, Onion y Portugal, y otras que la transcripción recoge como "European Just", "Euro" y "Jazz" (probablemente una o dos sociedades más; nombres no seguros) [30:18, 42:16, 21:09]. Una sociedad aparece como "H Advisor" o "Chadvisors"; Josep habla en el mismo contexto de su "checklist de acento", así que probablemente es HAPA (interpretación no segura). Aún no tiene pestaña propia: David hizo su presupuesto a mano una vez y Josep montó una pestaña en valores, descargada de Magnitude, para comparar. Josep y Fátima dicen que la idea es que tenga su propia pestaña [30:41, 31:04, 31:17, 31:25].
- Ediciones y calendario: presupuesto presentado en septiembre; FT3 en marzo (empezó en febrero); FT8 en septiembre del año en curso; el presupuesto del año siguiente empieza en septiembre [35:36, 36:04]. En el fichero actual (FT3), la columna FT8 es la del año anterior, que ahora no sirve; Fátima lo explica así [31:29]. No es una contradicción: en el próximo documento el FT8 será el del año en curso.
- Orden de columnas: a la izquierda la edición en curso y a la derecha las anteriores, de más a menos reciente; hubo confusión entre Fátima y Josep antes de aclararlo [34:13, 34:44]. En el próximo documento, a la izquierda el FT8, a la derecha el FT3 y más a la derecha el presupuesto (budget). Lo resume Álvaro y lo confirma Fátima [35:47, 35:54, 35:59].
- La estructura de P&L es la misma que la del checklist, proyectada hasta cierre de año natural. No hay business plan [31:29, 33:10].
- Meses reales: enero y febrero cerrados. Marzo se presentó como real a inicios de abril, aunque aún no estaba cerrado, y se ajustaron diferencias en los totales [36:21, 37:08]. Abril a diciembre, proyectados [37:08].
- Cerrado = mes completo. No se puede adelantar el cierre de un mes [37:51, 38:00, 38:07].

### 5. Gross Income y reparto del revenue

- Objetivo de Gross Income: Fátima dice que "nos lo dan o lo marca David"; normalmente "global" (probablemente el Grupo) fija un porcentaje de crecimiento sobre el cierre del año anterior. En septiembre no hay cierre hecho, así que se aplica sobre el cierre estimado (el FT8) [39:26, 39:49, 40:01].
- El porcentaje cambia cada año y no es fijo [40:27, 40:31].
- Composición: facturación real por cliente (por ejemplo, un cliente con cuota fija mensual) más new business, es decir, facturación necesaria para llegar al objetivo y todavía sin cliente asignado [40:57].
- Fichero de revenue: una pestaña por versión (FT3, presupuesto, FT8). Por sociedad y por cliente, con meses reales y estimados [bloque 40:57 a 42:16]. Se construye a partir de MMS, se revisa con las directoras, y con su feedback se ajusta y se pega en el forecast, en la línea de honorarios (fees) [51:48, 57:33, 57:37]. Fátima dice que el fichero base es MMS [57:37]. Según Josep, las cifras salen de reuniones de Fátima y David con cada directora [43:37]. Las directoras no ven ese fichero [44:12].
- Honorarios: los contratos ya están en MMS a futuro. Se sabe lo que se cobrará hasta fin de año, aunque los contratos se renegocian [46:33]. Producción: solo se conoce cuando se hace; se extrapola del año anterior y lo estima la directora [47:22].
- Redondeos: los importes por cliente se redondean (por ejemplo 5000 en vez de 4900) porque el sistema no admite decimales. Fátima prefiere guardar el valor exacto y ajustar al subir. Álvaro lo ve correcto [50:24, 50:51].
- Reparto mensual: el total anual de los meses abiertos se reparte por porcentajes. En el último caso se usó el reparto del año anterior. Fátima dice que no hay criterio consistente; también se menciona la tendencia de meses anteriores [58:14, 59:18, 1:01:27]. Fátima lo consultará con David [1:02:27].
- Álvaro propone que la regla de reparto sea configurable: se elige la regla y queda un borrador que luego se puede corregir [1:01:56, 1:02:26].
- Cuadre: el total anual de FT3 cuadra con el revenue (la transcripción da la cifra 12615, unidad no clara). Por meses no cuadra, porque MMS "está vivo" y el real viene del checklist cerrado; hay diferencias de redondeo [54:12, 54:31, 54:51]. Con los redondeos se meten ajustes manuales para que cuadre el total [58:37]. Para los meses reales solo se comprueba que el total coincida [56:58].
- Fátima señala que una línea (la 17) está en positivo y otra (la 33) en negativo, sin que se explique por qué [55:01]. Queda abierto.
- Álvaro pregunta cómo se conecta el real. Fátima: el real viene del checklist; los meses abiertos se reparten con porcentajes. El fichero de revenue se pega en el de forecast [55:01, 56:12, 56:32].
- Álvaro quiere ver la lógica de reparto con un ejemplo; Fátima dice que el reparto se hace en otro Excel que no existe como tal, y que lo prepara y lo manda [58:50, 1:00:15, 1:00:34]. Álvaro intentará construir la lógica él mismo con lo explicado; si no, pedirá que se lo expliquen [1:00:40]. Fátima propondrá un cálculo y lo consultará con David [1:00:54].
- Álvaro pide conocer los distintos criterios de reparto que existan, para habilitarlos como opción [1:02:26]. Fátima: "lo consultamos y te decimos" [1:02:27].
- Portugal: aparece como una línea única. Tiene detalle en otro Excel que Fátima no ha compartido; dice que lo compartirá, pero antes tiene que encontrarlo [42:48, 43:11]. Ese detalle no se sube a Magnitude por decisión de la empresa [42:16, 42:48]. Fátima ve ideal desglosarlo en el modelo, ya que existe [43:11].

### 6. Fichero de rentabilidad

- Bloques: Gross Income, Compensation (coste de personal; "staff cost") y todo lo que va debajo (gastos externos, otros gastos, alquileres). Fátima llama "item" a la parte de otros gastos [1:03:32]. Compensation y otros gastos quedan para otro día [1:03:32]; los externos se consideran más fáciles pero con base parcial en el checklist [38:29, 1:13:06]. (Nota: estos bloques son los del fichero de forecast que se estaba mostrando, no necesariamente los del fichero de rentabilidad.)
- Resumen por directora: Gross Income del equipo, personal y Contribution [1:08:53].
- Gastos: algunos están por centro de coste (CECO) y otros no. Hay que definir cómo se reparten entre directoras [1:08:55].
- Gross Income por persona: se divide según el porcentaje de dedicación de cada persona en cada cliente. Hay dedicaciones sin rellenar por las directoras [1:08:55].
- Las directoras completan el fichero de rentabilidad por totales, no mensualizado, y cada una lo hace de forma distinta [44:12, 1:06:43]. Solo ven sus clientes y sus ingresos; el fichero de forecast con todos los clientes es de administración y ellas no lo ven [44:12, 45:09]. Fátima dijo que lo enseñaría [44:12] y lo mostró en pantalla al final [1:08:55]; no se acordó enviarlo.
- Próxima revisión: julio. Se quiere una estructura por directora y mensualizada [44:12, 49:36]. El presupuesto debería quedar hecho a finales de junio o principios de julio, porque en agosto no hay nadie; Fátima dice que no lo tiene muy claro [1:07:35, 1:07:56].
- Hay directoras que ya tienen su 2026 mensualizado, con fin de contrato y subidas de fee. Es útil [1:08:55].
- Propuesta de Álvaro: formulario por directora con los datos de MMS precargados, para ajustar encima y volcar al total. Solo vería sus clientes [49:18, 51:23]. Fátima pide que sea rápido: un formulario por cliente no es viable porque son muchos clientes [51:16]. Álvaro dice que lo irá pensando [49:58]. Fátima: no hay que cargarles con mucho más; el fichero es de revisión [1:08:27]. Nuevos clientes se añadirían a mano [1:10:39]. Álvaro plantea sustituir el Excel por una herramienta con enlace que mantenga la estructura [1:10:30]. Fátima dice que esto habría que verlo "con Dan" (probablemente David; no seguro) [1:10:56].
- Fátima señala que el cambio de mentalidad es grande y se avanza con flexibilidad [1:06:43, 1:07:15].

### 7. Prueba de carpeta compartida

- Álvaro creará una carpeta en OneDrive o SharePoint, recurso de Docenteo, compartida con Tinkle, para ver si sirve de repositorio común, como la que ya existe en el entorno de Havas ("habas" en la transcripción). Es parte de la búsqueda de dónde levantar la capacidad. Pide validar acceso y subida de un fichero. Enviará un correo con instrucciones [1:04:34, 1:05:33, 1:05:51].

### 8. Próximos pasos generales

- Álvaro: seguir avanzando, empezar mayo, y explicar qué ofrece la herramienta; después se decide si ayuda [1:11:13].
- La decisión de herramienta la toma David [1:11:14].
- Presupuesto: Fátima pregunta si se deja parado; Álvaro responde que no: la construcción del presupuesto hay que terminar de verla, porque esa lógica hay que meterla sí o sí. Queda pendiente cómo entra el real y cómo se ajustan los meses [1:11:42, 1:11:50].
- Antes, Álvaro pide a Fátima resolver el tema de los repartos y preparar cómo se presenta el revenue a las directoras, y después hacer la reunión para cerrar presupuesto [1:03:32, 1:04:04].
- Siguiente sesión: Fátima avisa cuando lo tenga; se piensa en miércoles o jueves, después de una reunión ya prevista "mañana o pasado" en la que se vería Compensation [1:12:40, 1:12:43, 1:13:24]. Fecha no cerrada.

## Decisiones

- Punto de partida, no cerrado: la pestaña de clientes del checklist es el maestro inicial, al que se añadirán columnas (límite de crédito, posiblemente forma de pago) [27:51].
- Se parte del dato bruto de los extractos (Oracle y Databox), sin manipularlo a mano; el formato lo hará el modelo. Pendiente de confirmar en la práctica [6:52, 8:07, 10:40].
- Los meses cerrados (completos) toman el real del checklist; los abiertos se proyectan [54:51, 36:21].
- El revenue se construye desde MMS, se revisa con las directoras y se pega en el forecast [57:37]. Es la descripción del proceso actual que se toma como base, no una decisión nueva [1:03:08].
- Portugal se sube a Magnitude como una única línea, sin detalle [42:48]. Práctica actual, no decisión de la reunión.
- Orden de columnas del presupuesto: FT8 a la izquierda, FT3 y budget a la derecha [35:47]. Práctica actual, no decisión de la reunión.
- Los importes por cliente se guardan con decimales y el ajuste se hace al subir (propuesta de Fátima, sin cierre formal) [50:51].

## Reglas de negocio mencionadas

- Solo los meses completos cerrados cuentan como real; el mes abierto es proyectado (Fátima y Josep) [37:51, 38:00].
- No se puede adelantar el cierre de un mes (Fátima) [38:07].
- El aging se calcula a una fecha elegida, normalmente cierre de mes, y al menos dos veces al mes (Fátima) [19:13].
- Las columnas de tramos del aging son las que usa el Grupo (Josep) [18:30].
- El porcentaje de crecimiento de Gross Income sobre el cierre del año anterior lo dan (normalmente "global", probablemente el Grupo) o lo marca David; varía cada año (Fátima) [39:26, 40:27].
- El Gross Income objetivo, en septiembre, se calcula sobre el cierre estimado (FT8), porque el cierre del año anterior no existe aún (Fátima) [39:49].
- Facturación real = facturación ya comprometida por cliente; new business = facturación necesaria aún sin cliente (Fátima) [40:57].
- Honorarios: se toman de MMS, que tiene los contratos a futuro (Josep) [46:33].
- Producción: solo se conoce al hacerse; se estima con la directora (Josep) [47:22].
- El reparto mensual de los meses abiertos se hace por porcentajes, normalmente con el reparto del año anterior; no hay criterio fijo (Fátima) [58:14, 1:01:27].
- Los totales anuales cuadran con el revenue; por meses no, porque MMS cambia (Fátima) [54:12, 53:02].
- Las directoras solo ven sus clientes, no los del resto (Josep) [45:09].
- El fichero de rentabilidad lo completan las directoras y finanzas lo revisa; el fichero de forecast y revenue con todos los clientes es de administración y las directoras no lo ven (Fátima y Josep) [44:12, 45:09].
- Portugal no se sube a Magnitude con detalle, por decisión de la empresa (Fátima) [42:48].
- El riesgo se calcula contra el límite máximo de crédito del cliente; si el saldo lo supera, es riesgo excedido (Josep) [22:13].
- En extractos de Oracle, los decimales vienen con punto y hay que cambiarlos a coma (Fátima) [12:24].
- Las pestañas de reclamaciones no se usan para el cálculo (Fátima) [14:47, 15:14].
- Presupuesto: FT3 se presenta en marzo y FT8 en septiembre; el presupuesto siguiente empieza en septiembre (Fátima) [35:36].
- Los contratos se renegocian en fechas concretas; por eso el honorario futuro puede cambiar (Josep) [46:33].
- Los agings de proveedores no se piden todavía por el Grupo (Josep) [18:30].
- En el extracto de proveedores de Databox se descarta la última fila, que es el total (Fátima) [17:02].

## Tareas pendientes

- Álvaro: crear la carpeta compartida (OneDrive o SharePoint) entre Docenteo y Tinkle y enviar el correo con instrucciones. Se espera que Fátima y Josep validen acceso y suban un fichero de prueba [1:04:34, 1:05:33, 1:05:51].
- Fátima y Josep: validar acceso a la carpeta compartida, subir un fichero y reportar si hay bloqueo [1:05:33].
- Fátima: avisar a Álvaro cuando tenga el trabajo validado con David y proponer fecha de la siguiente sesión (mañana a una hora, si quiere) [1:05:58, 1:06:07].
- Fátima: consultar con David la regla de reparto mensual del Gross Income (es un solo tema, no dos) y contestar a Álvaro, incluidos los distintos criterios posibles para habilitarlos como opción [59:18, 1:01:40, 1:02:27, 1:12:19].
- Fátima: preparar y enviar a Álvaro el Excel de ejemplo con la lógica de reparto (ejemplo con 957 y el mes de julio); hoy ese Excel no existe como tal [1:00:15, 1:00:34].
- Fátima: localizar y compartir el Excel con el detalle de Portugal por empresa y mes (es un único Excel; la versión anterior del acta lo desdoblaba en dos) [42:48, 43:11].
- Fátima: enseñó el fichero de rentabilidad en pantalla [1:08:55]; no hubo compromiso de enviarlo. Abierto: si Álvaro necesita copia (corrección: la versión anterior decía "enviar") [44:12].
- Fátima: enviar el extracto de proveedores de Databox en Excel y en CSV ("te mando los 2") [16:23, 16:47].
- Fátima: guardar sin modificar y subir el extracto bruto de aging de clientes descargado de Oracle, a petición de Álvaro [8:21, 13:05, 13:13].
- Fátima: subir los cuatro ficheros de presupuesto y "el otro" que dice apuntarse [28:34].
- Fátima: preparar cómo se presenta el revenue a las directoras, para verlo en la reunión de cierre de presupuesto [1:03:32, 1:04:04].
- Sin responsable: incorporar fecha de factura, fecha de vencimiento y fecha contable al aging de proveedores (lo pide Fátima; no es una tarea suya de proponerlo, ya lo propuso) [1:09].
- Josep: ofreció enseñar cómo se extraen los agings [5:18]. En la sesión Fátima mostró la descarga de Oracle y de Databox [9:07, 15:58]; no consta si queda algo más por enseñar.
- Josep o Fátima (no queda claro quién): mirar si en Databox hay también aging de clientes. Fátima lo propone y Josep dice "sí, pero" lo ve irrelevante [10:18, 10:38, 10:40].
- Josep y Fátima: ver la parte de Compensation en una reunión ya prevista "mañana o pasado" (posiblemente el miércoles) [1:12:19, 1:12:40, 1:12:43]. No consta si Álvaro asiste.
- Álvaro, Fátima y Josep: siguiente sesión para cerrar presupuesto (cómo entra el real y cómo se ajustan los meses) y, si da tiempo, Compensation; miércoles o jueves, sin fecha cerrada. Fátima avisa por correo cuando lo tenga [1:04:04, 1:11:50, 1:12:43, 1:13:24].
- Álvaro: incorporar el maestro de clientes del checklist como punto de partida y añadirle columnas (límite de crédito) [27:51].
- Álvaro: decir a Josep si necesita un maestro de clientes extraído de Oracle con más campos [24:59]; y plantear qué información nueva añadir a la pestaña cuando presente el modelo [27:28].
- Sin responsable: estudiar si se puede conectar directamente a las fuentes o si hay mecanismo de acceso ("salvoconducto"). Fue un comentario de Álvaro, sin compromiso [11:18].
- Álvaro: intentar construir la lógica de reparto con lo explicado; si no, pedir a Fátima que se lo explique [1:00:40].
- Álvaro: enseñar qué ofrece la herramienta (por ejemplo, un formulario que reparte automáticamente) antes de que se comunique nada a las directoras; en mayo [1:08:02, 1:08:20, 1:11:13].
- Álvaro: pensar la forma del formulario por directora, para que sea muy sencillo y rápido con muchos clientes [49:58, 51:16, 1:10:51].
- David (no presente): decidir la herramienta y el criterio de reparto [1:11:14, 1:02:27].
- Fátima: ver con "Dan" (probablemente David; no seguro) la propuesta de herramienta para las directoras [1:10:56].
- Sin responsable: obtener la fecha de vencimiento de AP y AR y decidir cómo llega al modelo [6:01, 6:11].
- Sin responsable: decidir si los límites de crédito van en el maestro de clientes, en Excel o en una ficha de Power BI [23:21, 23:46].
- Forma de pago del cliente en el maestro: Fátima la apuntó y la descartó en el momento [28:04]. No se reabre salvo que alguien lo pida.
- Sin responsable: dar pestaña propia en el presupuesto a la sociedad "H Advisor" (probablemente HAPA) [31:17, 31:25].
- Sin responsable: desglosar Portugal en el modelo sin subir ese detalle a Magnitude [42:48, 43:11].
- Sin responsable: preparar la revisión de julio con directoras (estructura mensualizada por directora) [44:12].
- Sin responsable: definir el reparto de gastos sin centro de coste entre directoras [1:08:55].
- Sin responsable: definir cómo se reparte el Gross Income por persona según dedicación, incluidas las dedicaciones sin rellenar [1:08:55].
- Sin responsable: decidir quién gestiona el formulario de nuevos clientes y su dirección [1:10:39].
- Sin responsable: revisar el aging de proveedores con detalle de tramos (no pedido aún por el Grupo) [18:30].
- Sin responsable: confirmar si FT8 es acumulado. La duda viene de CONTEXT; en la reunión no se trató. Que la columna FT8 del fichero actual sea la del año anterior sí quedó explicado [31:29, 35:47].
- Sin responsable: aclarar por qué la línea 17 está en positivo y la 33 en negativo en el forecast [55:01].

## Requisitos pedidos por el cliente

- Aging de clientes y proveedores en Power BI, incluida la fecha de vencimiento, con fecha de cálculo elegible y tramos como los del Grupo [6:01, 18:30, 19:13].
- Consolidado por fecha de vencimiento, con filtro por empresa [15:23].
- Control de riesgo de crédito por cliente, visible en el propio aging de clientes: límite, saldo y alerta de riesgo excedido [21:36, 22:42].
- Límite de crédito dentro del maestro de clientes (la forma de pago se apuntó y se descartó) [23:27, 28:04].
- Aging de proveedores con fecha de factura, fecha de vencimiento y fecha contable [1:09].
- Pestaña propia de la sociedad "H Advisor" (probablemente HAPA) en el presupuesto [31:17].
- Presupuesto con tres columnas: FT8 (en curso), FT3 (presentado) y budget (anterior) [31:29, 35:47].
- Estructura de P&L igual a la del checklist, proyectada hasta cierre de año [33:10].
- Real de meses cerrados del checklist; proyección de los meses abiertos [54:51, 36:21].
- Revenue por cliente, construido desde MMS, revisado con las directoras y pegado en el forecast [57:37].
- Reparto mensual con varias reglas configurables, con borrador por defecto [1:01:56].
- Importes con decimales; no redondear a 5000 lo que vale 4900 [50:24].
- Formulario por directora precargado con MMS, para que cada una vea solo sus clientes [51:23]. Propuesta de Álvaro aceptada en principio por Fátima; la herramienta la decide David [1:11:14].
- Que el ajuste sea rápido con muchos clientes, no un formulario por cliente (Fátima) [51:16].
- Que las directoras puedan añadir nuevos clientes a mano (Fátima) [1:10:39].
- Fichero de rentabilidad mensualizado y por directora, en la revisión de julio [44:12].
- Resumen de rentabilidad por directora: Gross Income, personal y Contribution [1:08:55].
- Gastos por centro de coste y gastos sin centro de coste, repartidos entre directoras [1:08:55].
- Gross Income repartido por persona según dedicación [1:08:55].
- Que las cifras cuadren, aunque por meses pueda haber diferencias explicadas por MMS vivo [54:12].
- Portugal como una única línea hacia Magnitude [42:16, 42:48], con su detalle desglosado dentro del modelo (Fátima lo ve ideal) [43:11].
- (Corrección: la versión anterior recogía aquí "evitar subir más ficheros de los necesarios" [6:01]. Josep no lo pide: dice que el aging debe estar dentro aunque haya que subir más ficheros.)
- Salida de presupuesto en el formato de carga de Magnitude [28:59, 29:02].

## Dudas abiertas

- "RP" y "Abbas": probablemente "RP" es ERP [19:28] y "Abbas" (también "habas" [1:04:34]) es Havas, el Grupo [11:09]. Interpretación no segura.
- Nombres de algunas sociedades: no se entienden ("European Just", "Euro", "Jazz"). Relación entre "H Advisor", "Chadvisors", "Acento" y HAPA del glosario [30:18, 30:41, 31:04, 42:16].
- FT8: en el fichero actual la columna FT8 es la del año anterior, y en el próximo será la del año en curso; esto sí quedó explicado. Sigue abierto si es acumulado, pregunta que viene de CONTEXT y no se trató [31:29, 35:47].
- Quién fija el porcentaje de crecimiento: "global" (probablemente el Grupo) o David [39:26].
- Por qué la línea 17 está en positivo y la 33 en negativo en el forecast [55:01].
- Si la pestaña de resumen del aging se usa o no: la frase de Fátima es ambigua [14:14].
- Qué es "la respuesta de Aras" que menciona Josep (quizá Havas) y si afecta al proyecto; Fátima dice "después hablamos" [8:51, 8:54].
- Fecha de la revisión con directoras: julio [44:12, 49:36] o finales de junio y principios de julio [1:07:56]; Fátima no lo tiene claro [1:07:35].
- Si Docenteo asiste a la reunión de Compensation del miércoles [1:12:40, 1:12:43].
- Criterio de reparto mensual del presupuesto: cuál aplicar y quién lo fija (David) [1:01:27].
- Quién fija y revisa los límites de crédito, y con qué frecuencia cambian [22:43, 23:00].
- Si la "sección" del cliente es su centro de coste [27:03].
- Qué es "Matrix" en la frase sobre la reunión del miércoles: no se entiende [1:12:43].
- Alcance de Compensation: qué incluye y cómo se obtiene. Hay "un fichero que está muy bien" sin detalle [1:12:19].
- Cómo se reparten entre directoras los "item" (otros gastos, según Fátima [1:03:32]) que no van por centro de coste [1:08:55].
- Papel de Dan: no se entiende; probablemente es David mal reconocido [1:10:56].
- Qué significa "global" cuando se dice que "global nos dice" el porcentaje de crecimiento (probablemente Grupo) [39:26].
- Cómo se obtiene la fecha de vencimiento desde AP y AR [5:46, 6:25].
- Si Databox tiene aging de clientes [10:38, 10:40].
- Cómo se calcula cada vez el porcentaje de crecimiento y si se revisa durante el año [40:31].
- Unidades de las cifras del presupuesto (miles o euros): la transcripción habla de miles en algún punto, sin confirmar [58:50, 59:18].
- Si el fichero de rentabilidad se mantendrá en Excel o pasará a una herramienta [1:08:02].
- Qué datos de la sociedad Portugal se necesitan y cuáles no se suben a Magnitude [42:48].
- Qué pasa con las directoras que no rellenan dedicaciones [1:08:55].

## Riesgos

- Procesos muy manuales: copiar y pegar, arrastrar fórmulas, refrescar. Alta dependencia de pocas personas (Fátima, Josep y David).
- Cifras que no cuadran por meses: MMS está vivo y el real viene del checklist. Riesgo de comunicar cifras distintas al Grupo.
- Calendario: el presupuesto debe estar listo a finales de junio o principios de julio; agosto sin personal.
- Resistencia y heterogeneidad: cada directora trabaja de forma distinta; el formulario podría sobrecargarlas.
- Dependencia de extracciones manuales de Oracle, Databox y MMS. No hay conexión directa.
- Fecha de vencimiento no disponible en el extracto actual. Límite de crédito en Excel manual, que puede quedar obsoleto.
- Datos sensibles: detalle de Portugal y rentabilidad por cliente. Control de acceso en la carpeta compartida.
- Criterio de reparto no fijo: los resultados cambian de un ciclo a otro.
- Transcripción automática con errores de nombres y términos. Algunas afirmaciones pueden estar mal interpretadas.

## Términos para el glosario

- Aging (en la transcripción aparece como "legging", "edging" o "eging"): antigüedad de facturas pendientes de cobro o pago. Completa CONTEXT; las variantes probablemente son errores de transcripción.
- Riesgo máximo de crédito (límite de crédito): importe máximo que Tinkle concede a un cliente. No está en CONTEXT.
- Riesgo excedido: saldo pendiente de un cliente por encima de su límite. No está en CONTEXT.
- Maestro de clientes: pestaña con código Oracle, código MMS, nombre, empresa, sección y directora. Completa CONTEXT (Maestro).
- Sección: columna del maestro de clientes. No confirmado si es centro de coste; CONTEXT ya lo señala como pendiente.
- Fichero de revenue: por cliente, con meses reales y estimados, construido desde MMS y revisado con directoras. Entra al forecast. Contradice en parte CONTEXT, que define Revenue como ingreso de un cliente: aquí es también el nombre de un fichero.
- New business: facturación necesaria para llegar al objetivo y todavía no asignada a un cliente. No está en CONTEXT.
- Facturación real: facturación ya comprometida por cliente, por ejemplo cuota fija mensual. No está en CONTEXT.
- Fees: el cliente lo usa como sinónimo de honorarios [57:30]. CONTEXT pide evitar "fees" y usar Honorarios.
- FT3, FT8 y budget: ediciones del forecast y presupuesto. Coinciden con CONTEXT en calendario (FT3 en el cuarto mes, FT8 en el noveno). Falta aclarar si FT8 es acumulado.
- Real: el cliente presentó marzo como real antes de cerrarlo. Contradice CONTEXT, que exige periodo cerrado. Conviene anotarlo.
- Compensation (coste de personal, "staff cost"): segundo bloque del fichero de forecast que se mostró (Gross Income, Compensation y gastos) [38:29]; también aparece como "personal" en el resumen del fichero de rentabilidad [1:08:55]. Completa CONTEXT, que define Empleado y su coste, pero no el bloque.
- Fichero de rentabilidad: fichero que completan las directoras con Gross Income, personal y Contribution por equipo. Hoy se hace por totales. Completa CONTEXT.
- Porcentaje de crecimiento: incremento que fija el Grupo sobre el cierre para fijar el objetivo de Gross Income. No está en CONTEXT.
- Gastos externos y otros gastos: bloques de gasto debajo de personal. No están en CONTEXT.
- Databox: fuente de extracto de proveedores. No está en CONTEXT.
- Cuentas a pagar (AP) y cuentas a cobrar (AR): módulos de Oracle de los que sale la fecha de vencimiento. No están en CONTEXT.
- MMS vivo: MMS cambia de forma continua, por eso los meses no cuadran con el checklist. Completa CONTEXT (MMS).
- Portugal: se sube a Magnitude como una única línea. Completa CONTEXT.
- Contradicciones y variantes frente a CONTEXT detectadas en la revisión:
  - "Contribution" [1:08:55]: CONTEXT usa Contribución. Variante en inglés del cliente.
  - "budget" y "B uno" [35:01, 35:09]: CONTEXT pide Presupuesto y evitar budget y B01.
  - "Facturación real" [40:57]: CONTEXT pide evitar "facturación" y usar Revenue. Conviene decidir si "facturación real" (comprometida) entra como término propio.
  - "empresa" [27:03, 15:23]: CONTEXT pide Sociedad. Aquí es además el nombre literal de una columna del maestro.
  - "Acento" [22:20, 31:04]: CONTEXT lo marca como término a evitar (HAPA). En 22:20 parece referirse a un cliente o sociedad; no se entiende con seguridad.
  - "Abbas" y "habas" [11:09, 1:04:34]: probablemente Havas, el Grupo de CONTEXT.
  - Planning: CONTEXT lo define como hojas de captura en Fabric donde las directoras revisan el forecast. En la reunión la herramienta no está decidida (la decide David) y las directoras no ven el fichero de forecast, sino el de rentabilidad [44:12, 1:11:14].
  - Relación Forecast de CONTEXT ("la Directora puede corregir en Planning"): hoy son Fátima y David quienes ajustan el revenue tras reunirse con cada directora [43:37, 57:37].
  - "Sección" [27:03]: CONTEXT la lista como término a evitar para Centro de coste; sigue sin confirmar que sean lo mismo.
  - "BMS" [23:07]: error de transcripción de MMS.
