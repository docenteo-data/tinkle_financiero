# Preguntas para Tinkle (Josep / Álvaro) — TXT de Grupo pendientes

## General y lo más importante

1. El fichero de marzo compartido, ¿es exactamente lo que se genera cada mes para el reporting de Grupo, o tiene alguna diferencia (formato, filtros) respecto al proceso real?
2. Por varias menciones en las reuniones y en el nombre de la carpeta compartida, se ha asumido que el destino final de estos ficheros es el sistema "Magnitude". ¿Es correcto, o el destino es otro / ha cambiado?
3. Cuando se prepara hoy a mano el fichero, el cliente aparece con un código corto (ej. `IKEA`, `01500400`, `AMAZO594`). ¿De dónde sale ese código exactamente? ¿Existe un listado o fichero en algún sitio que relacione cada cliente con su código? (Afecta a Ageing, Revenue y Pendiente_Facturar).

## Ageing

4. Los tramos de antigüedad ya están calculados en días (0-30, 31-60, 61-90, 91-120, 121-180, más de 1 año). En el fichero final aparecen como códigos `GR0, GR1, GR2, GR3, GR4, GR5, GR8C, GR9C` y `GRICFLAG`. ¿Qué tramo corresponde a cada código?
5. `GRICFLAG` no parece ser un tramo de días, sino algo aparte. ¿Es el marcador de operaciones intercompany (con otras empresas del grupo Havas)?
6. El fichero de marzo compartido solo tenía clientes. ¿Ageing de Grupo también necesita un bloque de proveedores, o es solo de clientes?

## Revenue

7. La tabla de ingresos identificada como fuente está vacía en el sistema. ¿Se puede relanzar su proceso de carga para que vuelva a tener datos?
8. ¿El importe que va al fichero es el ingreso total del cliente (honorarios + producción juntos), o solo una de las dos partidas?

## Pendiente_Facturar

9. Se ha intentado reproducir el cálculo de varias formas con los datos de MMS (por fecha de factura en blanco, desagregando también por estado de pedido) y en ningún caso salen números parecidos a los del fichero de ejemplo. ¿Se puede mostrar, con el fichero de marzo delante, cómo se calcula exactamente el importe pendiente de facturar de un cliente concreto (por ejemplo Repsol)?
10. En MMS hay varios estados de pedido (`P`, `C`, `I`, `FP`, `E`, entre otros). ¿Cuáles de esos estados cuentan como "pendiente de facturar"?

## Working_Capital

11. No se ha encontrado ningún dato en el sistema que explique este fichero. ¿Working_Capital sale de algún cálculo, o son líneas que se introducen a mano directamente en Magnitude?
12. Si sale de un cálculo, ¿de qué información parte (aging, tesorería, algo del balance)?

## CashFlow

13. El fichero se llama internamente "HMES - Asientos con contrapartida fija" y mezcla cuentas de banco, proveedores, clientes, intercompany, nóminas, gastos financieros e impuestos — no es solo la cuenta 572. ¿Qué informe o consulta concreta de Oracle genera exactamente este listado, y con qué criterio selecciona esas líneas?
14. ¿La fecha de inicio del informe es siempre el 1 de enero del ejercicio (acumulado desde principio de año hasta el cierre), o depende de otra cosa?
15. Al principio de cada línea del fichero aparece un código de compañía (ej. `53`). ¿Qué código interno es ese?
