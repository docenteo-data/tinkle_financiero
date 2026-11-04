# Estado de los ficheros de Grupo pendientes

- 03/11/2026. Ficheros de Grupo que faltan por construir en Fabric: Ageing, Revenue, Pendiente_Facturar, Working_Capital y CashFlow. Balance y Saldos 4_7 ya existen.
- Arquitectura, la misma que Balance: una vista `vw_Export_<fichero>` en el esquema `200` con la lógica de negocio, un notebook que da formato y escribe el TXT en `Files/Exportaciones/<fichero>/`, y una actividad Copy data por carpeta en el pipeline `Grabar salidas` hacia `2. Salida de ficheros/<fichero>` en SharePoint.
- Referencia de validación: los TXT de marzo de 2026 que se subieron a Magnitude (carpeta `3.Fuentes/2026 03 - 0001 Magnitude Marzo/` del OneDrive del proyecto). Se comprueba con `scripts/validar_ficheros_grupo.py` y su test `tests/test_validar_ficheros_grupo_e2e.py`.
- Estimación en jornadas de 8 horas, trabajando con IA. Detalle de cada línea en `docs/prompts/PROMPT_nueva_conversacion_<fichero>.md` y preguntas abiertas en `docs/contexto/PREGUNTAS_PARA_TINKLE.md`.

## Estado por línea

| Línea | Estado | Validado con datos | Se puede construir ya | Bloqueo para entregar | Jornadas |
|---|---|---|---|---|---|
| Ageing | Lógica cerrada | Importes por sociedad y tramo de aging iguales al TXT de marzo (35 de 35, diferencia máxima 0,0004). Fuente `200.Aging_Clientes`, corte a fin de mes, tramos del DAX `AgingBucket`, importe en miles. Intercompañía (`GRICFLAG`) desde `Interno = 'Y'`, casi seguro. Solo clientes. `GRRL` no se informa (no hay límites de crédito). | Sí, entero, con código de cliente provisional: el cruce factura, MMS y Excel de Revenue reproduce 192 de 280 líneas | Maestro de clientes de Magnitude. Decidir si se informa `GRPROV` (la cuenta 490 tiene saldo y marzo no lo lleva) | 1 a 1,5 |
| Revenue | Lógica cerrada | Medida `REAL (Fees & other)`, acumulada del año, signo invertido, en miles. Total por sociedad igual al TXT en 4 de 5; COMM difiere en 6,82 (0,24%). Por cliente, 132 de 172 líneas con el Excel de Revenue | Sí, entero | Maestro de clientes de Magnitude. Explicar la diferencia de COMM | 1 a 1,5 |
| Pendiente_Facturar | Regla desconocida | Escala probable en miles (misma plantilla que Ageing, código `GRWIP`). La suma de MMS sin factura de cliente no reproduce el TXT ni por estado de orden ni por cliente | Solo el esqueleto (vista vacía, notebook, copia) | Sesión con Tinkle para ver el cálculo con un cliente real | 0,25 ahora; 1 a 2 después |
| Working_Capital | Lógica desconocida | Layout, literales (`ORIG07-01`, `0000.PACKAGE`) y redondeo a miles iguales a Balance. Las cuentas `MBFR010/011/020/021` no están en ninguna tabla de Fabric | Solo el esqueleto | Lógica de cálculo, o confirmación de que se introduce a mano | 0,25 ahora; 0,5 a 1 después |
| CashFlow | Fuente confirmada, selección desconocida | Fuente `200.Oracle_historico` (sus columnas coinciden con el listado). El listado "HMES - Asientos con contrapartida fija" mezcla bancos, proveedores, clientes, nóminas e impuestos: no es solo la cuenta 572 | Solo el escritor del formato (cabecera de informe, Latin-1, CRLF, coma decimal) | La macro que lo calcula. Confirmar si el listado es lo que se entrega | 0,5 ahora; 1 a 3 después |

## Trabajo común

| Bloque | Jornadas |
|---|---|
| Código de cliente Magnitude en `Dim_Clientes`, versión provisional desde `Revenue 2026 FT3.xlsm` | 0,5 ahora |
| Código de cliente Magnitude definitivo, al recibir el maestro de Tinkle (carga y repaso de las validaciones) | 0,5 a 1 después |
| Integración en `Grabar salidas`, prueba de extremo a extremo y publicación | 0,5 a 1 |

## Totales

| | Jornadas |
|---|---|
| Lo que se puede hacer ya | 4 a 5,5 |
| Lo que queda tras desbloquear | 3 a 7 |
| **Total** | **7 a 12,5** |

## Ruta crítica

El maestro de clientes de Magnitude bloquea la entrega de Ageing, Revenue y Pendiente_Facturar. El Excel `Revenue 2026 FT3.xlsm` no basta: le faltan 21 de los 167 códigos usados en marzo (19 no están en ningún Excel del proyecto) y asigna a algunos clientes un código distinto del que se usó en marzo (sobre todo el genérico `16300001` y los de intercompañía).

## Avisos

- `Aging_Clientes` guarda solo la última carga, sin fecha de foto: un mes pasado no se puede regenerar desde Fabric, hay que recargar su Excel de origen. En Balance el histórico sí está (`Fact_Actuals`), aunque la vista toma siempre el último periodo.
- El nombre de cliente del aging viene truncado a 25 caracteres: el cruce de cliente se hace por número de factura contra MMS, no por nombre.
- `notebooks/Generar_txt_Ageing.ipynb` es un borrador antiguo con una premisa equivocada: solo es reutilizable su parte de escritura de ficheros.
- Crear las vistas y publicar en Fabric lo hace una persona del equipo (`publicar_fabric.py` con confirmación expresa), igual que ejecutar los pipelines.
