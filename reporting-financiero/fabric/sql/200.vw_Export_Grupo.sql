CREATE   VIEW [200].[vw_Export_Grupo]
AS

WITH UltimoPeriodo AS
(
    SELECT
        MAX(CAST([Periodo] AS date)) AS PeriodoMaximo
    FROM [lh_tinkle_financiero].[300].[Fact_Actuals]
    WHERE [Periodo] IS NOT NULL
),

/* ============================================================
   1. SALDO POR CUENTA CONTABLE ORIGEN

   A / P:
       acumulado histórico hasta el periodo de cierre.

   R:
       acumulado únicamente desde enero del ejercicio.

   IMPORTANTE:
       Primero agregamos por Cuenta_origen.
       Después dividimos entre 1.000 y redondeamos.
       Finalmente agruparemos por Cuenta_magnitude.
   ============================================================ */

CuentaOrigen AS
(
    SELECT
        f.[Sociedad],
        f.[Cuenta_origen],

        up.[PeriodoMaximo] AS Periodo,

        m.[Cuenta_magnitude] AS CuentaReporting,

        CAST(
            ROUND(
                SUM(COALESCE(f.[Saldo], 0)) / 1000.0,
                0
            )
            AS bigint
        ) AS SaldoMiles

    FROM [lh_tinkle_financiero].[300].[Fact_Actuals] AS f

    INNER JOIN [lh_tinkle_financiero].[300].[Dim_Mapeo_Cuentas] AS m
        ON m.[ID_Account] = f.[ID_Account]

    CROSS JOIN UltimoPeriodo AS up

    WHERE
        m.[Cuenta_magnitude] IS NOT NULL

        AND LTRIM(RTRIM(m.[Cuenta_magnitude])) <> ''

        /* P12000 se calcula posteriormente */
        AND m.[Cuenta_magnitude] <> 'P12000'

        AND
        (
            /* =================================================
               BALANCE:
               acumulado histórico hasta cierre
               ================================================= */
            (
                LEFT(m.[Cuenta_magnitude], 1) IN ('A', 'P')

                AND CAST(f.[Periodo] AS date)
                    <= up.[PeriodoMaximo]
            )

            OR

            /* =================================================
               P&L:
               acumulado desde enero del ejercicio
               ================================================= */
            (
                LEFT(m.[Cuenta_magnitude], 1) = 'R'

                AND YEAR(CAST(f.[Periodo] AS date))
                    = YEAR(up.[PeriodoMaximo])

                AND CAST(f.[Periodo] AS date)
                    <= up.[PeriodoMaximo]
            )
        )

    GROUP BY
        f.[Sociedad],
        f.[Cuenta_origen],
        up.[PeriodoMaximo],
        m.[Cuenta_magnitude]
),

/* ============================================================
   2. AGRUPACIÓN POR CUENTA MAGNITUDE

   Signos validados contra los TXT oficiales:

       A → mantiene signo
       P → invierte signo
       R → invierte signo
   ============================================================ */

CuentaMagnitude AS
(
    SELECT
        [Sociedad],
        [Periodo],
        [CuentaReporting],

        SUM(
            CASE

                WHEN LEFT([CuentaReporting], 1) = 'A'
                    THEN [SaldoMiles]

                WHEN LEFT([CuentaReporting], 1) IN ('P', 'R')
                    THEN -[SaldoMiles]

                ELSE 0

            END
        ) AS ImporteGrupo

    FROM CuentaOrigen

    GROUP BY
        [Sociedad],
        [Periodo],
        [CuentaReporting]
),

/* ============================================================
   3. ASIGNACIÓN DEL CÓDIGO DE SOCIEDAD DE GRUPO

   No modificamos Dim_Sociedades.
   Usamos CodigoSociedad únicamente como código interno.
   ============================================================ */

DatosConSociedad AS
(
    SELECT
        c.[Sociedad],
        c.[Periodo],

        CASE s.[CodigoSociedad]

            WHEN 'COMM'
                THEN 'ESP066'

            WHEN 'EURO'
                THEN 'ESP067'

            WHEN 'JAZZ'
                THEN 'ESP068'

            WHEN 'ONION'
                THEN 'ESP069'

            WHEN 'CONS'
                THEN 'ESP070'

            ELSE NULL

        END AS CodigoGrupo,

        c.[CuentaReporting],
        c.[ImporteGrupo]

    FROM CuentaMagnitude AS c

    INNER JOIN [lh_tinkle_financiero].[300].[Dim_Sociedades] AS s
        ON s.[Sociedad] = c.[Sociedad]
),

/* ============================================================
   4. SOLO SOCIEDADES QUE REPORTAN ACTUALMENTE A GRUPO

   Portugal y HAPA quedan fuera hasta disponer
   del código de Grupo correspondiente.
   ============================================================ */

DatosSociedadValidos AS
(
    SELECT
        [Sociedad],
        [Periodo],
        [CodigoGrupo],
        [CuentaReporting],
        [ImporteGrupo]

    FROM DatosConSociedad

    WHERE
        [CodigoGrupo] IS NOT NULL
),

/* ============================================================
   5. RESULTADO DEL EJERCICIO

   P12000 = suma de todas las cuentas R ya transformadas
             y redondeadas a miles.
   ============================================================ */

ResultadoEjercicio AS
(
    SELECT
        [Sociedad],
        [Periodo],
        [CodigoGrupo],

        'P12000' AS CuentaReporting,

        SUM([ImporteGrupo]) AS ImporteGrupo

    FROM DatosSociedadValidos

    WHERE
        LEFT([CuentaReporting], 1) = 'R'

    GROUP BY
        [Sociedad],
        [Periodo],
        [CodigoGrupo]
),

/* ============================================================
   6. CUENTAS NORMALES + P12000
   ============================================================ */

DatosFinales AS
(
    SELECT
        [Sociedad],
        [Periodo],
        [CodigoGrupo],
        [CuentaReporting],
        [ImporteGrupo]

    FROM DatosSociedadValidos

    UNION ALL

    SELECT
        [Sociedad],
        [Periodo],
        [CodigoGrupo],
        [CuentaReporting],
        [ImporteGrupo]

    FROM ResultadoEjercicio
)

/* ============================================================
   7. FORMATO FINAL MAGNITUDE
   ============================================================ */

SELECT

    'C' AS D_CA,

    REPLACE(
        CONVERT(char(7), [Periodo], 120),
        '-',
        '.'
    ) AS D_DP,

    '' AS D_DEVTR,

    '' AS D_SAJOB,

    '' AS D_DIM2,

    '' AS D_DIM3,

    '' AS D_ACTY,

    '' AS D_CLIENT,

    REPLACE(
        CONVERT(char(7), [Periodo], 120),
        '-',
        '.'
    ) AS D_PE,

    [CodigoGrupo] AS D_RU,

    [CodigoGrupo] AS D_ORU,

    [CuentaReporting] AS D_AC,

    'ASOC01' AS D_FL,

    '0LIA01' AS D_AU,

    '' AS D_T1,

    '' AS D_T2,

    'EUR' AS D_CU,

    'ORIG07-01' AS D_TO,

    '0000.PACKAGE' AS D_GO,

    '' AS D_LE,

    '' AS D_NU,

    '' AS D_DIM4,

    '' AS D_DEST,

    '' AS D_AREA,

    '' AS D_TFTR,

    CAST([ImporteGrupo] AS bigint) AS P_AMOUNT,

    '' AS P_COMMENT

FROM DatosFinales

WHERE
    [ImporteGrupo] <> 0;

