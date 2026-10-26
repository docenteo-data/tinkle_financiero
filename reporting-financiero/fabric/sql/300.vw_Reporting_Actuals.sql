CREATE   VIEW [300].[vw_Reporting_Actuals]
AS

WITH Reporting_Cuentas AS
(
    /* ============================================================
       1. Líneas cuyo origen son cuentas
       ============================================================ */
    SELECT
        f.[Sociedad],
        f.[Cliente],
        f.[Fecha],
        f.[Periodo],

        f.[Cuenta_origen],
        f.[Descripcion],
        f.[Origen_actuals],
        f.[ID_Account],

        d.[Cuenta_magnitude],

        m.[Reporte],
        m.[Report_Line_Key],
        m.[Row_ID],
        m.[Tipo_Origen],
        m.[Referencia],
        m.[Cuenta] AS [Cuenta_Reporting],
        m.[Signo],
        m.[Tipo_Mapeo],

        f.[Debe],
        f.[Haber],
        f.[Saldo],

        f.[Saldo] * m.[Signo] AS [Importe_Reporting]

    FROM [300].[Fact_Actuals] f

    INNER JOIN [300].[Dim_Mapeo_Cuentas] d
        ON f.[ID_Account] = d.[ID_Account]

    INNER JOIN [300].[Map_Report_Line_Account] m
        ON d.[Cuenta_magnitude] = m.[Cuenta]
       AND m.[Tipo_Origen] = 'Cuenta'
),

Net_Income AS
(
    /* ============================================================
       2. Calculamos NET_INCOME una sola vez a partir del P&L
       ============================================================ */
    SELECT
        [Sociedad],
        [Cliente],
        [Fecha],
        [Periodo],

        SUM([Importe_Reporting]) AS [Importe_NET_INCOME]

    FROM Reporting_Cuentas

    WHERE [Reporte] = 'P&L'
      AND [Report_Line_Key] = 'TOTAL|NET_INCOME|P&L'

    GROUP BY
        [Sociedad],
        [Cliente],
        [Fecha],
        [Periodo]
),

Reporting_Medidas AS
(
    /* ============================================================
       3. Asignamos NET_INCOME a las líneas configuradas como Medida
       ============================================================ */
    SELECT
        ni.[Sociedad],
        ni.[Cliente],
        ni.[Fecha],
        ni.[Periodo],

        CAST(NULL AS varchar(8000)) AS [Cuenta_origen],
        CAST('NET_INCOME' AS varchar(8000)) AS [Descripcion],
        CAST('CALCULATED' AS varchar(8000)) AS [Origen_actuals],
        CAST(NULL AS varchar(8000)) AS [ID_Account],

        CAST(NULL AS varchar(8000)) AS [Cuenta_magnitude],

        m.[Reporte],
        m.[Report_Line_Key],
        m.[Row_ID],
        m.[Tipo_Origen],
        m.[Referencia],
        m.[Cuenta] AS [Cuenta_Reporting],
        m.[Signo],
        m.[Tipo_Mapeo],

        CAST(NULL AS float) AS [Debe],
        CAST(NULL AS float) AS [Haber],
        ni.[Importe_NET_INCOME] AS [Saldo],

        ni.[Importe_NET_INCOME] * m.[Signo] AS [Importe_Reporting]

    FROM Net_Income ni

    INNER JOIN [300].[Map_Report_Line_Account] m
        ON m.[Tipo_Origen] = 'Medida'
       AND m.[Referencia] = 'NET_INCOME'
)

SELECT *
FROM Reporting_Cuentas

UNION ALL

SELECT *
FROM Reporting_Medidas;
