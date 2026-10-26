[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Fact_Asignacion_RRHH_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Fact_Asignacion_RRHH = let
    // ============================================================
    // 1. NAVEGACIÓN HASTA LA CARPETA RENTABILIDAD
    // ============================================================

    Source = Lakehouse.Contents(null),

    Navigation =
        Source{
            [workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]
        }[Data],

    #"Navigation 1" =
        Navigation{
            [lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]
        }[Data],

    #"Navigation 2" =
        #"Navigation 1"{
            [Id = "Files", ItemKind = "Folder"]
        }[Data],

    #"Navigation 3" =
        #"Navigation 2"{
            [Name = "Reporting Financiero"]
        }[Content],

    #"Navigation 4" =
        #"Navigation 3"{
            [Name = "1. Entrada de Datos"]
        }[Content],

    Navegación =
        #"Navigation 4"{
            [Name = "Arranque"]
        }[Content],

    #"Navigation 5" =
        Navegación{
            [Name = "RENTABILIDAD"]
        }[Content],


    // ============================================================
    // 2. FUNCIONES AUXILIARES
    // ============================================================


    // ------------------------------------------------------------
    // Convierte cualquier valor a texto seguro.
    // Nunca devuelve NULL ni ERROR.
    // ------------------------------------------------------------

    fxTexto = (Valor as any) as text =>
        if Valor = null then
            ""
        else
            try
                Text.Upper(
                    Text.Trim(
                        Text.From(Valor)
                    )
                )
            otherwise
                "",


    // ------------------------------------------------------------
    // Obtiene un valor de una lista sin generar error
    // ------------------------------------------------------------

    fxValor = (Lista as list, Posicion as number) as any =>
        try
            Lista{Posicion}
        otherwise
            null,


    // ------------------------------------------------------------
    // LIMPIAR ERRORES EXCEL
    //
    // Convierte:
    // #REF!
    // #VALUE!
    // #N/A
    // #DIV/0!
    // etc.
    //
    // en NULL antes de procesar la hoja.
    // ------------------------------------------------------------

    fxLimpiarErroresTabla = (tbl as any) as nullable table =>
        if tbl = null then
            null

        else if not Value.Is(tbl, type table) then
            null

        else
            let
                Columnas =
                    try
                        Table.ColumnNames(tbl)
                    otherwise
                        {},

                Reemplazos =
                    List.Transform(
                        Columnas,
                        each {_, null}
                    ),

                TablaLimpia =
                    try
                        Table.ReplaceErrorValues(
                            tbl,
                            Reemplazos
                        )
                    otherwise
                        null
            in
                TablaLimpia,


    // ------------------------------------------------------------
    // Convierte porcentajes a decimal
    //
    // 0,10    -> 0,10
    // 10%     -> 0,10
    // 10      -> 0,10
    // ------------------------------------------------------------

    fxPorcentaje = (Valor as any) as nullable number =>
        let
            NumeroDirecto =
                if Valor = null then
                    null
                else
                    try
                        Number.From(Valor)
                    otherwise
                        null,

            Texto =
                if Valor = null then
                    null
                else
                    try
                        Text.Trim(
                            Text.From(Valor)
                        )
                    otherwise
                        null,

            DesdeTexto =
                if NumeroDirecto <> null then
                    NumeroDirecto

                else if
                    Texto <> null
                    and Text.EndsWith(Texto, "%")
                then
                    try
                        Number.FromText(
                            Text.BeforeDelimiter(
                                Texto,
                                "%"
                            )
                        ) / 100
                    otherwise
                        null

                else if Texto <> null then
                    try
                        Number.FromText(Texto)
                    otherwise
                        null

                else
                    null,

            Normalizado =
                if DesdeTexto = null then
                    null

                else if
                    Number.Abs(DesdeTexto) > 1
                    and Number.Abs(DesdeTexto) <= 100
                then
                    DesdeTexto / 100

                else
                    DesdeTexto
        in
            Normalizado,


    // ------------------------------------------------------------
    // Identificar columnas financieras.
    //
    // Estas columnas NO deben interpretarse como empleados.
    // ------------------------------------------------------------

    fxEsCampoFinanciero = (Cabecera as any) as logical =>
        let
            T =
                fxTexto(Cabecera),

            EsAño =
                Text.Length(T) = 4
                and Text.StartsWith(T, "20")
                and
                    (
                        try
                            Number.FromText(T)
                        otherwise
                            null
                    ) <> null
        in
            T = ""
            or EsAño
            or Text.StartsWith(T, "FACTUR")
            or Text.StartsWith(T, "PROYECC")
            or Text.StartsWith(T, "FORECAST")
            or Text.StartsWith(T, "PRESUP")
            or Text.StartsWith(T, "PPTO")
            or Text.StartsWith(T, "FT")
            or Text.StartsWith(T, "FCT")
            or Text.StartsWith(T, "COSTE")
            or Text.StartsWith(T, "TOTAL")
            or Text.StartsWith(T, "REVENUE")
            or Text.StartsWith(T, "GROSS")
            or Text.StartsWith(T, "MARGEN")
            or Text.StartsWith(T, "CONTRIB")
            or Text.StartsWith(T, "HONORARIO")
            or Text.StartsWith(T, "FEE"),


    // ------------------------------------------------------------
    // Comprobar si una hoja contiene la matriz.
    //
    // Busca CLIENTE ORACLE en las primeras 30 filas.
    // ------------------------------------------------------------

    fxTieneMatriz = (tbl as any) as logical =>
        let
            TablaLimpia =
                fxLimpiarErroresTabla(tbl),

            PrimerasFilas =
                if TablaLimpia = null then
                    {}
                else
                    try
                        Table.ToRows(
                            Table.FirstN(
                                TablaLimpia,
                                30
                            )
                        )
                    otherwise
                        {},

            Encontrado =
                if List.Count(PrimerasFilas) = 0 then
                    false
                else
                    List.AnyTrue(
                        List.Transform(
                            PrimerasFilas,
                            (Fila) =>
                                List.AnyTrue(
                                    List.Transform(
                                        Fila,
                                        (Valor) =>
                                            fxTexto(Valor) = "CLIENTE ORACLE"
                                    )
                                )
                        )
                    )
        in
            Encontrado,


    // ------------------------------------------------------------
    // Obtener nombre de equipo desde el nombre de la hoja
    // ------------------------------------------------------------

    fxEquipo =
        (
            NombreHoja as any,
            CodigoDirectora as any
        )
        as text =>

        let
            Hoja =
                if NombreHoja = null then
                    ""
                else
                    Text.Trim(
                        Text.From(NombreHoja)
                    ),

            HojaUpper =
                Text.Upper(Hoja),

            Codigo =
                if CodigoDirectora = null then
                    ""
                else
                    Text.Trim(
                        Text.From(CodigoDirectora)
                    ),

            Equipo =
                if Text.StartsWith(
                    HojaUpper,
                    "CLIENTES RENTABILIDAD EQUIPO "
                )
                then
                    Text.Trim(
                        Text.Range(
                            Hoja,
                            Text.Length(
                                "CLIENTES RENTABILIDAD EQUIPO "
                            )
                        )
                    )

                else if Text.StartsWith(
                    HojaUpper,
                    "CLIENTES RENTABILIDAD "
                )
                then
                    Text.Trim(
                        Text.Range(
                            Hoja,
                            Text.Length(
                                "CLIENTES RENTABILIDAD "
                            )
                        )
                    )

                else if Text.StartsWith(
                    HojaUpper,
                    "RENTABILIDAD EQUIPO "
                )
                then
                    Text.Trim(
                        Text.Range(
                            Hoja,
                            Text.Length(
                                "RENTABILIDAD EQUIPO "
                            )
                        )
                    )

                else if Text.StartsWith(
                    HojaUpper,
                    "RENTABILIDAD "
                )
                then
                    Text.Trim(
                        Text.Range(
                            Hoja,
                            Text.Length(
                                "RENTABILIDAD "
                            )
                        )
                    )

                else if
                    HojaUpper = "CLIENTES RENTABILIDAD"
                    or HojaUpper = "RENTABILIDAD"
                then
                    Codigo

                else
                    Hoja
        in
            Equipo,


    // ============================================================
    // 3. FUNCIÓN PRINCIPAL:
    //    NORMALIZAR MATRIZ DE DEDICACIONES
    // ============================================================

    fxNormalizar =
        (
            tbl as any,
            NombreHoja as any,
            NombreArchivo as any,
            CodigoDirectora as any
        )
        as table =>

        let
            // ----------------------------------------------------
            // Primero limpiamos TODOS los errores Excel
            // ----------------------------------------------------

            TablaLimpia =
                fxLimpiarErroresTabla(tbl),


            Filas =
                if TablaLimpia = null then
                    {}
                else
                    try
                        Table.ToRows(
                            TablaLimpia
                        )
                    otherwise
                        {},


            // ----------------------------------------------------
            // Tabla vacía con estructura final
            // ----------------------------------------------------

            TablaVacia =
                #table(
                    {
                        "CodigoDirectora",
                        "Equipo",
                        "ClienteOracle",
                        "ClienteMMS",
                        "Descripcion",
                        "Empleado",
                        "EmpleadoPosicion",
                        "PctDedicacion",
                        "TipoDedicacion",
                        "ArchivoOrigen",
                        "HojaOrigen"
                    },
                    {}
                ),


            // ----------------------------------------------------
            // Buscar CLIENTE ORACLE
            // ----------------------------------------------------

            FlagsCabecera =
                List.Transform(
                    Filas,
                    (Fila) =>
                        List.AnyTrue(
                            List.Transform(
                                Fila,
                                (Valor) =>
                                    fxTexto(Valor) = "CLIENTE ORACLE"
                            )
                        )
                ),

            PosCabecera =
                List.PositionOf(
                    FlagsCabecera,
                    true
                ),


            Resultado =
                if PosCabecera = -1 then

                    TablaVacia

                else

                    let
                        // ========================================
                        // CABECERA DE LA MATRIZ
                        // ========================================

                        Cabecera =
                            Filas{PosCabecera},

                        CabeceraNormalizada =
                            List.Transform(
                                Cabecera,
                                each
                                    fxTexto(_)
                            ),


                        // ========================================
                        // CLIENTE ORACLE
                        // ========================================

                        PosOracle =
                            List.PositionOf(
                                CabeceraNormalizada,
                                "CLIENTE ORACLE"
                            ),


                        // ========================================
                        // CLIENTE MMS
                        // ========================================

                        FlagsMMS =
                            List.Transform(
                                CabeceraNormalizada,
                                each
                                    Text.StartsWith(
                                        _,
                                        "CLIENTE MMS"
                                    )
                            ),

                        PosMMS =
                            List.PositionOf(
                                FlagsMMS,
                                true
                            ),


                        // ========================================
                        // DESCRIPCIÓN
                        // ========================================

                        FlagsDescripcion =
                            List.Transform(
                                CabeceraNormalizada,
                                each
                                    Text.StartsWith(
                                        _,
                                        "DESCRIP"
                                    )
                            ),

                        PosDescripcion =
                            List.PositionOf(
                                FlagsDescripcion,
                                true
                            ),


                        EstructuraValida =
                            PosOracle >= 0
                            and PosDescripcion >= 0,


                        ResultadoEstructura =
                            if not EstructuraValida then

                                TablaVacia

                            else

                                let
                                    // ============================
                                    // COLUMNAS A LA DERECHA
                                    // DE DESCRIPCIÓN
                                    // ============================

                                    PosicionesDerecha =
                                        List.Select(
                                            List.Positions(
                                                Cabecera
                                            ),
                                            each
                                                _ > PosDescripcion
                                        ),


                                    // ============================
                                    // CANDIDATOS A EMPLEADO
                                    // ============================

                                    CandidatosEmpleado =
                                        List.Select(
                                            PosicionesDerecha,
                                            (Pos) =>
                                                let
                                                    H =
                                                        fxValor(
                                                            Cabecera,
                                                            Pos
                                                        )
                                                in
                                                    fxTexto(H) <> ""
                                                    and
                                                    not fxEsCampoFinanciero(H)
                                        ),


                                    PosPrimerEmpleado =
                                        if List.Count(
                                            CandidatosEmpleado
                                        ) > 0
                                        then
                                            List.Min(
                                                CandidatosEmpleado
                                            )
                                        else
                                            -1,


                                    // ============================
                                    // POSICIONES DE EMPLEADOS
                                    // ============================

                                    PosicionesEmpleado =
                                        if PosPrimerEmpleado = -1 then

                                            {}

                                        else

                                            List.Select(
                                                List.Positions(
                                                    Cabecera
                                                ),
                                                (Pos) =>
                                                    Pos >= PosPrimerEmpleado

                                                    and

                                                    fxTexto(
                                                        fxValor(
                                                            Cabecera,
                                                            Pos
                                                        )
                                                    ) <> ""

                                                    and

                                                    not fxEsCampoFinanciero(
                                                        fxValor(
                                                            Cabecera,
                                                            Pos
                                                        )
                                                    )
                                            ),


                                    // ============================
                                    // FILAS POSTERIORES
                                    // ============================

                                    FilasPosteriores =
                                        List.Skip(
                                            Filas,
                                            PosCabecera + 1
                                        ),


                                    // ============================
                                    // BUSCAR FINAL DE MATRIZ
                                    // ============================

                                    FlagsCorte =
                                        List.Transform(
                                            FilasPosteriores,
                                            (Fila) =>
                                                List.AnyTrue(
                                                    List.Transform(
                                                        Fila,
                                                        (Valor) =>
                                                            Text.Contains(
                                                                fxTexto(Valor),
                                                                "COSTE SALARIOS POR CLIENTE"
                                                            )
                                                    )
                                                )
                                        ),

                                    PosCorteRelativa =
                                        List.PositionOf(
                                            FlagsCorte,
                                            true
                                        ),


                                    // Si no encontramos el corte,
                                    // usamos el resto de filas.
                                    FilasDatos =
                                        if PosCorteRelativa = -1 then

                                            FilasPosteriores

                                        else

                                            List.FirstN(
                                                FilasPosteriores,
                                                PosCorteRelativa
                                            ),


                                    // ============================
                                    // EQUIPO
                                    // ============================

                                    NombreEquipo =
                                        fxEquipo(
                                            NombreHoja,
                                            CodigoDirectora
                                        ),


                                    // ============================
                                    // TRANSFORMAR FILAS
                                    // ============================

                                    RegistrosPorFila =
                                        List.Transform(
                                            FilasDatos,
                                            (Fila) =>

                                                let
                                                    ClienteOracle =
                                                        fxValor(
                                                            Fila,
                                                            PosOracle
                                                        ),

                                                    ClienteMMS =
                                                        if PosMMS >= 0 then
                                                            fxValor(
                                                                Fila,
                                                                PosMMS
                                                            )
                                                        else
                                                            null,

                                                    Descripcion =
                                                        fxValor(
                                                            Fila,
                                                            PosDescripcion
                                                        ),


                                                    OracleNorm =
                                                        fxTexto(
                                                            ClienteOracle
                                                        ),

                                                    MMSNorm =
                                                        fxTexto(
                                                            ClienteMMS
                                                        ),

                                                    DescripcionNorm =
                                                        fxTexto(
                                                            Descripcion
                                                        ),


                                                    // ----------------
                                                    // FILA VÁLIDA
                                                    // ----------------

                                                    EsFilaValida =
                                                        DescripcionNorm <> ""

                                                        and
                                                        OracleNorm <> "TOTAL"

                                                        and
                                                        not Text.StartsWith(
                                                            DescripcionNorm,
                                                            "TOTAL HONORARIOS"
                                                        )

                                                        and
                                                        not Text.StartsWith(
                                                            DescripcionNorm,
                                                            "TOTAL GENERAL"
                                                        )

                                                        and
                                                        DescripcionNorm <> "CHECKS",


                                                    // ----------------
                                                    // UN REGISTRO POR
                                                    // EMPLEADO
                                                    // ----------------

                                                    RegistrosEmpleado =
                                                        if not EsFilaValida then

                                                            {}

                                                        else

                                                            List.RemoveNulls(
                                                                List.Transform(
                                                                    PosicionesEmpleado,
                                                                    (PosEmpleado) =>

                                                                        let
                                                                            CabeceraEmpleado =
                                                                                fxValor(
                                                                                    Cabecera,
                                                                                    PosEmpleado
                                                                                ),

                                                                            NombreEmpleado =
                                                                                if CabeceraEmpleado = null then
                                                                                    ""
                                                                                else
                                                                                    try
                                                                                        Text.Trim(
                                                                                            Text.From(
                                                                                                CabeceraEmpleado
                                                                                            )
                                                                                        )
                                                                                    otherwise
                                                                                        "",


                                                                            ValorDedicacion =
                                                                                fxValor(
                                                                                    Fila,
                                                                                    PosEmpleado
                                                                                ),

                                                                            Pct =
                                                                                fxPorcentaje(
                                                                                    ValorDedicacion
                                                                                ),


                                                                            Tipo =
                                                                                if
                                                                                    Text.Contains(
                                                                                        DescripcionNorm,
                                                                                        "TRABAJO INTERNO"
                                                                                    )
                                                                                then
                                                                                    "INTERNO"

                                                                                else if
                                                                                    Text.Contains(
                                                                                        DescripcionNorm,
                                                                                        "NUEVO NEGOCIO"
                                                                                    )
                                                                                    or
                                                                                    Text.Contains(
                                                                                        DescripcionNorm,
                                                                                        "NEW BUSINESS"
                                                                                    )
                                                                                    or
                                                                                    MMSNorm = "NB"
                                                                                then
                                                                                    "NUEVO_NEGOCIO"

                                                                                else
                                                                                    "CLIENTE"

                                                                        in
                                                                            if
                                                                                NombreEmpleado = ""
                                                                                or
                                                                                Pct = null
                                                                                or
                                                                                Pct = 0
                                                                            then

                                                                                null

                                                                            else

                                                                                [
                                                                                    CodigoDirectora =
                                                                                        if CodigoDirectora = null
                                                                                        then
                                                                                            null
                                                                                        else
                                                                                            try
                                                                                                Text.Trim(
                                                                                                    Text.From(
                                                                                                        CodigoDirectora
                                                                                                    )
                                                                                                )
                                                                                            otherwise
                                                                                                null,

                                                                                    Equipo =
                                                                                        NombreEquipo,

                                                                                    ClienteOracle =
                                                                                        if ClienteOracle = null
                                                                                        then
                                                                                            null
                                                                                        else
                                                                                            try
                                                                                                Text.Trim(
                                                                                                    Text.From(
                                                                                                        ClienteOracle
                                                                                                    )
                                                                                                )
                                                                                            otherwise
                                                                                                null,

                                                                                    ClienteMMS =
                                                                                        if ClienteMMS = null
                                                                                        then
                                                                                            null
                                                                                        else
                                                                                            try
                                                                                                Text.Trim(
                                                                                                    Text.From(
                                                                                                        ClienteMMS
                                                                                                    )
                                                                                                )
                                                                                            otherwise
                                                                                                null,

                                                                                    Descripcion =
                                                                                        if Descripcion = null
                                                                                        then
                                                                                            null
                                                                                        else
                                                                                            try
                                                                                                Text.Trim(
                                                                                                    Text.From(
                                                                                                        Descripcion
                                                                                                    )
                                                                                                )
                                                                                            otherwise
                                                                                                null,

                                                                                    Empleado =
                                                                                        NombreEmpleado,

                                                                                    EmpleadoPosicion =
                                                                                        PosEmpleado
                                                                                        -
                                                                                        PosPrimerEmpleado
                                                                                        +
                                                                                        1,

                                                                                    PctDedicacion =
                                                                                        Pct,

                                                                                    TipoDedicacion =
                                                                                        Tipo,

                                                                                    ArchivoOrigen =
                                                                                        if NombreArchivo = null
                                                                                        then
                                                                                            null
                                                                                        else
                                                                                            try
                                                                                                Text.From(
                                                                                                    NombreArchivo
                                                                                                )
                                                                                            otherwise
                                                                                                null,

                                                                                    HojaOrigen =
                                                                                        if NombreHoja = null
                                                                                        then
                                                                                            null
                                                                                        else
                                                                                            try
                                                                                                Text.From(
                                                                                                    NombreHoja
                                                                                                )
                                                                                            otherwise
                                                                                                null
                                                                                ]
                                                                )
                                                            )

                                                in
                                                    RegistrosEmpleado
                                        ),


                                    // ============================
                                    // APLANAR RESULTADO
                                    // ============================

                                    Registros =
                                        if List.Count(
                                            RegistrosPorFila
                                        ) = 0
                                        then
                                            {}
                                        else
                                            List.Combine(
                                                RegistrosPorFila
                                            ),


                                    TablaResultado =
                                        if List.Count(Registros) = 0 then

                                            TablaVacia

                                        else

                                            Table.FromRecords(
                                                Registros
                                            )

                                in
                                    TablaResultado

                    in
                        ResultadoEstructura

        in
            Resultado,


    // ============================================================
    // 4. FILTRAR FICHEROS
    //
    // Solo XLSX / XLSM.
    // ============================================================

    #"Filtered files" =
        Table.SelectRows(
            #"Navigation 5",
            each
                let
                    Extension =
                        fxTexto(
                            [Extension]
                        ),

                    Nombre =
                        fxTexto(
                            [Name]
                        )
                in
                    List.Contains(
                        {
                            ".XLSX",
                            ".XLSM"
                        },
                        Extension
                    )

                    and
                    Text.Contains(
                        Nombre,
                        "RENTABILIDAD"
                    )

                    and
                    not Text.StartsWith(
                        Nombre,
                        "~$"
                    )
        ),


    // ============================================================
    // 5. CÓDIGO DIRECTORA
    //
    // EA - RENTABILIDAD... -> EA
    // MB - RENTABILIDAD... -> MB
    // ============================================================

    #"Added CodigoDirectora" =
        Table.AddColumn(
            #"Filtered files",
            "CodigoDirectora",
            each
                let
                    NombreArchivo =
                        if [Name] = null then
                            ""
                        else
                            Text.Trim(
                                Text.From(
                                    [Name]
                                )
                            ),

                    Codigo =
                        try
                            Text.Trim(
                                Text.BeforeDelimiter(
                                    NombreArchivo,
                                    "-"
                                )
                            )
                        otherwise
                            Text.Start(
                                NombreArchivo,
                                2
                            )
                in
                    Codigo,
            type text
        ),


    // ============================================================
    // 6. ABRIR WORKBOOKS
    // ============================================================

    #"Added Workbook" =
        Table.AddColumn(
            #"Added CodigoDirectora",
            "Workbook",
            each
                try
                    Excel.Workbook(
                        [Content],
                        null,
                        true
                    )
                otherwise
                    null
        ),


    // ============================================================
    // 7. SOLO WORKBOOKS VÁLIDOS
    // ============================================================

    #"Valid Workbooks" =
        Table.SelectRows(
            #"Added Workbook",
            each
                [Workbook] <> null
        ),


    // ============================================================
    // 8. EXPANDIR HOJAS
    // ============================================================

    #"Expanded Workbook" =
        Table.ExpandTableColumn(
            #"Valid Workbooks",
            "Workbook",
            {
                "Data",
                "Item",
                "Kind",
                "Hidden"
            },
            {
                "SheetData",
                "SheetName",
                "SheetKind",
                "SheetHidden"
            }
        ),


    // ============================================================
    // 9. LIMPIAR #REF!, #VALUE!, #N/A...
    // DE TODAS LAS HOJAS
    // ============================================================

    #"Added Clean SheetData" =
        Table.AddColumn(
            #"Expanded Workbook",
            "SheetDataClean",
            each
                fxLimpiarErroresTabla(
                    [SheetData]
                )
        ),


    // ============================================================
    // 10. FILTRAR HOJAS CON MATRIZ
    // ============================================================

    #"Filtered Sheets" =
        Table.SelectRows(
            #"Added Clean SheetData",
            each
                let
                    EsHoja =
                        if [SheetKind] = null then
                            false
                        else
                            Text.From(
                                [SheetKind]
                            ) = "Sheet",

                    EsVisible =
                        if [SheetHidden] = null then
                            true
                        else
                            [SheetHidden] <> true,

                    TieneDatos =
                        [SheetDataClean] <> null,

                    TieneMatriz =
                        if TieneDatos then
                            fxTieneMatriz(
                                [SheetDataClean]
                            )
                        else
                            false
                in
                    EsHoja
                    and EsVisible
                    and TieneDatos
                    and TieneMatriz
        ),


    // ============================================================
    // 11. NORMALIZAR CADA MATRIZ
    // ============================================================

    #"Added Dedicaciones" =
        Table.AddColumn(
            #"Filtered Sheets",
            "Dedicaciones",
            each
                fxNormalizar(
                    [SheetDataClean],
                    [SheetName],
                    [Name],
                    [CodigoDirectora]
                )
        ),


    // ============================================================
    // 12. COMBINAR TODAS LAS MATRICES
    // ============================================================

    #"Combined Dedicaciones" =
        if Table.RowCount(
            #"Added Dedicaciones"
        ) = 0
        then

            #table(
                {
                    "CodigoDirectora",
                    "Equipo",
                    "ClienteOracle",
                    "ClienteMMS",
                    "Descripcion",
                    "Empleado",
                    "EmpleadoPosicion",
                    "PctDedicacion",
                    "TipoDedicacion",
                    "ArchivoOrigen",
                    "HojaOrigen"
                },
                {}
            )

        else

            Table.Combine(
                #"Added Dedicaciones"[Dedicaciones]
            ),


    // ============================================================
    // 13. TIPOS DE DATOS
    // ============================================================

    #"Changed Types" =
        Table.TransformColumnTypes(#"Combined Dedicaciones", {{"CodigoDirectora", type text}, {"Equipo", type text}, {"ClienteOracle", type text}, {"ClienteMMS", type text}, {"Descripcion", type text}, {"Empleado", type text}, {"EmpleadoPosicion", Int64.Type}, {"PctDedicacion", Percentage.Type}, {"TipoDedicacion", type text}, {"ArchivoOrigen", type text}, {"HojaOrigen", type text}}),
  #"Inserted merged column" = Table.AddColumn(#"Changed Types", "EquipoKey", each Text.Combine({[CodigoDirectora], [Equipo]}, "|"), type text)

in
    #"Inserted merged column";
shared Fact_Asignacion_RRHH_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "300", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Fact_Asignacion_RRHH", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Dim_equipos_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Dim_equipos = let
    // ============================================================
    // 1. PARTIMOS DE LAS DEDICACIONES
    // ============================================================

    Source = Fact_Asignacion_RRHH,


    // ============================================================
    // 2. SOLO NECESITAMOS DIRECTORA + EQUIPO
    // ============================================================

    #"Selected Columns" =
        Table.SelectColumns(
            Source,
            {
                "CodigoDirectora",
                "Equipo"
            }
        ),


    // ============================================================
    // 3. LIMPIEZA
    // ============================================================

    #"Clean Text" =
        Table.TransformColumns(
            #"Selected Columns",
            {
                {
                    "CodigoDirectora",
                    each
                        if _ = null then
                            null
                        else
                            Text.Upper(
                                Text.Trim(
                                    Text.From(_)
                                )
                            ),
                    type text
                },
                {
                    "Equipo",
                    each
                        if _ = null then
                            null
                        else
                            Text.Upper(
                                Text.Trim(
                                    Text.From(_)
                                )
                            ),
                    type text
                }
            }
        ),


    // ============================================================
    // 4. ELIMINAR NULOS / VACÍOS
    // ============================================================

    #"Filtered Rows" =
        Table.SelectRows(
            #"Clean Text",
            each
                [CodigoDirectora] <> null
                and [CodigoDirectora] <> ""
                and [Equipo] <> null
                and [Equipo] <> ""
        ),


    // ============================================================
    // 5. UNA FILA POR EQUIPO
    // ============================================================

    #"Removed Duplicates" =
        Table.Distinct(
            #"Filtered Rows",
            {
                "CodigoDirectora",
                "Equipo"
            }
        ),


    // ============================================================
    // 6. CREAR EQUIPOKEY
    //
    // Ejemplo:
    // EA|ALBA
    // MB|VICTOR
    // OS|DIGITAL
    // ============================================================

    #"Added EquipoKey" =
        Table.AddColumn(
            #"Removed Duplicates",
            "EquipoKey",
            each
                [CodigoDirectora]
                & "|"
                & [Equipo],
            type text
        ),


    // ============================================================
    // 7. TRAER DATOS DE DIM_CDC
    //
    // CodigoDirectora
    //        =
    // Dim_CDC[INICIALES CAPTIO]
    // ============================================================

    #"Merged Dim CDC" =
        Table.NestedJoin(
            #"Added EquipoKey",
            {
                "CodigoDirectora"
            },
            Dim_CDC,
            {
                "INICIALES CAPTIO"
            },
            "CDC",
            JoinKind.LeftOuter
        ),


    // ============================================================
    // 8. EXPANDIR ATRIBUTOS DE LA DIRECTORA
    // ============================================================

    #"Expanded CDC" =
        Table.ExpandTableColumn(
            #"Merged Dim CDC",
            "CDC",
            {
                "Código CDC ORACLE",
                "Directora",
                "CENTRO DE COSTE"
            },
            {
                "CodigoCDC",
                "Directora",
                "CentroCoste"
            }
        ),


    // ============================================================
    // 10. ORDEN FINAL
    // ============================================================

    #"Reordered Columns" =
        Table.ReorderColumns(
            #"Expanded CDC",
            {
                "EquipoKey",
                "CodigoDirectora",
                "Equipo",
                "Directora",
                "CodigoCDC",
                "CentroCoste"
            }
        )

in
    #"Reordered Columns";
shared Dim_CDC = let
    // ============================================================
    // 1. NAVEGACIÓN HASTA LA CARPETA RENTABILIDAD
    // ============================================================

    Source = Lakehouse.Contents(null),

    Navigation =
        Source{
            [workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]
        }[Data],

    #"Navigation 1" =
        Navigation{
            [lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]
        }[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "300.Dim_CDC", ItemKind = "Table"]}[Data]

in
    #"Navigation 2";
shared Dim_equipos_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "300", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Dim_equipos", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
