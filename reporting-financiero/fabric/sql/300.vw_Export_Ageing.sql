CREATE   VIEW [300].[vw_Export_Ageing]
AS

/* ============================================================
   FICHERO DE GRUPO: AGEING DE CLIENTES (Magnitude)

   Una fila por sociedad, cliente y tramo de antiguedad, mas una
   fila GRICFLAG por cliente intercompania.

   - Fuente: 200.Aging_Clientes.
   - Importe: S_Pendiente en miles, redondeado a 4 decimales por linea.
   - Tramos: limites del DAX AgingBucket del modelo Agings, en dias
     desde F. Vto. hasta el fin del ultimo periodo de Fact_Actuals.
   - Cliente: el codigo Magnitude (Dim_Clientes.Codigo_Magnitude,
     provisional) al que lleva la factura en MMS. Si no hay codigo,
     d_client es el nombre del cliente del aging y sin_codigo vale 1.
   - GRICFLAG: p_amount = 1 por cada cliente con alguna factura con
     Interno = 'Y'.

   Las columnas van en minusculas y en el orden del TXT.
   ============================================================ */

WITH UltimoPeriodo AS
(
    SELECT
        MAX(CAST([Periodo] AS date)) AS PeriodoMaximo
    FROM [lh_tinkle_financiero].[300].[Fact_Actuals]
    WHERE [Periodo] IS NOT NULL
),

Corte AS
(
    SELECT
        EOMONTH(PeriodoMaximo) AS FechaCorte,

        /* 2026.3: el mes va sin cero a la izquierda */
        CONCAT(YEAR(PeriodoMaximo), '.', MONTH(PeriodoMaximo)) AS PeriodoTexto
    FROM UltimoPeriodo
),

/* ============================================================
   1. FACTURAS DEL AGING CON SU SOCIEDAD
   ============================================================ */

Facturas AS
(
    SELECT
        ds.[CodigoSociedad],

        CASE ds.[CodigoSociedad]
            WHEN 'COMM'  THEN 'ESP066'
            WHEN 'EURO'  THEN 'ESP067'
            WHEN 'JAZZ'  THEN 'ESP068'
            WHEN 'ONION' THEN 'ESP069'
            WHEN 'CONS'  THEN 'ESP070'
            ELSE NULL
        END AS CodigoRU,

        a.[Nombre Cliente],
        CAST(a.[Nº Factura] AS varchar(50)) AS Factura,
        LTRIM(RTRIM(a.[NIF])) AS Nif,

        CASE
            WHEN UPPER(LTRIM(RTRIM(a.[Interno]))) = 'Y' THEN 1
            ELSE 0
        END AS EsIntercompania,

        a.[F. Vto.],
        CAST(a.[S_Pendiente] AS decimal(38, 6)) AS Pendiente

    FROM [lh_tinkle_financiero].[200].[Aging_Clientes] AS a

    INNER JOIN [lh_tinkle_financiero].[300].[Dim_Sociedades] AS ds
        ON ds.[Sociedad] = a.[Proveedor]
),

/* ============================================================
   2. CLIENTE DE MMS POR FACTURA Y, SI NO ESTA, POR NIF

   Se usa el cliente solo si es unico. No se usa
   Dim_Sociedades.Sociedad_MMS: hoy trae los nombres de COMM y JAZZ
   cruzados, asi que los nombres de MMS se mapean aqui.
   ============================================================ */

MmsOrigen AS
(
    SELECT
        CASE [Compañia]
            WHEN 'TINKLE COMMUNICATIONS, S.L.'            THEN 'COMM'
            WHEN 'EUROPEAN PUBLIC RELATIONS SERVICES SLU' THEN 'EURO'
            WHEN 'JAZZ ALTERNATIVE THINKING S.L.'         THEN 'JAZZ'
            WHEN 'ONION DIGITAL SERVICES S.L.U.'          THEN 'ONION'
            WHEN 'TINKLE CONSULTANTS, S.L.'               THEN 'CONS'
            ELSE NULL
        END AS CodigoSociedad,

        CAST([Nº Factura Cli.] AS varchar(50)) AS Factura,
        LTRIM(RTRIM([Nif. Empresa/Cliente])) AS Nif,
        LTRIM(RTRIM(CAST([Cod. Cliente] AS varchar(50)))) AS Cliente

    FROM [lh_tinkle_financiero].[200].[MMS]

    WHERE [Cod. Cliente] IS NOT NULL
      AND LTRIM(RTRIM(CAST([Cod. Cliente] AS varchar(50)))) <> ''
),

MmsPorFactura AS
(
    SELECT
        CodigoSociedad,
        Factura,
        MIN(Cliente) AS Cliente,
        COUNT(DISTINCT Cliente) AS NumClientes

    FROM MmsOrigen

    WHERE CodigoSociedad IS NOT NULL
      AND Factura IS NOT NULL

    GROUP BY
        CodigoSociedad,
        Factura
),

MmsPorNif AS
(
    SELECT
        CodigoSociedad,
        Nif,
        MIN(Cliente) AS Cliente,
        COUNT(DISTINCT Cliente) AS NumClientes

    FROM MmsOrigen

    WHERE CodigoSociedad IS NOT NULL
      AND Nif IS NOT NULL
      AND Nif <> ''

    GROUP BY
        CodigoSociedad,
        Nif
),

/* ============================================================
   3. CODIGO DE CLIENTE MAGNITUDE Y TRAMO
   ============================================================ */

FacturasCliente AS
(
    SELECT
        f.[CodigoRU],
        f.[EsIntercompania],
        f.[Pendiente],

        COALESCE(
            NULLIF(LTRIM(RTRIM(dc.[Codigo_Magnitude])), ''),
            f.[Nombre Cliente]
        ) AS d_client,

        CASE
            WHEN NULLIF(LTRIM(RTRIM(dc.[Codigo_Magnitude])), '') IS NULL
                THEN 1
            ELSE 0
        END AS sin_codigo,

        /* Sin F. Vto. no hay tramo (como en el DAX): la fila queda fuera
           y el cuadre contra la fuente lo detecta. */
        CASE
            WHEN f.[F. Vto.] IS NULL THEN NULL
            WHEN DATEDIFF(day, f.[F. Vto.], c.[FechaCorte]) <= 0   THEN 'GR0'
            WHEN DATEDIFF(day, f.[F. Vto.], c.[FechaCorte]) <= 30  THEN 'GR1'
            WHEN DATEDIFF(day, f.[F. Vto.], c.[FechaCorte]) <= 60  THEN 'GR2'
            WHEN DATEDIFF(day, f.[F. Vto.], c.[FechaCorte]) <= 90  THEN 'GR3'
            WHEN DATEDIFF(day, f.[F. Vto.], c.[FechaCorte]) <= 120 THEN 'GR4'
            WHEN DATEDIFF(day, f.[F. Vto.], c.[FechaCorte]) <= 180 THEN 'GR5'
            WHEN DATEDIFF(day, f.[F. Vto.], c.[FechaCorte]) <= 365 THEN 'GR8C'
            ELSE 'GR9C'
        END AS d_fl,

        c.[PeriodoTexto]

    FROM Facturas AS f

    CROSS JOIN Corte AS c

    LEFT JOIN MmsPorFactura AS mf
        ON mf.[CodigoSociedad] = f.[CodigoSociedad]
       AND mf.[Factura] = f.[Factura]

    LEFT JOIN MmsPorNif AS mn
        ON mn.[CodigoSociedad] = f.[CodigoSociedad]
       AND mn.[Nif] = f.[Nif]

    LEFT JOIN [lh_tinkle_financiero].[300].[Dim_Clientes] AS dc
        ON dc.[Empresa] = f.[CodigoSociedad]
       AND dc.[Cliente MMS] =
           CASE
               WHEN mf.[NumClientes] = 1 THEN mf.[Cliente]
               WHEN mf.[NumClientes] IS NULL AND mn.[NumClientes] = 1 THEN mn.[Cliente]
               ELSE NULL
           END

    WHERE f.[CodigoRU] IS NOT NULL
),

/* ============================================================
   4. LINEAS DE IMPORTE Y FLAGS DE INTERCOMPANIA
   ============================================================ */

Lineas AS
(
    SELECT
        [CodigoRU],
        [PeriodoTexto],
        d_client,
        d_fl,
        MAX(sin_codigo) AS sin_codigo,

        CAST(ROUND(SUM([Pendiente]) / 1000.0, 4) AS decimal(18, 4)) AS p_amount

    FROM FacturasCliente

    WHERE d_fl IS NOT NULL

    GROUP BY
        [CodigoRU],
        [PeriodoTexto],
        d_client,
        d_fl
),

Flags AS
(
    SELECT
        [CodigoRU],
        [PeriodoTexto],
        d_client,
        'GRICFLAG' AS d_fl,
        MAX(sin_codigo) AS sin_codigo,
        CAST(1 AS decimal(18, 4)) AS p_amount

    FROM FacturasCliente

    WHERE [EsIntercompania] = 1

    GROUP BY
        [CodigoRU],
        [PeriodoTexto],
        d_client
),

Todo AS
(
    SELECT * FROM Lineas
    UNION ALL
    SELECT * FROM Flags
)

SELECT
    CAST('C' AS varchar(1))              AS d_ca,
    CAST([PeriodoTexto] AS varchar(7))   AS d_dp,
    CAST([CodigoRU] AS varchar(6))       AS d_ru,
    CAST(NULL AS varchar(1))             AS d_devtr,
    CAST(NULL AS varchar(1))             AS d_sajob,
    CAST(NULL AS varchar(1))             AS d_dim2,
    CAST(NULL AS varchar(1))             AS d_dim3,
    CAST(NULL AS varchar(1))             AS d_acty,
    CAST(d_client AS varchar(200))       AS d_client,
    CAST([PeriodoTexto] AS varchar(7))   AS d_pe,
    CAST(NULL AS varchar(1))             AS d_oru,
    CAST('MB4000' AS varchar(6))         AS d_ac,
    CAST(d_fl AS varchar(8))             AS d_fl,
    CAST('0LIA01' AS varchar(6))         AS d_au,
    CAST(NULL AS varchar(1))             AS d_t1,
    CAST(NULL AS varchar(1))             AS d_t2,
    CAST('EUR' AS varchar(3))            AS d_cu,
    CAST(NULL AS varchar(1))             AS d_to,
    CAST(NULL AS varchar(1))             AS d_go,
    CAST(NULL AS varchar(1))             AS d_le,
    CAST(NULL AS varchar(1))             AS d_nu,
    CAST(NULL AS varchar(1))             AS d_dim4,
    CAST(NULL AS varchar(1))             AS d_dest,
    CAST(NULL AS varchar(1))             AS d_area,
    CAST(NULL AS varchar(1))             AS p_comment,
    p_amount,
    CAST(sin_codigo AS bit)              AS sin_codigo

FROM Todo;
