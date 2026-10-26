[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Mapping HAPA_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"Mapping HAPA" = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "Reporting Financiero"]}[Content],
  #"Navigation 4" = #"Navigation 3"{[Name = "1. Entrada de Datos"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "Maestros"]}[Content],
  #"Navigation 6" = #"Navigation 5"{[Name = "Maestros.xlsx"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(#"Navigation 6", null, true),
  #"Navigation 7" = #"Imported Excel workbook"{[Item = "MAPPING HAPA", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(#"Navigation 7", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"Cuenta", type text}, {"Descripción", type text}, {"Mapeo Magnitude", type text}, {"Descripción Magnitude", type text}, {"CUENTA", type text}, {"MUESTRA DE TINKLE - DESCRIPCION", type text}, {"ACCOUINT", type text}, {"DESCRIPTION", type text}}),
  #"Removed columns" = Table.RemoveColumns(#"Changed column type", {"Column5", "Column10"}),
  #"Removed duplicates" = Table.Distinct(#"Removed columns"),
  #"Filtered rows" = Table.SelectRows(#"Removed duplicates", each ([Cuenta] <> null))
in
  #"Filtered rows";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Dim_CDC_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Dim_CDC = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "Reporting Financiero"]}[Content],
  #"Navigation 4" = #"Navigation 3"{[Name = "1. Entrada de Datos"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "Maestros"]}[Content],
  #"Navigation 6" = #"Navigation 5"{[Name = "Maestros.xlsx"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(#"Navigation 6", null, true),
  #"Navigation 7" = #"Imported Excel workbook"{[Item = "CDC", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(#"Navigation 7", [PromoteAllScalars = true]),
  #"Choose columns" = Table.SelectColumns(#"Promoted headers", {"Código CDC ORACLE", "Nombre", "INICIALES CAPTIO", "Nombre_1"}),
  #"Renamed columns" = Table.RenameColumns(#"Choose columns", {{"Nombre_1", "Directora"}}),
  #"Removed duplicates" = Table.Distinct(#"Renamed columns", {"Directora", "INICIALES CAPTIO", "Nombre", "Código CDC ORACLE"}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Removed duplicates", "CENTRO DE COSTE", each [Código CDC ORACLE] & "-" & [INICIALES CAPTIO]), {{"CENTRO DE COSTE", type text}}),
  #"Changed column type" = Table.TransformColumnTypes(#"Added custom", {{"Código CDC ORACLE", type text}, {"Nombre", type text}, {"INICIALES CAPTIO", type text}, {"Directora", type text}, {"CENTRO DE COSTE", type text}})
in
  #"Changed column type";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Dim_Calendar_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Dim_Calendar = let
    FechaInicio = #date(2020, 1, 1),
    FechaFin = #date(2030, 12, 31),

    NumDias = Duration.Days(FechaFin - FechaInicio) + 1,

    ListaFechas = List.Dates(
        FechaInicio,
        NumDias,
        #duration(1, 0, 0, 0)
    ),

    TablaFechas = Table.FromList(
        ListaFechas,
        Splitter.SplitByNothing(),
        {"Fecha"}
    ),

    #"Tipo Fecha" = Table.TransformColumnTypes(
        TablaFechas,
        {{"Fecha", type date}}
    ),

    #"Added Ejercicio" = Table.AddColumn(
        #"Tipo Fecha",
        "Ejercicio",
        each Date.Year([Fecha]),
        Int64.Type
    ),

    #"Added NUMMES" = Table.AddColumn(
        #"Added Ejercicio",
        "NUMMES",
        each Date.Month([Fecha]),
        Int64.Type
    ),

    #"Added Mes" = Table.AddColumn(
        #"Added NUMMES",
        "Mes",
        each Text.Proper(Date.MonthName([Fecha], "es-ES")),
        type text
    ),

    #"Added Mes Corto" = Table.AddColumn(
        #"Added Mes",
        "Mes_Corto",
        each Text.Proper(Date.ToText([Fecha], "MMM", "es-ES")),
        type text
    ),

    #"Added PERIODO" = Table.AddColumn(
        #"Added Mes Corto",
        "PERIODO",
        each [Ejercicio] * 100 + [NUMMES],
        Int64.Type
    ),

    #"Added Año Mes" = Table.AddColumn(
        #"Added PERIODO",
        "Año_Mes",
        each Text.From([Ejercicio]) & "-" & Text.PadStart(Text.From([NUMMES]), 2, "0"),
        type text
    ),

    #"Added Trimestre" = Table.AddColumn(
        #"Added Año Mes",
        "Trimestre",
        each "T" & Text.From(Date.QuarterOfYear([Fecha])),
        type text
    ),

    #"Added Num Trimestre" = Table.AddColumn(
        #"Added Trimestre",
        "Num_Trimestre",
        each Date.QuarterOfYear([Fecha]),
        Int64.Type
    ),

    #"Added Dia" = Table.AddColumn(
        #"Added Num Trimestre",
        "Dia",
        each Date.Day([Fecha]),
        Int64.Type
    ),

    #"Added Dia Semana" = Table.AddColumn(
        #"Added Dia",
        "Dia_Semana",
        each Date.DayOfWeek([Fecha], Day.Monday) + 1,
        Int64.Type
    ),

    #"Added Nombre Dia Semana" = Table.AddColumn(
        #"Added Dia Semana",
        "Nombre_Dia_Semana",
        each Text.Proper(Date.DayOfWeekName([Fecha], "es-ES")),
        type text
    ),

    #"Added Inicio Mes" = Table.AddColumn(
        #"Added Nombre Dia Semana",
        "Inicio_Mes",
        each Date.StartOfMonth([Fecha]),
        type date
    ),

    #"Added Fin Mes" = Table.AddColumn(
        #"Added Inicio Mes",
        "Fin_Mes",
        each Date.EndOfMonth([Fecha]),
        type date
    ),

    #"Added Orden Mes" = Table.AddColumn(
        #"Added Fin Mes",
        "Orden_Mes",
        each [PERIODO],
        Int64.Type
    ),
  #"Columna duplicada" = Table.DuplicateColumn(#"Added Orden Mes", "Año_Mes", "Año_Mes - Copia")
in
    #"Columna duplicada";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Dim_Clientes_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Dim_Clientes = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "Reporting Financiero"]}[Content],
  #"Navigation 4" = #"Navigation 3"{[Name = "1. Entrada de Datos"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "Maestros"]}[Content],
  #"Navigation 6" = #"Navigation 5"{[Name = "Maestros.xlsx"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(#"Navigation 6", null, true),
  #"Navigation 7" = #"Imported Excel workbook"{[Item = "Clientes", Kind = "Sheet"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 7", {{"Column1", type text}, {"Column3", type text}, {"Column4", type text}, {"Column5", type text}, {"Column6", type text}, {"Column7", type text}, {"Column8", type text}, {"Column9", type text}, {"Column10", type text}, {"Column11", type text}, {"Column12", type text}, {"Column2", type text}}),
  #"Promoted headers" = Table.PromoteHeaders(#"Changed column type", [PromoteAllScalars = true]),
  #"Sorted rows" = Table.Sort(#"Promoted headers", {{"Cliente ORACLE", Order.Ascending}}),
  #"Removed duplicates" = Table.Distinct(#"Sorted rows"),
  #"Sorted rows 1" = Table.Sort(#"Removed duplicates", {{"Cliente MMS", Order.Descending}}),
  #"Filtered rows" = Table.SelectRows(#"Sorted rows 1", each ([Cliente MMS] <> "0000000" and [Cliente MMS] <> "CORP" and [Cliente MMS] <> "COST" and [Cliente MMS] <> "ESPA" and [Cliente MMS] <> "FIN" and [Cliente MMS] <> "NREP" and [Cliente MMS] <> "PERS" and [Cliente MMS] <> "T" and [Cliente MMS] <> "WC1")),
  #"Trimmed text" = Table.TransformColumns(#"Filtered rows", {{"Descripción", each Text.Trim(_), type nullable text}}),
  #"Personalizado agregado" = Table.TransformColumnTypes(Table.AddColumn(#"Trimmed text", "ClienteKey_Oracle", each [Cliente ORACLE] & "-" & [Empresa]), {{"ClienteKey_Oracle", type text}}),
  #"Personalizado agregado 1" = Table.TransformColumnTypes(Table.AddColumn(#"Personalizado agregado", "ClienteKey_MMS", each [Cliente MMS] & "-" & [Empresa]), {{"ClienteKey_MMS", type text}})
in
  #"Personalizado agregado 1";
[BindToDefaultDestination = false]
shared Assets_Reporte = let
    // ============================================================
    // Assets_Reporte
    // Replica la estructura de C - Assets
    // ============================================================

    Source =
        #table(
            type table
            [
                Fila_Excel = Int64.Type,
                Etiqueta = text,
                Codigo_Reporte = nullable text,
                Cuenta_Visible = nullable text,
                Tipo_Fila = text
            ],
            {
                {5, "A10900 - Uncalled subscribed capital", "A10900", "A10900", "Detalle"},
                {6, "ST-A110   Authorised Capital - Uncalled up", "ST-A11", null, "Subtotal"},
                {7, "A20100 - Start-up costs", "A20100", "A20100", "Detalle"},
                {8, "A20200 - Development costs", "A20200", "A20200", "Detalle"},
                {9, "A20300 - Research costs", "A20300", "A20300", "Detalle"},
                {10, "A20400 - Trademarks", "A20400", "A20400", "Detalle"},
                {11, "A20500 - Concessions, software licenses, patents, similar rights", "A20500", "A20500", "Detalle"},
                {12, "A20600 - Database", "A20600", "A20600", "Detalle"},
                {13, "A20650 - Customer list", "A20650", "A20650", "Detalle"},
                {14, "A20700 - Goodwill", "A20700", "A20700", "Detalle"},
                {15, "A20800 - Other intangible assets", "A20800", "A20800", "Detalle"},
                {16, "A23200 - Intangible assets in progress", "A23200", "A23200", "Detalle"},
                {17, "ST-A120B   Intangible Fixed Assets", "ST-A12", null, "Subtotal"},
                {18, "A28010 - Dep/amort. start-up costs", "A28010", "A28010", "Detalle"},
                {19, "A28020 - Dep/amort. Developpement costs", "A28020", "A28020", "Detalle"},
                {20, "A28030 - Dep/amort. Research", "A28030", "A28030", "Detalle"},
                {21, "A28040 - Dep/amort. trademarks", "A28040", "A28040", "Detalle"},
                {22, "A28050 - Dep/amort. concessions/ softwares licenses /patents", "A28050", "A28050", "Detalle"},
                {23, "A28060 - Dep/amort. database", "A28060", "A28060", "Detalle"},
                {24, "A28065 - Dep/amort. customer list", "A28065", "A28065", "Detalle"},
                {25, "A28070 - Goodwill depreciation", "A28070", "A28070", "Detalle"},
                {26, "A28080 - Dep/prov other intang assets", "A28080", "A28080", "Detalle"},
                {27, "A29320 - Dep/prov intang assets in progress", "A29320", "A29320", "Detalle"},
                {28, "ST-A120D   A/P Intangible Assets", "ST-A12", null, "Subtotal"},
                {29, "A21100 - Land", "A21100", "A21100", "Detalle"},
                {30, "A21300 - Buildings", "A21300", "A21300", "Detalle"},
                {31, "A21500 - Plant & Equipment", "A21500", "A21500", "Detalle"},
                {32, "A21600 - Buildings fixtures and fittings on NON freehold land", "A21600", "A21600", "Detalle"},
                {33, "A21650 - Buildings fixtures and fittings on freehold land", "A21650", "A21650", "Detalle"},
                {34, "A21700 - IT Equipment", "A21700", "A21700", "Detalle"},
                {35, "A21800 - Other tangible assets", "A21800", "A21800", "Detalle"},
                {36, "A21850 - Right of use IFRS16", "A21850", "A21850", "Detalle"},
                {37, "A23100 - Tangible assets in progress", "A23100", "A23100", "Detalle"},
                {38, "ST-A140B   Tangible Assets", "ST-A14", null, "Subtotal"},
                {39, "A28110 - Depreciation on land", "A28110", "A28110", "Detalle"},
                {40, "A28130 - Dep/amort. buildings", "A28130", "A28130", "Detalle"},
                {41, "A28150 - Dep/amort. plant & equipment", "A28150", "A28150", "Detalle"},
                {42, "A28160 - Dep/prov leasehold improvements on NON freehold land", "A28160", "A28160", "Detalle"},
                {43, "A28165 - Dep/prov leasehold improvements on freehold land", "A28165", "A28165", "Detalle"},
                {44, "A28170 - Dep/prov IT equipment", "A28170", "A28170", "Detalle"},
                {45, "A28180 - Dep/prov other tang assets", "A28180", "A28180", "Detalle"},
                {46, "A28185 - Amortization Right of use IFRS16", "A28185", "A28185", "Detalle"},
                {47, "A28186 - Depreciation Right of use IFRS16", "A28186", "A28186", "Detalle"},
                {48, "A29310 - Dep/prov tang assets in progress", "A29310", "A29310", "Detalle"},
                {49, "ST-A140D   Tangible Assets Depreciation", "ST-A14", null, "Subtotal"},
                {50, "A26100 - Investments in consolidated subsidiaries", "A26100", "A26100", "Detalle"},
                {51, "A26110 - Listed securities - gross value", "A26110", "A26110", "Detalle"},
                {52, "A26710 - Loans to NON consolidated entities < 1 an", "A26710", "A26710", "Detalle"},
                {53, "A26711 - Loans to NON consolidated entities > 1 year", "A26711", "A26711", "Detalle"},
                {54, "A26780 - Accrued interest on outside group receivables and loans < 1year", "A26780", "A26780", "Detalle"},
                {55, "A26781 - Accrued interest on outside group receivables and loans > 1year", "A26781", "A26781", "Detalle"},
                {56, "A27100 - Investments in non consolidated subsidiaries", "A27100", "A27100", "Detalle"},
                {57, "A27400 - Loss from merger on financial assets > 1year ((France only)", "A27400", "A27400", "Detalle"},
                {58, "A27501 - Surplus linked to funded pension plans", "A27501", "A27501", "Detalle"},
                {59, "A27600 - Other financial assets < 1 year", "A27600", "A27600", "Detalle"},
                {60, "A27601 - Other financial assets > 1year", "A27601", "A27601", "Detalle"},
                {61, "A27700 - Treasury shares", "A27700", "A27700", "Detalle"},
                {62, "A27800 - Loans, security & other receivables < 1year", "A27800", "A27800", "Detalle"},
                {63, "A27801 - Loans, security & other receivables > 1 year", "A27801", "A27801", "Detalle"},
                {64, "A27900 - Fair market value of swaps - Asset side < 1 year through equity", "A27900", "A27900", "Detalle"},
                {65, "A27905 - Fair market value of swaps - Asset side < 1 year through P&L", "A27905", "A27905", "Detalle"},
                {66, "A45100 - Loans to subsidiaries (Group)", "A45100", "A45100", "Detalle"},
                {67, "A45100F - Loans to subsidiaries Group (Fast close)", "A45100", "A45100F", "Detalle"},
                {68, "ST-A160B   Financial Assets", "ST-A16", null, "Subtotal"},
                {69, "A29610 - Provision for investments in subsidiaries", "A29610", "A29610", "Detalle"},
                {70, "A29611 - Provision for listed securities", "A29611", "A29611", "Detalle"},
                {71, "A29670 - Prov loans to non controlled entities", "A29670", "A29670", "Detalle"},
                {72, "A29678 - Prov accrued interests on outside group loans", "A29678", "A29678", "Detalle"},
                {73, "A29710 - Prov for non consolidated investments through P&L", "A29710", "A29710", "Detalle"},
                {74, "A29711 - Prov for non consolidated investments through OCI", "A29711", "A29711", "Detalle"},
                {75, "A29740 - Prov for loss from merger on financial assets (France only)", "A29740", "A29740", "Detalle"},
                {76, "A29760 - Prov other financial asset", "A29760", "A29760", "Detalle"},
                {77, "A29770 - Prov treasury stock", "A29770", "A29770", "Detalle"},
                {78, "A29780 - Prov loans, security & other receivables", "A29780", "A29780", "Detalle"},
                {79, "A49510 - Prov on loans to subsidiaries (group)", "A49510", "A49510", "Detalle"},
                {80, "A49570 - Provision for dividends to be received", "A49570", "A49570", "Detalle"},
                {81, "ST-A160D   Prov. for depreciation of financial assets", "ST-A16", null, "Subtotal"},
                {82, "A33000 - Inventories & WIP (work in progress)", "A33000", "A33000", "Detalle"},
                {83, "A33010 - Media Inventory deals", "A33010", "A33010", "Detalle"},
                {84, "ST-A210B   Inventories & Work in progress", "ST-A21", null, "Subtotal"},
                {85, "A39300 - Provision on inventories & WIP (work in progress)", "A39300", "A39300", "Detalle"},
                {86, "A39301 - Provision on Media inventory deals", "A39301", "A39301", "Detalle"},
                {87, "ST-A210D   Provisions/Inventories & WIP", "ST-A21", null, "Subtotal"},
                {88, "A40910 - Advances to suppliers", "A40910", "A40910", "Detalle"},
                {89, "A41000 - Trade notes and accounts receivable", "A41000", "A41000", "Detalle"},
                {90, "A41800 - Invoices to be issued to clients", "A41800", "A41800", "Detalle"},
                {91, "A43000 - Outstanding suppliers credits", "A43000", "A43000", "Detalle"},
                {92, "A44050 - VAT consolidation receivables (France only)", "A44050", "A44050", "Detalle"},
                {93, "A44100 - Deferred tax assets", "A44100", "A44100", "Detalle"},
                {94, "A44200 - Tax consolidation receivables", "A44200", "A44200", "Detalle"},
                {95, "A44201 - Tax consolidation receivables VIVENDI", "A44201", "A44201", "Detalle"},
                {96, "A44250 - Receivables of CVAE (France only)", "A44250", "A44250", "Detalle"},
                {97, "A44255 - Assets, withholding tax", "A44255", "A44255", "Detalle"},
                {98, "A44400 - Income tax receivable", "A44400", "A44400", "Detalle"},
                {99, "A44410 - Receivable (Research / cinema / other) Tax credit", "A44410", "A44410", "Detalle"},
                {100, "A44500 - Value-added tax (VAT) receivables", "A44500", "A44500", "Detalle"},
                {101, "A44600 - CICE (France only)", "A44600", "A44600", "Detalle"},
                {102, "A45620 - Shareholders: unpaid called capital", "A45620", "A45620", "Detalle"},
                {103, "A45700 - Dividends to be received", "A45700", "A45700", "Detalle"},
                {104, "A46200 - Receivable on disposal fixed assets < 1 year", "A46200", "A46200", "Detalle"},
                {105, "A46201 - Receivable on disposal fixed assets > 1 year", "A46201", "A46201", "Detalle"},
                {106, "A46300 - Receivables on earn out < 1 year", "A46300", "A46300", "Detalle"},
                {107, "A46301 - Receivables on earn out > 1 year", "A46301", "A46301", "Detalle"},
                {108, "A46400 - Receivable on disposal of financial assets < 1 year", "A46400", "A46400", "Detalle"},
                {109, "A46401 - Receivable on disposal of financial assets > 1 year", "A46401", "A46401", "Detalle"},
                {110, "A46700 - Other receivables", "A46700", "A46700", "Detalle"},
                {111, "A46720 - Receivables as agent", "A46720", "A46720", "Detalle"},
                {112, "ST-A220B   Other receivables", "ST-A22", null, "Subtotal"},
                {113, "A49091 - Allowance for adv.suppliers", "A49091", "A49091", "Detalle"},
                {114, "A49100 - Prov trade notes & accounts receivable", "A49100", "A49100", "Detalle"},
                {115, "A49441 - Allowance for deferred tax asset - Tax losses", "A49441", "A49441", "Detalle"},
                {116, "A49445 - Allowance for deferred tax asset - Deferred deduct. exp.", "A49445", "A49445", "Detalle"},
                {117, "A49620 - Prov receivables on fixed assets disp.", "A49620", "A49620", "Detalle"},
                {118, "A49630 - Prov receivables on earn out", "A49630", "A49630", "Detalle"},
                {119, "A49640 - Prov receivables on financial assets disp.", "A49640", "A49640", "Detalle"},
                {120, "A49700 - Provision for other receivables", "A49700", "A49700", "Detalle"},
                {121, "A49720 - Provision for receivables as agent", "A49720", "A49720", "Detalle"},
                {122, "ST-A220D   Prov. other receivables", "ST-A22", null, "Subtotal"},
                {123, "A50000 - Cash equivalents", "A50000", "A50000", "Detalle"},
                {124, "A50100 - Other investments (Marketable securities)", "A50100", "A50100", "Detalle"},
                {125, "A50200 - Own shares", "A50200", "A50200", "Detalle"},
                {126, "ST-A240B   Marketable Securities", "ST-A24", null, "Subtotal"},
                {127, "A59000 - Unrealized losses on market securities", "A59000", "A59000", "Detalle"},
                {128, "A59200 - Unrealized losses on own shares", "A59200", "A59200", "Detalle"},
                {129, "ST-A240D   Prov/Marketable Securities", "ST-A24", null, "Subtotal"},
                {130, "A51000 - Cash at bank (Outside Group)", "A51000", "A51000", "Detalle"},
                {131, "A51100 - Cash pooling debit (ZBA)", "A51100", "A51100", "Detalle"},
                {132, "A51100F - Cash pooling debit - ZBA (Fast close)", "A51100", "A51100F", "Detalle"},
                {133, "A51101 - Cash pooling debit (ZBA) VIVENDI (FRF001 Havas SA only)", "A51101", "A51101", "Detalle"},
                {134, "A51800 - Accrued interest on cash (outside group)", "A51800", "A51800", "Detalle"},
                {135, "ST-A250   Cash", "ST-A25", null, "Subtotal"},
                {136, "A59100 - Provisions for cash unavailable", "A59100", "A59100", "Detalle"},
                {137, "A59110 - Provisions for cash pooling debit (ZBA)", "A59110", "A59110", "Detalle"},
                {138, "ST-A250D   Prov. for cash unavailable", "ST-A25", null, "Subtotal"},
                {139, "A47600 - Unrealized foreign exchange loss", "A47600", "A47600", "Detalle"},
                {140, "A48100 - Deferred expenses", "A48100", "A48100", "Detalle"},
                {141, "A48600 - Prepaid expenses", "A48600", "A48600", "Detalle"},
                {142, "ST-A300   Accruals - Assets", null, null, "Subtotal"},
                {143, " ", null, null, "Separador"},
                {144, "Total Assets", null, null, "Total"}
            }
        ),

    ConOrden =
        Table.AddColumn(
            Source,
            "Orden",
            each [Fila_Excel],
            Int64.Type
        ),

    ConRowID =
        Table.AddColumn(
            ConOrden,
            "Row_ID",
            each
                let
                    OrdenTexto = Text.PadStart(Text.From([Orden]), 3, "0"),
                    CodigoSeguro =
                        if [Codigo_Reporte] = null or [Codigo_Reporte] = ""
                        then "SIN_CODIGO"
                        else [Codigo_Reporte]
                in
                    if [Tipo_Fila] = "Detalle" then
                        "DET|" & OrdenTexto & "|" & [Cuenta_Visible]
                    else if [Tipo_Fila] = "Subtotal" then
                        "SUB|" & OrdenTexto & "|" & CodigoSeguro
                    else if [Tipo_Fila] = "Total" then
                        "TOTAL|" & OrdenTexto & "|ASSETS"
                    else if [Tipo_Fila] = "Separador" then
                        "SEP|" & OrdenTexto
                    else
                        "CALC|" & OrdenTexto & "|" & CodigoSeguro,
            type text
        ),

    ConClaseFormato =
        Table.AddColumn(
            ConRowID,
            "Clase_Formato",
            each
                if [Tipo_Fila] = "Total" then "Total"
                else if [Tipo_Fila] = "Subtotal" then "Subtotal"
                else if [Tipo_Fila] = "Calculo" then "Resultado"
                else if [Tipo_Fila] = "Separador" then "Separador"
                else "Detalle",
            type text
        ),

    Resultado =
        Table.ReorderColumns(
            ConClaseFormato,
            {
                "Orden",
                "Fila_Excel",
                "Row_ID",
                "Etiqueta",
                "Codigo_Reporte",
                "Cuenta_Visible",
                "Tipo_Fila",
                "Clase_Formato"
            }
        ),

    ConReporte =
        Table.AddColumn(
            Resultado,
            "Reporte",
            each "Assets",
            type text
        ),

    ConReportLineKey =
        Table.AddColumn(
            ConReporte,
            "Report_Line_Key",
            each Text.Combine({[Row_ID], [Reporte]}, "|"),
            type text
        )

in
    ConReportLineKey;
[BindToDefaultDestination = false]
shared Assets_Reporte_Cuentas = let
    // ============================================================
    // Assets_Reporte_Cuentas
    // Mapping de cada línea de Assets a las cuentas Magnitude
    // que intervienen en su cálculo.
    //
    // Depende únicamente de Assets_Reporte.
    // Las cuentas Fast Close terminadas en F no generan mapping.
    // ============================================================

    Source = Assets_Reporte,

    // ------------------------------------------------------------
    // 1. Filas detalle que tienen una cuenta real
    // ------------------------------------------------------------
    Detalle =
        Table.SelectRows(
            Source,
            each
                [Tipo_Fila] = "Detalle"
                and [Cuenta_Visible] <> null
                and not Text.EndsWith([Cuenta_Visible], "F")
        ),

    // Cada detalle se calcula directamente desde su cuenta
    DetalleConTipoOrigen =
        Table.AddColumn(
            Detalle,
            "Tipo_Origen",
            each "Cuenta",
            type text
        ),

    DetalleConReferencia =
        Table.AddColumn(
            DetalleConTipoOrigen,
            "Referencia",
            each [Cuenta_Visible],
            type text
        ),

    DetalleConCuenta =
        Table.AddColumn(
            DetalleConReferencia,
            "Cuenta",
            each [Cuenta_Visible],
            type text
        ),

    DetalleConSigno =
        Table.AddColumn(
            DetalleConCuenta,
            "Signo",
            each 1,
            Int64.Type
        ),

    DetalleConTipoMapeo =
        Table.AddColumn(
            DetalleConSigno,
            "Tipo_Mapeo",
            each "Detalle",
            type text
        ),

    DetalleFinal =
        Table.SelectColumns(
            DetalleConTipoMapeo,
            {
                "Row_ID",
                "Report_Line_Key",
                "Tipo_Origen",
                "Referencia",
                "Cuenta",
                "Signo",
                "Tipo_Mapeo",
                "Reporte"
            }
        ),

    // ------------------------------------------------------------
    // 2. Definición de subtotales
    //
    // DesdeFila / HastaFila se refieren a Fila_Excel.
    // Solo se recogen filas de Tipo_Fila = Detalle.
    // Las Fast Close terminadas en F se excluyen.
    // ------------------------------------------------------------
    DefinicionSubtotales =
        #table(
            type table
            [
                Etiqueta = text,
                DesdeFila = Int64.Type,
                HastaFila = Int64.Type,
                Tipo_Mapeo = text
            ],
            {
                {"ST-A110   Authorised Capital - Uncalled up", 5, 5, "Subtotal"},

                {"ST-A120B   Intangible Fixed Assets", 7, 16, "Subtotal"},
                {"ST-A120D   A/P Intangible Assets", 18, 27, "Subtotal"},

                {"ST-A140B   Tangible Assets", 29, 37, "Subtotal"},
                {"ST-A140D   Tangible Assets Depreciation", 39, 48, "Subtotal"},

                {"ST-A160B   Financial Assets", 50, 67, "Subtotal"},
                {"ST-A160D   Prov. for depreciation of financial assets", 69, 80, "Subtotal"},

                {"ST-A210B   Inventories & Work in progress", 82, 83, "Subtotal"},
                {"ST-A210D   Provisions/Inventories & WIP", 85, 86, "Subtotal"},

                {"ST-A220B   Other receivables", 88, 111, "Subtotal"},
                {"ST-A220D   Prov. other receivables", 113, 121, "Subtotal"},

                {"ST-A240B   Marketable Securities", 123, 125, "Subtotal"},
                {"ST-A240D   Prov/Marketable Securities", 127, 128, "Subtotal"},

                {"ST-A250   Cash", 130, 134, "Subtotal"},
                {"ST-A250D   Prov. for cash unavailable", 136, 137, "Subtotal"},

                {"ST-A300   Accruals - Assets", 139, 141, "Subtotal"}
            }
        ),

    // ------------------------------------------------------------
    // 3. Convertimos cada subtotal en una lista de cuentas
    // ------------------------------------------------------------
    SubtotalesConFilaReporte =
        Table.AddColumn(
            DefinicionSubtotales,
            "FilaReporte",
            each
                let
                    EtiquetaActual = [Etiqueta]
                in
                    Table.SelectRows(
                        Source,
                        each
                            [Etiqueta] = EtiquetaActual
                            and [Tipo_Fila] = "Subtotal"
                    )
        ),

    ExpandirFilaReporte =
        Table.ExpandTableColumn(
            SubtotalesConFilaReporte,
            "FilaReporte",
            {
                "Row_ID",
                "Report_Line_Key",
                "Reporte"
            },
            {
                "Row_ID",
                "Report_Line_Key",
                "Reporte"
            }
        ),

    SubtotalesConCuentas =
        Table.AddColumn(
            ExpandirFilaReporte,
            "Cuentas",
            each
                let
                    Desde = [DesdeFila],
                    Hasta = [HastaFila]
                in
                    Table.SelectRows(
                        Source,
                        each
                            [Fila_Excel] >= Desde
                            and [Fila_Excel] <= Hasta
                            and [Tipo_Fila] = "Detalle"
                            and [Cuenta_Visible] <> null
                            and not Text.EndsWith([Cuenta_Visible], "F")
                    )
        ),

    ExpandirCuentasSubtotal =
        Table.ExpandTableColumn(
            SubtotalesConCuentas,
            "Cuentas",
            {"Cuenta_Visible"},
            {"Cuenta"}
        ),

    SubtotalesTipoOrigen =
        Table.AddColumn(
            ExpandirCuentasSubtotal,
            "Tipo_Origen",
            each "Cuenta",
            type text
        ),

    SubtotalesReferencia =
        Table.AddColumn(
            SubtotalesTipoOrigen,
            "Referencia",
            each [Cuenta],
            type text
        ),

    SubtotalesSigno =
        Table.AddColumn(
            SubtotalesReferencia,
            "Signo",
            each 1,
            Int64.Type
        ),

    SubtotalesFinal =
        Table.SelectColumns(
            SubtotalesSigno,
            {
                "Row_ID",
                "Report_Line_Key",
                "Tipo_Origen",
                "Referencia",
                "Cuenta",
                "Signo",
                "Tipo_Mapeo",
                "Reporte"
            }
        ),

    // ------------------------------------------------------------
    // 4. Total Assets
    //
    // Reproduce el total a partir de las líneas que componen
    // el balance de Assets, evitando sumar subtotales y detalles
    // simultáneamente.
    // ------------------------------------------------------------
    TotalAssets =
        Table.SelectRows(
            Source,
            each [Tipo_Fila] = "Total"
        ),

    CuentasTotal =
        Table.SelectRows(
            Source,
            each
                [Tipo_Fila] = "Detalle"
                and [Cuenta_Visible] <> null
                and not Text.EndsWith([Cuenta_Visible], "F")
        ),

    TotalConCuentas =
        Table.AddColumn(
            TotalAssets,
            "Cuentas",
            each CuentasTotal
        ),

    ExpandirCuentasTotal =
        Table.ExpandTableColumn(
            TotalConCuentas,
            "Cuentas",
            {"Cuenta_Visible"},
            {"Cuenta"}
        ),

    TotalTipoOrigen =
        Table.AddColumn(
            ExpandirCuentasTotal,
            "Tipo_Origen",
            each "Cuenta",
            type text
        ),

    TotalReferencia =
        Table.AddColumn(
            TotalTipoOrigen,
            "Referencia",
            each [Cuenta],
            type text
        ),

    TotalSigno =
        Table.AddColumn(
            TotalReferencia,
            "Signo",
            each 1,
            Int64.Type
        ),

    TotalTipoMapeo =
        Table.AddColumn(
            TotalSigno,
            "Tipo_Mapeo",
            each "Total",
            type text
        ),

    TotalFinal =
        Table.SelectColumns(
            TotalTipoMapeo,
            {
                "Row_ID",
                "Report_Line_Key",
                "Tipo_Origen",
                "Referencia",
                "Cuenta",
                "Signo",
                "Tipo_Mapeo",
                "Reporte"
            }
        ),

    // ------------------------------------------------------------
    // 5. Unimos detalle + subtotales + total
    // ------------------------------------------------------------
    Resultado =
        Table.Combine(
            {
                DetalleFinal,
                SubtotalesFinal,
                TotalFinal
            }
        ),

    // Evita duplicados accidentales en el mapping
    SinDuplicados =
        Table.Distinct(
            Resultado,
            {
                "Report_Line_Key",
                "Tipo_Origen",
                "Referencia",
                "Cuenta",
                "Signo"
            }
        )

in
    SinDuplicados;
[BindToDefaultDestination = false]
shared Liabilities_Reporte = let
    // ============================================================
    // Liabilities_Reporte
    // Orden y etiquetas extraídos de la hoja oficial del Checklist.
    // Consulta independiente: no referencia la tabla de cuentas.
    // ============================================================

    Source =
        #table(
            type table
            [
                Fila_Excel = Int64.Type,
                Etiqueta = text,
                Codigo_Reporte = nullable text,
                Cuenta_Visible = nullable text,
                Tipo_Fila = text
            ],
            {
                {5, "P10100 - Share Capital", "P10100", "P10100", "Detalle"},
                {6, "P10400 - Share premium account", "P10400", "P10400", "Detalle"},
                {7, "P10500 - Revaluation reserve", "P10500", "P10500", "Detalle"},
                {8, "P10600 - Retained earnings", "P10600", "P10600", "Detalle"},
                {9, "P10601 - Legal reserve", "P10601", "P10601", "Detalle"},
                {10, "P10602 - Actuarial gains and losses", "P10602", "P10602", "Detalle"},
                {11, "P10605 - IFRS16 reserves", "P10605", "P10605", "Detalle"},
                {12, "P10609 - Deferred tax on Actuarial Gains and losses", "P10609", "P10609", "Detalle"},
                {13, "P10611 - Free stock shares (AGA)", "P10611", "P10611", "Detalle"},
                {14, "P10680 - Prov for non consolidated investments through OCI", "P10680", "P10680", "Detalle"},
                {15, "P10690 - OBSAAR", "P10690", "P10690", "Detalle"},
                {16, "P106R - Reserves, revaluation (fair value)", "P106R", "P106R", "Detalle"},
                {17, "P12000 - Net income", "P12000", "P12000", "Detalle"},
                {18, "P13000 - Subsidy of investment (French companies only)", "P13000", "P13000", "Detalle"},
                {19, "P14800 - Other regulated provisions", "P14800", "P14800", "Detalle"},
                {20, "ST-P110   Shareholders Equity", "ST-P11", null, "Subtotal"},
                {21, "P16700 - Other equity capital < 1 year", "P16700", "P16700", "Detalle"},
                {22, "P16701 - Other equity capital > 1year", "P16701", "P16701", "Detalle"},
                {23, "ST-P200   Other Equity Capital", "ST-P20", null, "Subtotal"},
                {24, "P15110 - Provisions for litigations - other", "P15110", "P15110", "Detalle"},
                {25, "P15120 - Provisions for litigations with employees only", "P15120", "P15120", "Detalle"},
                {26, "P15150 - Provision for foreign exchange losses", "P15150", "P15150", "Detalle"},
                {27, "P15170 - Provision for taxation risks", "P15170", "P15170", "Detalle"},
                {28, "P15180 - Other provisions for risks", "P15180", "P15180", "Detalle"},
                {29, "P15190 - Provisions for subsidiaries risks (GROUP)", "P15190", "P15190", "Detalle"},
                {30, "ST-P410   Provisions for risks", "ST-P41", null, "Subtotal"},
                {31, "P15300 - Provisions for pension plans", "P15300", "P15300", "Detalle"},
                {32, "P15301 - Provisions for pensions medical insurance (french companies only)", "P15301", "P15301", "Detalle"},
                {33, "P15302 - Provisions for pensions_medals (french companies only)", "P15302", "P15302", "Detalle"},
                {34, "P15303 - Provisions for retiree (UK)", "P15303", "P15303", "Detalle"},
                {35, "P15304 - Provisions for pension plans not evaluated by the actuary", "P15304", "P15304", "Detalle"},
                {36, "P15400 - Provisions for premises", "P15400", "P15400", "Detalle"},
                {37, "P15800 - Provisions for other expenses", "P15800", "P15800", "Detalle"},
                {38, "P15810 - Dilapidation costs - IFRS16", "P15810", "P15810", "Detalle"},
                {39, "ST-P420   Provisions For Charges", "ST-P42", null, "Subtotal"},
                {40, "P16000 - Convertible and other bonds < 1 year", "P16000", "P16000", "Detalle"},
                {41, "P16001 - Convertible and other bonds > 1 year", "P16001", "P16001", "Detalle"},
                {42, "P16400 - Bank borrowings < 1 year", "P16400", "P16400", "Detalle"},
                {43, "P16401 - Bank borrowings > 1 year", "P16401", "P16401", "Detalle"},
                {44, "P16500 - Finance lease debts < 1 year", "P16500", "P16500", "Detalle"},
                {45, "P16501 - Finance lease debts >1 year", "P16501", "P16501", "Detalle"},
                {46, "P16600 - BO obligations < 1 year", "P16600", "P16600", "Detalle"},
                {47, "P16601 - BO obligations > 1 year.", "P16601", "P16601", "Detalle"},
                {48, "P16800 - Other non group debts and liabilities < 1 year", "P16800", "P16800", "Detalle"},
                {49, "P16801 - Other non group debts and liabilities > 1 year", "P16801", "P16801", "Detalle"},
                {50, "P16880 - Accrued interest on outside group financial debts", "P16880", "P16880", "Detalle"},
                {51, "P16886 - Accrued interest on convertible and other bonds", "P16886", "P16886", "Detalle"},
                {52, "P16887 - Accrued interest on bank borrowings", "P16887", "P16887", "Detalle"},
                {53, "P16900 - Fair market value of swaps - Liability side < 1 year through equity - financial debt item", "P16900", "P16900", "Detalle"},
                {54, "P18000 - IFRS16 leases debt - Non current", "P18000", "P18000", "Detalle"},
                {55, "P18005 - IFRS16 leases debt - Current", "P18005", "P18005", "Detalle"},
                {56, "P45100 - Other liabilities - GROUP", "P45100", "P45100", "Detalle"},
                {57, "P45100F - Other liabilities - GROUP (Fast close)", "P45100", "P45100F", "Detalle"},
                {58, "ST-P510   Financial Debts (except overdraft)", "ST-P51", null, "Subtotal"},
                {59, "P51910 - Bank overdrafts (Outside Group)", "P51910", "P51910", "Detalle"},
                {60, "P51920 - Cash Pooling credit (ZBA)", "P51920", "P51920", "Detalle"},
                {61, "P51920F - Cash Pooling credit - ZBA (Fast close)", "P51920", "P51920F", "Detalle"},
                {62, "P51980 - Accrued interest on outside group overdraft", "P51980", "P51980", "Detalle"},
                {63, "ST-P520   Overdraft", "ST-P52", null, "Subtotal"},
                {64, "P16902 - Fair market value of swaps - Liability side < 1 year through equity", "P16902", "P16902", "Detalle"},
                {65, "P16905 - Fair market value of swaps - Liability side < 1 year through P&L", "P16905", "P16905", "Detalle"},
                {66, "P40000 - Accounts payable", "P40000", "P40000", "Detalle"},
                {67, "P40110 - Advance payments from clients", "P40110", "P40110", "Detalle"},
                {68, "P40501 - Debts on intangible investments < 1 year", "P40501", "P40501", "Detalle"},
                {69, "P40502 - Debts on intangible investments > 1 year.", "P40502", "P40502", "Detalle"},
                {70, "P40601 - Debts on tangible investments < 1 year", "P40601", "P40601", "Detalle"},
                {71, "P40602 - Debts on tangible investments > 1 year.", "P40602", "P40602", "Detalle"},
                {72, "P40700 - Debts on financial investments < 1 year", "P40700", "P40700", "Detalle"},
                {73, "P40701 - Debts on financial investments > 1 year", "P40701", "P40701", "Detalle"},
                {74, "P40710 - Debts on earn out < 1 year", "P40710", "P40710", "Detalle"},
                {75, "P40711 - Debts on earn out > 1 year", "P40711", "P40711", "Detalle"},
                {76, "P40800 - Invoices to be received from suppliers", "P40800", "P40800", "Detalle"},
                {77, "P42000 - Staff related liabilities (no bonuses)", "P42000", "P42000", "Detalle"},
                {78, "P42080 - Bonuses", "P42080", "P42080", "Detalle"},
                {79, "P42100 - Accrued severances", "P42100", "P42100", "Detalle"},
                {80, "P42200 - Long Term Incentive Plan < 1 year", "P42200", "P42200", "Detalle"},
                {81, "P42201 - Long Term Incentive Plan > 1 year.", "P42201", "P42201", "Detalle"},
                {82, "P42300 - SOP liabilities < 1  year", "P42300", "P42300", "Detalle"},
                {83, "P42301 - SOP liabilities greater 1 year.", "P42301", "P42301", "Detalle"},
                {84, "P42501 - Employee profit sharing (France Only) < 1 year (France only)", "P42501", "P42501", "Detalle"},
                {85, "P42502 - Employee profit sharing (France Only) > 1 year (France only)", "P42502", "P42502", "Detalle"},
                {86, "P43000 - Customer credits", "P43000", "P43000", "Detalle"},
                {87, "P44000 - Other tax payables", "P44000", "P44000", "Detalle"},
                {88, "P43010 - Debts on media inventory deals", "P43010", "P43010", "Detalle"},
                {89, "P44050 - VAT consolidation payables (France only)", "P44050", "P44050", "Detalle"},
                {90, "P44100 - Deferred tax liabilities", "P44100", "P44100", "Detalle"},
                {91, "P44200 - Tax consolidation payables", "P44200", "P44200", "Detalle"},
                {92, "P44201 - Tax consolidation payables VIVENDI", "P44201", "P44201", "Detalle"},
                {93, "P44250 - Payables of CVAE (France only)", "P44250", "P44250", "Detalle"},
                {94, "P44255 - Liabilities, withholding tax", "P44255", "P44255", "Detalle"},
                {95, "P44270 - Provisions for taxation risks", "P44270", "P44270", "Detalle"},
                {96, "P44400 - Income tax payable", "P44400", "P44400", "Detalle"},
                {97, "P44500 - Value-added tax (VAT) payables", "P44500", "P44500", "Detalle"},
                {98, "P45700 - Dividends payable", "P45700", "P45700", "Detalle"},
                {99, "P46700 - Other liabilities", "P46700", "P46700", "Detalle"},
                {100, "P46720 - Payables as agent", "P46720", "P46720", "Detalle"},
                {101, "ST-P610   Accounts payable and other liabilities", "ST-P61", null, "Subtotal"},
                {102, "P47700 - Unrealized foreign exchange gain", "P47700", "P47700", "Detalle"},
                {103, "P48700 - Deferred income", "P48700", "P48700", "Detalle"},
                {104, "P48701 - Landlord Allowances", "P48701", "P48701", "Detalle"},
                {105, "ST-P700   Accruals - Liabilities", null, null, "Subtotal"},
                {106, " ", null, null, "Separador"},
                {107, "Total Liabilities and equity", null, null, "Total"}
            }
        ),

    ConOrden =
        Table.AddColumn(
            Source,
            "Orden",
            each [Fila_Excel],
            Int64.Type
        ),

    ConRowID =
        Table.AddColumn(
            ConOrden,
            "Row_ID",
            each
                let
                    OrdenTexto = Text.PadStart(Text.From([Orden]), 3, "0"),
                    CodigoSeguro =
                        if [Codigo_Reporte] = null or [Codigo_Reporte] = ""
                        then "SIN_CODIGO"
                        else [Codigo_Reporte]
                in
                    if [Tipo_Fila] = "Detalle" then
                        "DET|" & OrdenTexto & "|" & [Cuenta_Visible]
                    else if [Tipo_Fila] = "Subtotal" then
                        "SUB|" & OrdenTexto & "|" & CodigoSeguro
                    else if [Tipo_Fila] = "Total" then
                        "TOTAL|" & OrdenTexto & "|LIABILITIES_EQUITY"
                    else if [Tipo_Fila] = "Separador" then
                        "SEP|" & OrdenTexto
                    else
                        "CALC|" & OrdenTexto & "|" & CodigoSeguro,
            type text
        ),

    ConClaseFormato =
        Table.AddColumn(
            ConRowID,
            "Clase_Formato",
            each
                if [Tipo_Fila] = "Total" then "Total"
                else if [Tipo_Fila] = "Subtotal" then "Subtotal"
                else if [Tipo_Fila] = "Calculo" then "Resultado"
                else if [Tipo_Fila] = "Separador" then "Separador"
                else "Detalle",
            type text
        ),

    Resultado =
        Table.ReorderColumns(
            ConClaseFormato,
            {
                "Orden",
                "Fila_Excel",
                "Row_ID",
                "Etiqueta",
                "Codigo_Reporte",
                "Cuenta_Visible",
                "Tipo_Fila",
                "Clase_Formato"
            }
        ),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(Resultado, "Reporte", each "Liabilities"), {{"Reporte", type text}}),
  #"Inserted merged column" = Table.AddColumn(#"Added custom", "Report_Line_Key", each Text.Combine({[Row_ID], [Reporte]}, "|"), type text)
in
    #"Inserted merged column";
[BindToDefaultDestination = false]
shared Liabilities_Reporte_Cuentas = let
    // ============================================================
    // Liabilities_Reporte_Cuentas
    // Mapping de cada fila visible a cuentas o medidas de origen.
    // Depende únicamente de Liabilities_Reporte; no crea referencias cíclicas.
    // ============================================================

    Source = Liabilities_Reporte,

    SoloDetalle =
        Table.SelectRows(
            Source,
            each [Tipo_Fila] = "Detalle"
        ),

    ConTipoOrigen =
        Table.AddColumn(
            SoloDetalle,
            "Tipo_Origen",
            each
                if [Cuenta_Visible] = "P12000" then "Medida"
                else if Text.EndsWith([Cuenta_Visible], "F") then "SinDato"
                else "Cuenta",
            type text
        ),

    ConReferencia =
        Table.AddColumn(
            ConTipoOrigen,
            "Referencia",
            each
                if [Tipo_Origen] = "Medida" then "NET_INCOME"
                else if [Tipo_Origen] = "Cuenta" then [Cuenta_Visible]
                else null,
            type text
        ),

    ConCuenta =
        Table.AddColumn(
            ConReferencia,
            "Cuenta",
            each
                if [Tipo_Origen] = "Cuenta" then [Cuenta_Visible] else null,
            type text
        ),

    // Las líneas Fast Close no tienen fórmula en la columna Actual del Excel.
    // Permanecen en la estructura visible, pero sin mapping y por tanto muestran 0.
    CatalogoMapeable =
        Table.Buffer(
            Table.SelectRows(
                ConCuenta,
                each [Tipo_Origen] <> "SinDato"
            )
        ),

    DetalleConSigno =
    Table.AddColumn(
        CatalogoMapeable,
        "Signo",
        each -1,
        Int64.Type
    ),

    DetalleConTipoMapeo =
        Table.AddColumn(
            DetalleConSigno,
            "Tipo_Mapeo",
            each "Detalle",
            type text
        ),

    DetalleFinal =
        Table.SelectColumns(
            DetalleConTipoMapeo,
            {
                "Row_ID",
                "Tipo_Origen",
                "Referencia",
                "Cuenta",
                "Signo",
                "Tipo_Mapeo"
            }
        ),

    DefinicionRangos =
        #table(
            type table
            [
                Etiqueta_Resultado = text,
                Fila_Desde = Int64.Type,
                Fila_Hasta = Int64.Type,
                Tipo_Mapeo = text
            ],
            {
                {"ST-P110   Shareholders Equity", 5, 19, "Subtotal"},
                {"ST-P200   Other Equity Capital", 21, 22, "Subtotal"},
                {"ST-P410   Provisions for risks", 24, 29, "Subtotal"},
                {"ST-P420   Provisions For Charges", 31, 38, "Subtotal"},
                {"ST-P510   Financial Debts (except overdraft)", 40, 57, "Subtotal"},
                {"ST-P520   Overdraft", 59, 62, "Subtotal"},
                {"ST-P610   Accounts payable and other liabilities", 64, 100, "Subtotal"},
                {"ST-P700   Accruals - Liabilities", 102, 104, "Subtotal"},
                {"Total Liabilities and equity", 5, 104, "Total"}
            }
        ),

    MergeResultado =
        Table.NestedJoin(
            DefinicionRangos,
            {"Etiqueta_Resultado"},
            Source,
            {"Etiqueta"},
            "FilaResultado",
            JoinKind.LeftOuter
        ),

    ExpandResultado =
        Table.ExpandTableColumn(
            MergeResultado,
            "FilaResultado",
            {"Row_ID"},
            {"Row_ID"}
        ),

    ValidarResultado =
        Table.AddColumn(
            ExpandResultado,
            "Validacion",
            each
                if [Row_ID] = null then
                    error "No se encontró la línea: " & [Etiqueta_Resultado]
                else if [Fila_Desde] > [Fila_Hasta] then
                    error "Rango invertido en: " & [Etiqueta_Resultado]
                else
                    true,
            type logical
        ),

    ConComponentes =
        Table.AddColumn(
            ValidarResultado,
            "Componentes",
            each
                let
                    Desde = [Fila_Desde],
                    Hasta = [Fila_Hasta]
                in
                    Table.SelectColumns(
                        Table.SelectRows(
                            CatalogoMapeable,
                            each [Fila_Excel] >= Desde and [Fila_Excel] <= Hasta
                        ),
                        {
                            "Tipo_Origen",
                            "Referencia",
                            "Cuenta"
                        }
                    ),
            type table
        ),

    ExpandComponentes =
        Table.ExpandTableColumn(
            ConComponentes,
            "Componentes",
            {"Tipo_Origen", "Referencia", "Cuenta"},
            {"Tipo_Origen", "Referencia", "Cuenta"}
        ),

    ResultadosConSigno =
    Table.AddColumn(
        ExpandComponentes,
        "Signo",
        each -1,
        Int64.Type
    ),

    ResultadosFinal =
        Table.SelectColumns(
            ResultadosConSigno,
            {
                "Row_ID",
                "Tipo_Origen",
                "Referencia",
                "Cuenta",
                "Signo",
                "Tipo_Mapeo"
            }
        ),

    Combinado =
        Table.Combine(
            {
                DetalleFinal,
                ResultadosFinal
            }
        ),

    SinDuplicados =
        Table.Distinct(
            Combinado,
            {
                "Row_ID",
                "Tipo_Origen",
                "Referencia",
                "Cuenta"
            }
        ),

    Resultado =
        Table.TransformColumnTypes(
            SinDuplicados,
            {
                {"Row_ID", type text},
                {"Tipo_Origen", type text},
                {"Referencia", type text},
                {"Cuenta", type text},
                {"Signo", Int64.Type},
                {"Tipo_Mapeo", type text}
            }
        ),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(Resultado, "Reporte", each "Liabilities"), {{"Reporte", type text}}),
  #"Inserted merged column" = Table.AddColumn(#"Added custom", "Report_Line_Key", each Text.Combine({[Row_ID], [Reporte]}, "|"), type text)
in
    #"Inserted merged column";
[BindToDefaultDestination = false]
shared PL_Reporte = let
    // ============================================================
    // PL_REPORTE
    // Tabla desconectada de presentación: una fila por línea visible.
    // No depende de PL_Reporte_Cuentas, por lo que no crea ciclos.
    // ============================================================

    Source =
        #table(
            type table
            [
                Etiqueta = text,
                Codigo_Reporte = nullable text
            ],
            {
                {"R70500 - Other turnover", "R70500"},
                {"R70550 - Direct rebilled costs (other than media)", "R70550"},
                {"R70600 - Fees", "R70600"},
                {"R70610 - Coordination fees received", "R70610"},
                {"R70700 - Media Turnover", "R70700"},
                {"R70710 - Media Rebates", "R70710"},
                {"R70720 - Media Client Return", "R70720"},
                {"R70730 - Media income from marketing services", "R70730"},
                {"R70740 - Operating Discount", "R70740"},
                {"R70750 - Production services - income (Billed in group)", "R70750"},
                {"R70760 - Production services - income direct to client", "R70760"},
                {"R70770 - Affiperf revenue", "R70770"},
                {"R70800 - Other Project Revenue", "R70800"},
                {"ST-R111   Turnover", "ST-R11"},
                {"R60380 - Change in work in progress of directs costs", "R60380"},
                {"R60500 - Other direct costs", "R60500"},
                {"R60510 - Subcontracted prod services - expense (In group)", "R60510"},
                {"R60550 - Direct rebilled costs to client", "R60550"},
                {"R60610 - Coordination fees paid", "R60610"},
                {"R60700 - Media direct costs", "R60700"},
                {"Clients costs and coordinatioin fees", "Client"},
                {"Revenue IFRS15", "Revenu"},
                {"R60370 - Change in work in progress", "R60370"},
                {"R60520 - Subcontracted prod services - expense (External)", "R60520"},
                {"R60600 - Other direct project costs not explicitly rebilled to client", "R60600"},
                {"Pass trough costs", "Pass t"},
                {"GROSS INCOME", "GROSS"},
                {"R62100 - Freelance", "R62100"},
                {"R62111 - Recharged staff (expenses) / income GROUP", "R62111"},
                {"R62111F - Recharged staff (expenses) / income (Fast close)", "R62111"},
                {"R62120 - Recharged staff (expenses) / income OUTSIDE GROUP", "R62120"},
                {"R64100 - Wages and salaries", "R64100"},
                {"R64110 - Bonuses (without social contributions)", "R64110"},
                {"R64115 - Social contributions relating bonuses", "R64115"},
                {"R64120 - Severance Costs", "R64120"},
                {"R64121 - Severance linked to a plan", "R64121"},
                {"R64122 - Expenses paid on provisions for litigations with employees only", "R64122"},
                {"R64140 - Partial unemployment wage", "R64140"},
                {"R64200 - LTIP", "R64200"},
                {"R64300 - SOP, Free stock shares (AGA) January 29, 2014", "R64300"},
                {"R64307 - Vivendi performance shares, 2018 plan", "R64307"},
                {"R64308 - Vivendi performance shares, 2019 plan", "R64308"},
                {"R64310 - Vivendi performance shares, 2020 plan", "R64310"},
                {"R64350 - Recharge of Vivendi performance shares (expenses) / income GROUP", "R64350"},
                {"R64360 - PEG / OPUS Vivendi expenses", "R64360"},
                {"R64500 - Social contributions (excluding social contributions relating bonuses)", "R64500"},
                {"R64510 - Social contributions relating to free shares (France only))", "R64510"},
                {"R64530 - Defined contribution schemes charges (401K plan ; INPS in Italy)", "R64530"},
                {"R64600 - Crédit d'impôt pour la compétitivité et l'emploi (CICE) (France only)", "R64600"},
                {"R64700 - Other advantages granted to employees", "R64700"},
                {"R64720 - Benefits paid to pension plan beneficiaries", "R64720"},
                {"R64730 - Benefits paid to medical plan retirees beneficiaries (France only)", "R64730"},
                {"R64740 - Jubilee or other long service benefits (France only)", "R64740"},
                {"R68160 - Retirement benefit obligations", "R68160"},
                {"R68161 - Retirement benefit obligations - medical plan (France only)", "R68161"},
                {"R68162 - Retirement benefit obligations - jubilee (France only)", "R68162"},
                {"R68163 - Retirement benefit obligations (UK)", "R68163"},
                {"R68164 - Retirement benefit obligations not evaluated by the actuary", "R68164"},
                {"R68180 - Provision for litigations with employees only", "R68180"},
                {"R69100 - Employee profit share", "R69100"},
                {"R74140 - Compensation costs borne by government", "R74140"},
                {"R78160 - Write-back of retirement benefit obligations", "R78160"},
                {"R78161 - Write-back of retirement benefit obligations - medical plan (France only)", "R78161"},
                {"R78162 - Write-back of retirement benefit obligations - jubilee (France only)", "R78162"},
                {"R78163 - Write-back of retirement benefit obligations (UK)", "R78163"},
                {"R78164 - Write-back of retirement benefit obligations not evaluated by the actuary", "R78164"},
                {"R78180 - Write-back of provisions for litigations with employees only", "R78180"},
                {"ST-R124   Compensation", "ST-R12"},
                {"R61100 - IT system charges", "R61100"},
                {"R61150 - Expenses and maintenance for capitalized cars and equipment", "R61150"},
                {"R61200 - Real property rental (expenses) / income", "R61200"},
                {"R61201 - Real property rental", "R61201"},
                {"R61210 - Amortization of Landlord allowances (income)", "R61210"},
                {"R61220 - Finance leased equipment", "R61220"},
                {"R61230 - Finance leased building", "R61230"},
                {"R61300 - Operating leased equipment", "R61300"},
                {"R61320 - Service expense on operating leased equipment", "R61320"},
                {"R61350 - Long term car rental", "R61350"},
                {"R61400 - Real property service expenses (expenses) / income", "R61400"},
                {"R61500 - Moving expenses", "R61500"},
                {"R61700 - Research costs", "R61700"},
                {"R62200 - Fees and subscription fees", "R62200"},
                {"R62260 - Management fees (expenses) / income", "R62260"},
                {"R62260F - Management fees (expenses) / income (fast close)", "R62260"},
                {"R62261 - Management fees VIVENDI/ BOLLORE (FRF001 Havas SA only)", "R62261"},
                {"R62265 - Trademark licence fee - (expenses) / income", "R62265"},
                {"R62265F - Trademark licence fee - (expenses) / income (fast close)", "R62265"},
                {"R62300 - Acquisition costs on investments", "R62300"},
                {"R62700 - Bank charges", "R62700"},
                {"R62810 - Telecommunication and mail", "R62810"},
                {"R62820 - Stationery, supplies and other office costs", "R62820"},
                {"R62830 - Insurance", "R62830"},
                {"R62840 - Travel costs", "R62840"},
                {"R62845 - Recruitment fees", "R62845"},
                {"R62846 - Training expenses", "R62846"},
                {"R62850 - Entertainment", "R62850"},
                {"R62860 - Own advertising", "R62860"},
                {"R62870 - New Business costs", "R62870"},
                {"R65620 - Expenses paid on provisions for premises", "R65620"},
                {"ST-R122   External services", "ST-R12"},
                {"R63300 - Other taxes based on payroll", "R63300"},
                {"R63700 - Other taxes (excluding corporate tax)", "R63700"},
                {"ST-R123   Taxes", "ST-R12"},
                {"R65400 - Bad debts written off", "R65400"},
                {"R65410 - Bad debts written off not provided for", "R65410"},
                {"R65500 - Share of loss transferred from partnership", "R65500"},
                {"R65600 - Expenses paid on provisions for risk and charges", "R65600"},
                {"R65610 - Expenses paid on provisions for clients and other receivables", "R65610"},
                {"R65800 - Other expenses from operations (GROUP)", "R65800"},
                {"R65800F - Other expenses from operations (Fast close)", "R65800"},
                {"R65801 - Other expenses from operations (OUTSIDE GROUP)", "R65801"},
                {"ST-R125   Other Operating expenses", "ST-R12"},
                {"R72000 - Capitalized expense", "R72000"},
                {"R75500 - Share of profit transferred from partnership", "R75500"},
                {"R75800 - Other operating income (GROUP)", "R75800"},
                {"R75800F - Other operating income (Fast close)", "R75800"},
                {"R75801 - Other operating income (OUTSIDE GROUP)", "R75801"},
                {"R75830 - Income from old accounts receivables and payables", "R75830"},
                {"R77700 - Subsidy of investment at the P&L", "R77700"},
                {"ST-R112   Other Operating income", "ST-R11"},
                {"R68111 - Amort/deprec of tangible assets", "R68111"},
                {"R68112 - Goodwill amortization", "R68112"},
                {"R68113 - Dep/amort. customer list", "R68113"},
                {"R68114 - Amort/deprec of intangible assets", "R68114"},
                {"R68120 - Amortization of deferred expenses", "R68120"},
                {"R68130 - Provision for premises", "R68130"},
                {"R68140 - Change in estimates of provisions for premises - restructuring", "R68140"},
                {"R68150 - Provision for other risk and charges", "R68150"},
                {"R68170 - Provision for doubtful receivables and inventories", "R68170"},
                {"R68185 - Amort of tangible assets IFRS16", "R68185"},
                {"R68186 - Depreciation of tangible assets IFRS16", "R68186"},
                {"R68190 - Provision for other regulated provisions", "R68190"},
                {"ST-R130D   Operating allowances", "ST-R13"},
                {"R78111 - Write-back of prov. for intang+tang assets", "R78111"},
                {"R78112 - Write-back of Goodwill amortization", "R78112"},
                {"R78130 - Write-back of provisions for premises", "R78130"},
                {"R78140 - Write-back of provisions for premises - restructuring", "R78140"},
                {"R78150 - Write-back of provisions for other risk and charges", "R78150"},
                {"R78170 - Write-back prov for doubtful receivables and inventories", "R78170"},
                {"R78176 - Write-back depreciation right of Use IFRS16", "R78176"},
                {"R78190 - Write-back of other regulated provisions", "R78190"},
                {"ST-R130R   Operating write-backs", "ST-R13"},
                {"Operating Expenses", "OPEX"},
                {"OPERATING PROFIT", "OPERAT"},
                {"R76110 - Dividends", "R76110"},
                {"R76120 - Interim dividends", "R76120"},
                {"R76128 - Premium on swaps", "R76128"},
                {"R76200 - Interest income OUTSIDE GROUP", "R76200"},
                {"R76410 - Income from cash and cash equivalent", "R76410"},
                {"R76600 - Unrealized foreign exchange gains", "R76600"},
                {"R76601 - Realized foreign exchange gains", "R76601"},
                {"R76602 - Unrealized foreign exchange gains - operating", "R76602"},
                {"R76605 - Realized foreign exchange gains - operating", "R76605"},
                {"R76606 - Unrealized exchange gains IFRS16", "R76606"},
                {"R76650 - Fair market value of swaps - Income", "R76650"},
                {"R76700 - Net gains on disposals of securities", "R76700"},
                {"R76710 - Net gain on cash equivalent disposals", "R76710"},
                {"R76800 - Other interest income GROUP", "R76800"},
                {"R76800F - Interest income (Fast close)", "R76800"},
                {"R76810 - Other interest income VIVENDI / BOLLORE  (FRF001 Havas SA only)", "R76810"},
                {"R76821 - Other interest income", "R76821"},
                {"ST-R210   Financial income", "ST-R21"},
                {"R66100 - Interest expenses OUTSIDE GROUP", "R66100"},
                {"R66110 - Interest on bonds", "R66110"},
                {"R66116 - Interest expenses on capital leases", "R66116"},
                {"R66118 - Premium on swaps", "R66118"},
                {"R66130 - Commitment fees on undrawn lines of credit", "R66130"},
                {"R66140 - Expenses on free stock shares (France only)", "R66140"},
                {"R66180 - IFRS16 Paid in advance interest expenses", "R66180"},
                {"R66185 - IFRS16 Paid in arrears interest expenses", "R66185"},
                {"R66200 - Losses on debt receivables and securities", "R66200"},
                {"R66300 - Acquisition costs on investments", "R66300"},
                {"R66600 - Unrealized foreign exchange losses", "R66600"},
                {"R66601 - Realized foreign exchange losses", "R66601"},
                {"R66605 - Realized foreign exchange losses - operating", "R66605"},
                {"R66606 - Unrealized exchange losses IFRS16", "R66606"},
                {"R66650 - Fair market value of swaps - Expense", "R66650"},
                {"R66710 - Net loss on cash equivalent disposal", "R66710"},
                {"R66820 - Other interest expenses GROUP", "R66820"},
                {"R66820F - Interest expenses (Fast close)", "R66820"},
                {"R66821 - Other financial expenses", "R66821"},
                {"ST-R220   Financial expenses", "ST-R22"},
                {"R68650 - Depreciation of investments in subsidiaries", "R68650"},
                {"R68660 - Depreciation of other financial assets", "R68660"},
                {"R68661 - Depreciation of loss from merger on financial assets (France only)", "R68661"},
                {"R68670 - Accretion expenses", "R68670"},
                {"R68674 - Retirement benefit obligations, interest cost (UK)", "R68674"},
                {"R68675 - Retirement benefit obligations, interest cost", "R68675"},
                {"R68676 - Retirement benefit obligations - medical plan, interest cost (France only)", "R68676"},
                {"R68677 - Retirement benefit obligations - jubilee, interest cost (France only)", "R68677"},
                {"ST-R230D   Financial allowances", "ST-R23"},
                {"R78650 - Write back of provisions for investments in subsidiaries", "R78650"},
                {"R78660 - Write-back of provisions for other financial assets provisions", "R78660"},
                {"R78661 - Write-back of provisions for loss on merger on financial assets (France only)", "R78661"},
                {"R78677 - Write-back Retirement benefit obligations - jubilee, interest cost (France only)", "R78677"},
                {"ST-R230R   Write-back on Financial allowances", "ST-R23"},
                {"FINANCIAL INCOME", "FINANC"},
                {"R77200 - Earn out (no compensatory) income", "R77200"},
                {"R77510 - Intangible assets selling price", "R77510"},
                {"R77520 - Tangible assets selling price", "R77520"},
                {"R77560 - Investments in subs selling price", "R77560"},
                {"R77580 - Other financial assets selling price", "R77580"},
                {"R77820 - Profit on merger", "R77820"},
                {"R77830 - Profit from own shares buyout", "R77830"},
                {"R77880 - Net impact of IFRS16 lease scope reduction", "R77880"},
                {"R77885 - Net impact of IFRS16 contracts earlier termination", "R77885"},
                {"Exceptional revenues", "Except"},
                {"R67200 - Earn out (no compensatory)", "R67200"},
                {"R67510 - NBV of intangible assets sold", "R67510"},
                {"R67520 - NBV of tangible assets sold", "R67520"},
                {"R67560 - Gross book value of investments in subsidiaries sold", "R67560"},
                {"R67580 - Book value of other financial assets sold", "R67580"},
                {"R67820 - Loss on merger", "R67820"},
                {"R67830 - Loss from own shares buyout", "R67830"},
                {"R67700 - Costs relating to the sale of subsidiaries", "R67700"},
                {"Exceptional expenses", "Except"},
                {"NON OPERATING ITEMS INCOME NET", "NON OP"},
                {"R68999 - Depreciation of provision for tax reserve", "R68999"},
                {"R69500 - Corporate tax - At current rate", "R69500"},
                {"R69510 - Corporate tax - At reduced rate", "R69510"},
                {"R69520 - Corporate tax - Tax audits, PY adjustments and others", "R69520"},
                {"R69530 - Corporate tax - Aditional contributions", "R69530"},
                {"R69750 - Withholding tax", "R69750"},
                {"R69800 - Tax income/expense tied to tax consolidation", "R69800"},
                {"R69801 - Tax income/expense tied to tax consolidation VIVENDI", "R69801"},
                {"R69900 - Tax losses carried back", "R69900"},
                {"R69910 - Research & Development / cinema - Tax credit", "R69910"},
                {"R69915 - Other tax credits", "R69915"},
                {"R69920 - Cotisation sur la Valeur Ajoutée des Entreprises (CVAE) - France only", "R69920"},
                {"R78999 - Write back of provision for tax reserve", "R78999"},
                {"R69400 - Deferred Tax", "R69400"},
                {"R69450 - Deferred Tax Liabilities - IFRIC23", "R69450"},
                {"R69600 - Valuation allowance - Tax losses", "R69600"},
                {"R69605 - Valuation allowance - Deferred deduct. exp.", "R69605"},
                {"ST-R520   Income tax", "SR-R52"},
                {" ", null},
                {"Total Net Income", null}
            }
        ),

    // La estructura oficial ocupa las filas 5 a 241 del Checklist.
    // Incluimos también la fila separadora 240.
    ConFilaExcel =
        Table.AddIndexColumn(
            Source,
            "Fila_Excel",
            5,
            1,
            Int64.Type
        ),

    ConOrden =
        Table.AddColumn(
            ConFilaExcel,
            "Orden",
            each [Fila_Excel],
            Int64.Type
        ),

    // La cuenta visible es el código situado antes de " - ".
    // En fast close se conserva R62111F, R62260F, etc.
    ConCuentaVisible =
        Table.AddColumn(
            ConOrden,
            "Cuenta_Visible",
            each
                if Text.StartsWith([Etiqueta], "R")
                    and Text.Contains([Etiqueta], " - ")
                then Text.BeforeDelimiter([Etiqueta], " - ")
                else null,
            type text
        ),

    EtiquetasSubtotal =
        {
            "ST-R111   Turnover",
            "Clients costs and coordinatioin fees",
            "Pass trough costs",
            "ST-R124   Compensation",
            "ST-R122   External services",
            "ST-R123   Taxes",
            "ST-R125   Other Operating expenses",
            "ST-R112   Other Operating income",
            "ST-R130D   Operating allowances",
            "ST-R130R   Operating write-backs",
            "ST-R210   Financial income",
            "ST-R220   Financial expenses",
            "ST-R230D   Financial allowances",
            "ST-R230R   Write-back on Financial allowances",
            "Exceptional revenues",
            "Exceptional expenses",
            "ST-R520   Income tax"
        },

    ConTipoFila =
        Table.AddColumn(
            ConCuentaVisible,
            "Tipo_Fila",
            each
                if [Etiqueta] = " " then "Separador"
                else if [Cuenta_Visible] <> null then "Detalle"
                else if [Etiqueta] = "Total Net Income" then "Total"
                else if List.Contains(EtiquetasSubtotal, [Etiqueta]) then "Subtotal"
                else "Calculo",
            type text
        ),

    // El Orden forma parte del identificador para garantizar unicidad,
    // incluso cuando el código de reporte se repite.
    ConRowID =
        Table.AddColumn(
            ConTipoFila,
            "Row_ID",
            each
                let
                    OrdenTexto = Text.PadStart(Text.From([Orden]), 3, "0"),
                    CodigoSeguro =
                        if [Codigo_Reporte] = null or [Codigo_Reporte] = ""
                        then "SIN_CODIGO"
                        else [Codigo_Reporte]
                in
                    if [Tipo_Fila] = "Detalle" then
                        "DET|" & OrdenTexto & "|" & [Cuenta_Visible]
                    else if [Tipo_Fila] = "Subtotal" then
                        "SUB|" & OrdenTexto & "|" & CodigoSeguro
                    else if [Tipo_Fila] = "Total" then
                        "TOTAL|" & OrdenTexto & "|NET_INCOME"
                    else if [Tipo_Fila] = "Separador" then
                        "SEP|" & OrdenTexto
                    else
                        "CALC|" & OrdenTexto & "|" & CodigoSeguro,
            type text
        ),

    ConClaseFormato =
        Table.AddColumn(
            ConRowID,
            "Clase_Formato",
            each
                if [Tipo_Fila] = "Total" then "Total"
                else if [Tipo_Fila] = "Calculo" then "Resultado"
                else if [Tipo_Fila] = "Subtotal" then "Subtotal"
                else if [Tipo_Fila] = "Separador" then "Separador"
                else "Detalle",
            type text
        ),

    TiposFinales =
        Table.TransformColumnTypes(
            ConClaseFormato,
            {
                {"Orden", Int64.Type},
                {"Fila_Excel", Int64.Type},
                {"Row_ID", type text},
                {"Etiqueta", type text},
                {"Codigo_Reporte", type text},
                {"Cuenta_Visible", type text},
                {"Tipo_Fila", type text},
                {"Clase_Formato", type text}
            }
        ),

    Resultado =
        Table.ReorderColumns(
            TiposFinales,
            {
                "Orden",
                "Fila_Excel",
                "Row_ID",
                "Etiqueta",
                "Codigo_Reporte",
                "Cuenta_Visible",
                "Tipo_Fila",
                "Clase_Formato"
            }
        ),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(Resultado, "Reporte", each "P&L"), {{"Reporte", type text}}),
  #"Inserted merged column" = Table.AddColumn(#"Added custom", "Report_Line_Key", each Text.Combine({[Row_ID], [Reporte]}, "|"), type text)
in
    #"Inserted merged column";
[BindToDefaultDestination = false]
shared PL_Reporte_Cuentas = let
    // ============================================================
    // PL_REPORTE_CUENTAS
    // Depende únicamente de PL_Reporte.
    // Genera el mapping Row_ID -> cuentas de reporting.
    //
    // Salida:
    // Row_ID
    // Tipo_Origen
    // Referencia
    // Cuenta
    // Signo
    // Tipo_Mapeo
    // Reporte
    // Report_Line_Key
    // ============================================================

    Source = PL_Reporte,

    TiposOrigen =
        Table.TransformColumnTypes(
            Source,
            {
                {"Orden", Int64.Type},
                {"Fila_Excel", Int64.Type},
                {"Row_ID", type text},
                {"Etiqueta", type text},
                {"Codigo_Reporte", type text},
                {"Cuenta_Visible", type text},
                {"Tipo_Fila", type text}
            }
        ),

    // ============================================================
    // CATÁLOGO DE CUENTAS DE DETALLE
    // ============================================================

    CatalogoDetalle =
        Table.Buffer(
            Table.SelectColumns(
                Table.SelectRows(
                    TiposOrigen,
                    each
                        [Tipo_Fila] = "Detalle"
                        and [Cuenta_Visible] <> null
                        and [Cuenta_Visible] <> ""
                        and not Text.EndsWith([Cuenta_Visible], "F")
                ),
                {
                    "Orden",
                    "Row_ID",
                    "Cuenta_Visible"
                }
            )
        ),

    // ============================================================
    // 1. MAPEO DE DETALLE
    // Cada línea de detalle suma su propia cuenta visible.
    // En P&L el signo de las líneas de detalle es -1.
    // ============================================================

    DetalleRenombrado =
        Table.RenameColumns(
            CatalogoDetalle,
            {
                {"Cuenta_Visible", "Cuenta"}
            }
        ),

    DetalleConSigno =
        Table.AddColumn(
            DetalleRenombrado,
            "Signo",
            each -1,
            Int64.Type
        ),

    DetalleConTipoMapeo =
        Table.AddColumn(
            DetalleConSigno,
            "Tipo_Mapeo",
            each "Detalle",
            type text
        ),

    DetalleFinal =
        Table.SelectColumns(
            DetalleConTipoMapeo,
            {
                "Row_ID",
                "Cuenta",
                "Signo",
                "Tipo_Mapeo"
            }
        ),

    // ============================================================
    // 2. DEFINICIÓN DE SUBTOTALES, CÁLCULOS Y TOTAL
    //
    // Se usan los límites definidos por Cuenta_Desde/Cuenta_Hasta
    // y se incorporan únicamente las líneas Tipo_Fila = Detalle
    // comprendidas entre ambos límites según Orden.
    //
    // Estas filas tienen signo +1.
    // ============================================================

    DefinicionRangos =
        #table(
            type table
            [
                Etiqueta_Resultado = text,
                Cuenta_Desde = text,
                Cuenta_Hasta = text,
                Tipo_Mapeo = text
            ],
            {
                {"ST-R111   Turnover", "R70500", "R70800", "Subtotal"},
                {"Clients costs and coordinatioin fees", "R60380", "R60700", "Subtotal"},
                {"Revenue IFRS15", "R70500", "R60700", "Calculo"},
                {"Pass trough costs", "R60370", "R60600", "Subtotal"},
                {"GROSS INCOME", "R70500", "R60600", "Calculo"},
                {"ST-R124   Compensation", "R62100", "R78180", "Subtotal"},
                {"ST-R122   External services", "R61100", "R65620", "Subtotal"},
                {"ST-R123   Taxes", "R63300", "R63700", "Subtotal"},
                {"ST-R125   Other Operating expenses", "R65400", "R65801", "Subtotal"},
                {"ST-R112   Other Operating income", "R72000", "R77700", "Subtotal"},
                {"ST-R130D   Operating allowances", "R68111", "R68190", "Subtotal"},
                {"ST-R130R   Operating write-backs", "R78111", "R78190", "Subtotal"},
                {"Operating Expenses", "R62100", "R78190", "Calculo"},
                {"OPERATING PROFIT", "R70500", "R78190", "Calculo"},
                {"ST-R210   Financial income", "R76110", "R76821", "Subtotal"},
                {"ST-R220   Financial expenses", "R66100", "R66821", "Subtotal"},
                {"ST-R230D   Financial allowances", "R68650", "R68677", "Subtotal"},
                {"ST-R230R   Write-back on Financial allowances", "R78650", "R78677", "Subtotal"},
                {"FINANCIAL INCOME", "R76110", "R78677", "Calculo"},
                {"Exceptional revenues", "R77200", "R77885", "Subtotal"},
                {"Exceptional expenses", "R67200", "R67700", "Subtotal"},
                {"NON OPERATING ITEMS INCOME NET", "R77200", "R67700", "Calculo"},
                {"ST-R520   Income tax", "R68999", "R69605", "Subtotal"},
                {"Total Net Income", "R70500", "R69605", "Total"}
            }
        ),

    // ============================================================
    // Localiza el Row_ID de cada subtotal/cálculo/total
    // ============================================================

    MergeResultado =
        Table.NestedJoin(
            DefinicionRangos,
            {"Etiqueta_Resultado"},
            TiposOrigen,
            {"Etiqueta"},
            "FilaResultado",
            JoinKind.LeftOuter
        ),

    ExpandResultado =
        Table.ExpandTableColumn(
            MergeResultado,
            "FilaResultado",
            {"Row_ID"},
            {"Row_ID"}
        ),

    // ============================================================
    // Localiza la posición inicial del rango
    // ============================================================

    MergeDesde =
        Table.NestedJoin(
            ExpandResultado,
            {"Cuenta_Desde"},
            CatalogoDetalle,
            {"Cuenta_Visible"},
            "FilaDesde",
            JoinKind.LeftOuter
        ),

    ExpandDesde =
        Table.ExpandTableColumn(
            MergeDesde,
            "FilaDesde",
            {"Orden"},
            {"Orden_Desde"}
        ),

    // ============================================================
    // Localiza la posición final del rango
    // ============================================================

    MergeHasta =
        Table.NestedJoin(
            ExpandDesde,
            {"Cuenta_Hasta"},
            CatalogoDetalle,
            {"Cuenta_Visible"},
            "FilaHasta",
            JoinKind.LeftOuter
        ),

    ExpandHasta =
        Table.ExpandTableColumn(
            MergeHasta,
            "FilaHasta",
            {"Orden"},
            {"Orden_Hasta"}
        ),

    // ============================================================
    // VALIDACIÓN
    // Evita generar mappings incompletos silenciosamente.
    // ============================================================

    ValidarDefiniciones =
        Table.AddColumn(
            ExpandHasta,
            "Validacion",
            each
                if [Row_ID] = null then
                    error "No se encontró en PL_Reporte la línea: " & [Etiqueta_Resultado]
                else if [Orden_Desde] = null then
                    error "No se encontró la cuenta inicial: " & [Cuenta_Desde]
                else if [Orden_Hasta] = null then
                    error "No se encontró la cuenta final: " & [Cuenta_Hasta]
                else if [Orden_Desde] > [Orden_Hasta] then
                    error "El rango está invertido para: " & [Etiqueta_Resultado]
                else
                    true,
            type logical
        ),

    DefinicionesValidadas =
        Table.SelectRows(
            ValidarDefiniciones,
            each [Validacion] = true
        ),

    // ============================================================
    // Expande cada subtotal/cálculo/total a las cuentas
    // de detalle comprendidas en su rango.
    // ============================================================

    ConCuentas =
        Table.AddColumn(
            DefinicionesValidadas,
            "CuentasIncluidas",
            each
                let
                    Desde = [Orden_Desde],
                    Hasta = [Orden_Hasta]
                in
                    Table.SelectColumns(
                        Table.SelectRows(
                            CatalogoDetalle,
                            each
                                [Orden] >= Desde
                                and [Orden] <= Hasta
                        ),
                        {
                            "Cuenta_Visible"
                        }
                    ),
            type table
        ),

    ExpandCuentas =
        Table.ExpandTableColumn(
            ConCuentas,
            "CuentasIncluidas",
            {"Cuenta_Visible"},
            {"Cuenta"}
        ),

    ResultadosConSigno =
        Table.AddColumn(
            ExpandCuentas,
            "Signo",
            each 1,
            Int64.Type
        ),

    ResultadosFinal =
        Table.SelectColumns(
            ResultadosConSigno,
            {
                "Row_ID",
                "Cuenta",
                "Signo",
                "Tipo_Mapeo"
            }
        ),

    // ============================================================
    // 3. UNIÓN FINAL DE DETALLES + RESULTADOS
    // ============================================================

    Combinado =
        Table.Combine(
            {
                DetalleFinal,
                ResultadosFinal
            }
        ),

    FilasValidas =
        Table.SelectRows(
            Combinado,
            each
                [Row_ID] <> null
                and [Row_ID] <> ""
                and [Cuenta] <> null
                and [Cuenta] <> ""
        ),

    // Evita que la misma cuenta participe dos veces
    // en la misma línea de reporting.
    SinDuplicados =
        Table.Distinct(
            FilasValidas,
            {
                "Row_ID",
                "Cuenta"
            }
        ),

    // ============================================================
    // 4. TIPO DE ORIGEN
    //
    // Las filas Fast Close terminadas en "F" permanecen en
    // Dim_Report_Line, pero se excluyen de este mapping y muestran 0.
    // El resto de filas se calcula desde cuentas de Magnitude.
    // ============================================================

    ConTipoOrigen =
        Table.AddColumn(
            SinDuplicados,
            "Tipo_Origen",
            each "Cuenta",
            type text
        ),

    // Referencia conserva explícitamente la cuenta que se utiliza
    // como origen del cálculo.
    ConReferencia =
        Table.AddColumn(
            ConTipoOrigen,
            "Referencia",
            each [Cuenta],
            type text
        ),

    // ============================================================
    // 5. TIPOS FINALES
    // ============================================================

    TiposFinales =
        Table.TransformColumnTypes(
            ConReferencia,
            {
                {"Row_ID", type text},
                {"Tipo_Origen", type text},
                {"Referencia", type text},
                {"Cuenta", type text},
                {"Signo", Int64.Type},
                {"Tipo_Mapeo", type text}
            }
        ),

    // Dejamos las columnas en el mismo orden que el resto
    // de mappings de reporting.
    ColumnasOrdenadas =
        Table.ReorderColumns(
            TiposFinales,
            {
                "Row_ID",
                "Tipo_Origen",
                "Referencia",
                "Cuenta",
                "Signo",
                "Tipo_Mapeo"
            }
        ),

    Resultado =
        Table.Sort(
            ColumnasOrdenadas,
            {
                {"Row_ID", Order.Ascending},
                {"Cuenta", Order.Ascending}
            }
        ),

    // ============================================================
    // 6. IDENTIFICACIÓN DEL REPORTE
    // ============================================================

    ConReporte =
        Table.AddColumn(
            Resultado,
            "Reporte",
            each "P&L",
            type text
        ),

    // Mantengo el formato que ya estás utilizando:
    // Row_ID|Reporte
    ConReportLineKey =
        Table.AddColumn(
            ConReporte,
            "Report_Line_Key",
            each Text.Combine(
                {
                    [Row_ID],
                    [Reporte]
                },
                "|"
            ),
            type text
        )

in
    ConReportLineKey;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Mapping HAPA (2)_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "Conta", DestinationColumnName = "Conta"], [SourceColumnName = "Descrição", DestinationColumnName = "Descrição"], [SourceColumnName = "Mapeo Magnitude", DestinationColumnName = "Mapeo Magnitude"], [SourceColumnName = "Mapeo summary", DestinationColumnName = "Mapeo summary"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared #"Mapping Portugal" = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "Reporting Financiero"]}[Content],
  #"Navigation 4" = #"Navigation 3"{[Name = "1. Entrada de Datos"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "Maestros"]}[Content],
  #"Navigation 6" = #"Navigation 5"{[Name = "Maestros.xlsx"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(#"Navigation 6", null, true),
  #"Navigation 7" = #"Imported Excel workbook"{[Item = "MAPPING PORTUGAL", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(#"Navigation 7", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"Conta", Int64.Type}, {"Descrição", type text}, {"Mapeo Magnitude", type text}, {"Mapeo summary", type text}})
in
  #"Changed column type";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "COA_Oracle_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared COA_Oracle = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "Reporting Financiero"]}[Content],
  #"Navigation 4" = #"Navigation 3"{[Name = "1. Entrada de Datos"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "Maestros"]}[Content],
  #"Navigation 6" = #"Navigation 5"{[Name = "Maestros.xlsx"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(#"Navigation 6", null, true),
  #"Navigation 7" = #"Imported Excel workbook"{[Item = "COA Oracle", Kind = "Sheet"]}[Data],
  #"Removed other columns" = Table.SelectColumns(#"Navigation 7", {"Column5", "Column6", "Column7", "Column8", "Column10"}),
  #"Filtered rows 1" = Table.SelectRows(#"Removed other columns", each ([Column5] <> null and [Column5] <> "ORACLE")),
  #"Promoted headers 1" = Table.PromoteHeaders(#"Filtered rows 1", [PromoteAllScalars = true]),
  #"Renamed columns" = Table.RenameColumns(#"Promoted headers 1", {{"CUENTA", "ORACLE-CUENTA"}, {"DESCRIPCION", "ORACLE-DESCRIPCION"}, {"ACCOUINT", "SAP-ACCOUNT"}, {"DESCRIPTION", "SAP-DESCRIPTION"}}),
  #"Changed column type" = Table.TransformColumnTypes(#"Renamed columns", {{"ORACLE-CUENTA", type text}, {"ORACLE-DESCRIPCION", type text}, {"SAP-ACCOUNT", type text}, {"SAP-DESCRIPTION", type text}, {"TIPO", type text}}),
  #"Removed duplicates" = Table.Distinct(#"Changed column type", {"ORACLE-CUENTA", "ORACLE-DESCRIPCION", "SAP-ACCOUNT", "SAP-DESCRIPTION", "TIPO"})
in
  #"Removed duplicates";
shared #"Mapping HAPA (2)_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "200", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Mapping Portugal", ItemKind = "Table"]}[Data]
in
  TableNavigation;
shared #"Mapping HAPA_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "200", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Mapping_HAPA", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Dim_Clientes_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "300", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Dim_Clientes", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Dim_Calendar_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "300", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Dim_Calendar", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared COA_Oracle_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "200", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "COA_Oracle", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Dim_Sociedades_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Dim_Sociedades = let
  Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("jVFLbsMgEL3KiLWVO0wJsqcdA4LBi1heeNVNpUb9HKTb3qJn8MUKTtKapItu0Oh9hsdjHJV2NqpGmQhC9oENFCCxoJUVfz3Oy9e8KvJxq2kg7ninpmZU93g4VKsuQL3jii9OZ8nZivpBau8Kw55aEmSIJgyks6lESKcQ3gVJLXIWb8fnl7f3x/mpjLKliqVDjxnrAPcDRRciYExWXAS/fN4x6TyZ6HH5wPNrb3L9x7vepV3fX9Xd98mSRqHzT9SbS0eALCbYLBkMSJeNZNvf3k0KrtpZAG/wj/4uDPhUwkEwfLp40yUnNU3f", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [CodigoSociedad = _t, Sociedad = _t, Pais = _t, CountryCode = _t, Sociedad_MMS = _t])
in
  Source;
shared Dim_Sociedades_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "300", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Dim_Sociedades", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[BindToDefaultDestination = false, DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Map_Report_Line_Account_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Map_Report_Line_Account = let
    Resultado =
        Table.Combine(
            {
                Assets_Reporte_Cuentas,
                Liabilities_Reporte_Cuentas,
                PL_Reporte_Cuentas
            }
        ),
  #"Changed column type" = Table.TransformColumnTypes(Resultado, {{"Row_ID", type text}, {"Report_Line_Key", type text}, {"Tipo_Origen", type text}, {"Referencia", type text}, {"Cuenta", type text}, {"Signo", Int64.Type}, {"Tipo_Mapeo", type text}, {"Reporte", type text}})
in
    #"Changed column type";
[BindToDefaultDestination = false, DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Dim_Report_Line_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Dim_Report_Line = let
    Resultado =
        Table.Combine(
            {
                Assets_Reporte,
                Liabilities_Reporte,
                PL_Reporte
            }
        )
in
    Resultado;
shared Map_Report_Line_Account_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "300", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Map_Report_Line_Account", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Dim_Report_Line_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "300", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Dim_Report_Line", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Dim_CDC_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "300", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Dim_CDC", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Dim_RRHH_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Dim_RRHH = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "Reporting Financiero"]}[Content],
  #"Navigation 4" = #"Navigation 3"{[Name = "1. Entrada de Datos"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "Maestros"]}[Content],
  #"Navigation 6" = #"Navigation 5"{[Name = "MASTER RRHH 2026 .xlsx"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(#"Navigation 6", null, true),
  #"Navigation 7" = #"Imported Excel workbook"{[Item = "MASTER", Kind = "Sheet"]}[Data],
  #"Filtered rows" = Table.SelectRows(#"Navigation 7", each ([Column1] <> null)),
  #"Promoted headers" = Table.PromoteHeaders(#"Filtered rows", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"OFICINA", type text}, {"CENTRO DE COSTE", type text}, {"EQUIPO", type text}, {"MANAGER", type text}, {"PUESTO", type text}, {"EMPRESA", type text}, {"NOMBRE", type text}, {"Fecha inicio ", type date}, {"Fecha fin ", type date}, {"Jornada", type number}, {"SALARIO 2025", type number}, {"SALARIO ANUAL 2026", type number}, {"SUBIDA SALARIAL 2026", type number}, {"GRATIFICACION 2026", type number}, {"Bonus 2025", type number}, {"IPC 2026 (INCLUIDO MEDIANA DE 2025 HASTA CONFIRMACION)", type number}, {"RETRIBUCION ANUAL 2026 (PRORRATEADO DE SUBIDAS, ALTAS Y BAJAS DURANTE EL AÑO)", type number}, {"COSTE SEGURIDAD SOCIAL 2026", type number}, {"COSTE TOTAL 2026 (PRORRATEADO DE SUBIDAS, ALTAS Y BAJAS DURANTE EL AÑO))", type number}, {"COSTE SS ANUAL TOTAL", type number}, {"COSTE TOTAL ANUAL (PROYECCION 2027)", type number}, {"Fecha subida", type date}}),
  #"Replaced errors" = Table.ReplaceErrorValues(#"Changed column type", {{"NOMBRE", null}, {"EMPRESA", null}, {"PUESTO", null}, {"MANAGER", null}, {"EQUIPO", null}, {"CENTRO DE COSTE", null}, {"OFICINA", null}, {"Fecha inicio ", null}, {"Fecha fin ", null}, {"Jornada", null}, {"SALARIO 2025", null}, {"SUBIDA SALARIAL 2026", null}, {"Fecha subida", null}, {"SALARIO ANUAL 2026", null}, {"GRATIFICACION 2026", null}, {"Bonus 2025", null}, {"IPC 2026 (INCLUIDO MEDIANA DE 2025 HASTA CONFIRMACION)", null}, {"RETRIBUCION ANUAL 2026 (PRORRATEADO DE SUBIDAS, ALTAS Y BAJAS DURANTE EL AÑO)", null}, {"COSTE SEGURIDAD SOCIAL 2026", null}, {"COSTE TOTAL 2026 (PRORRATEADO DE SUBIDAS, ALTAS Y BAJAS DURANTE EL AÑO))", null}, {"COSTE SS ANUAL TOTAL", null}, {"COSTE TOTAL ANUAL (PROYECCION 2027)", null}}),
  #"Sorted rows" = Table.Sort(#"Replaced errors", {{"PUESTO", Order.Descending}}),
  #"Removed duplicates" = Table.Distinct(#"Sorted rows", {"NOMBRE"})
in
  #"Removed duplicates";
shared Dim_RRHH_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "300", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Dim_RRHH", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Aux_CDC_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Aux_CDC = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "Reporting Financiero"]}[Content],
  #"Navigation 4" = #"Navigation 3"{[Name = "1. Entrada de Datos"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "Maestros"]}[Content],
  #"Navigation 6" = #"Navigation 5"{[Name = "Maestros.xlsx"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(#"Navigation 6", null, true),
  #"Navigation 7" = #"Imported Excel workbook"{[Item = "CDC", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(#"Navigation 7", [PromoteAllScalars = true]),
  #"Choose columns" = Table.SelectColumns(#"Promoted headers", {"CDC", "INICIALES CAPTIO"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Choose columns", {{"INICIALES CAPTIO", type text}, {"CDC", type text}})
in
  #"Changed column type";
shared Aux_CDC_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "300", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Aux_CDC", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
