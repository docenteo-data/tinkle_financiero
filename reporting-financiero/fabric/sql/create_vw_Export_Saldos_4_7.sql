CREATE   VIEW [200].[vw_Export_Saldos_4_7]
AS

WITH UltimoPeriodo AS
(
    SELECT
        MAX(CAST([Periodo] AS date)) AS PeriodoMaximo
    FROM [lh_tinkle_financiero].[300].[Fact_Actuals]
    WHERE [Periodo] IS NOT NULL
),

Saldos AS
(
    SELECT
        f.[Sociedad],

        up.[PeriodoMaximo] AS Periodo,

        f.[Cuenta_origen] AS Cuenta,

        MAX(f.[Descripcion]) AS Descripcion,

        SUM(
            COALESCE(f.[Saldo], 0)
        ) AS Saldo

    FROM [lh_tinkle_financiero].[300].[Fact_Actuals] AS f

    CROSS JOIN UltimoPeriodo AS up

    WHERE
        f.[Cuenta_origen] IS NOT NULL
        AND LTRIM(RTRIM(f.[Cuenta_origen])) <> ''

        AND
        (
            /* =================================================
               P&L:
               cuentas 6 y 7 acumuladas desde enero
               ================================================= */
            (
                LEFT(f.[Cuenta_origen], 1) IN ('6', '7')

                AND YEAR(CAST(f.[Periodo] AS date))
                    = YEAR(up.[PeriodoMaximo])

                AND CAST(f.[Periodo] AS date)
                    <= up.[PeriodoMaximo]
            )

            OR

            /* =================================================
               BALANCE:
               resto de cuentas acumuladas históricamente
               ================================================= */
            (
                LEFT(f.[Cuenta_origen], 1) NOT IN ('6', '7')

                AND CAST(f.[Periodo] AS date)
                    <= up.[PeriodoMaximo]
            )
        )

    GROUP BY
        f.[Sociedad],
        up.[PeriodoMaximo],
        f.[Cuenta_origen]
),

DatosSociedad AS
(
    SELECT
        s.[Sociedad],
        s.[Periodo],
        s.[Cuenta],
        s.[Descripcion],
        s.[Saldo],

        CASE ds.[CodigoSociedad]

            WHEN 'COMM'
                THEN 'TINKLE_COMM'

            WHEN 'EURO'
                THEN 'TINKLE_EU'

            WHEN 'JAZZ'
                THEN 'TINKLE_JAZZ'

            WHEN 'ONION'
                THEN 'TINKLE_ONION'

            WHEN 'CONS'
                THEN 'TINKLE_CONS'

            ELSE NULL

        END AS CodigoFichero

    FROM Saldos AS s

    INNER JOIN [lh_tinkle_financiero].[300].[Dim_Sociedades] AS ds
        ON ds.[Sociedad] = s.[Sociedad]
)

SELECT

    [Sociedad],

    [CodigoFichero],

    /* MAR-26 */
    UPPER(
        FORMAT(
            [Periodo],
            'MMM-yy',
            'es-ES'
        )
    ) AS PeriodoTexto,

    [Periodo],

    [Cuenta],

    [Descripcion],

    /* Saldo positivo = Debe */
    CASE
        WHEN [Saldo] > 0
            THEN [Saldo]
        ELSE NULL
    END AS Debe,

    /* Saldo negativo = Haber */
    CASE
        WHEN [Saldo] < 0
            THEN ABS([Saldo])
        ELSE NULL
    END AS Haber,

    [Saldo]

FROM DatosSociedad

WHERE
    [CodigoFichero] IS NOT NULL;

