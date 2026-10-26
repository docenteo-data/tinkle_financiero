[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Carga_New_MMS_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Carga_New_MMS = let

    Source = Lakehouse.Contents(null),

    Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],

    #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],

    #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],

    #"Navigation 3" = #"Navigation 2"{[Name = "Reporting Financiero"]}[Content],

    #"Navigation 4" = #"Navigation 3"{[Name = "1. Entrada de Datos"]}[Content],

    #"Navigation 5" = #"Navigation 4"{[Name = "Dinamicos"]}[Content],

    // Filtrar todos los Excel cuyo nombre contenga MMS
    #"Filtered MMS Files" = Table.SelectRows(
        #"Navigation 5",
        each
            Text.Contains([Name], "MMS", Comparer.OrdinalIgnoreCase)
            and Text.EndsWith([Name], ".xlsx", Comparer.OrdinalIgnoreCase)
            and not Text.StartsWith([Name], "~$")
    ),

    // Abrir cada Excel y obtener la hoja "Datos"
    #"Get Datos Sheet" = Table.AddColumn(
        #"Filtered MMS Files",
        "Datos",
        each
            let
                Workbook = Excel.Workbook([Content], null, true),
                Sheet = try Workbook{[Item = "Datos", Kind = "Sheet"]}[Data] otherwise null,
                Headers = if Sheet <> null
                    then Table.PromoteHeaders(Sheet, [PromoteAllScalars = true])
                    else null
            in
                Headers
    ),

    // Unir todas las tablas encontradas
    #"Promoted headers" = Table.Combine(
        List.RemoveNulls(#"Get Datos Sheet"[Datos])
    ),

    #"Changed column type" = Table.TransformColumnTypes(
        #"Promoted headers",
        {
            {"País", type text},
            {"Compañia", type text},
            {"Medio", type text},
            {"Cod. Proveedor", Int64.Type},
            {"Proveedor", type text},
            {"Nif. Empresa/Proveedor", type text},
            {"Pais Empresa Proveedor", type text},
            {"Grupo HVM Proveedor", type text},
            {"Editorial Comercial", type text},
            {"Status Editorial Comercial", type text},
            {"Agrupación Comercial", type text},
            {"Ind. Editorial ON\OFF", type text},
            {"Cod. Soporte", Int64.Type},
            {"Soporte", type text},
            {"Tipo Soporte", type text},
            {"Grupo Comunicación Soporte", type text},
            {"Grupo Soporte", type text},
            {"Exclusivista", type text},
            {"Grupo Negociación", type text},
            {"Grupo Negociación Táctica", type text},
            {"Ind. Auditado Grupo Negociación Táctica", type text},
            {"Grupo Soporte Comercial", type text},
            {"Fecha Baja Soporte", type date},
            {"Fecha Baja Proveedor-Soporte", type date},
            {"Delegación", type text},
            {"Cod. Grupo", Int64.Type},
            {"Grupo", type text},
            {"Grupo Principal", type text},
            {"Cod. Cliente", Int64.Type},
            {"Cliente", type text},
            {"Marca", type text},
            {"Producto", type text},
            {"Grupo Producto", type text},
            {"Empresa", type text},
            {"Nif. Empresa/Cliente", type text},
            {"Pais Empresa", type text},
            {"Grupo HVM", type text},
            {"Agencia", type text},
            {"Grupo Negocio", type text},
            {"Grupo Facturación", type text},
            {"Ind. Bloqueado", type text},
            {"Ind. Autorizado", type text},
            {"Ind. SAG por Separado", type text},
            {"Ind. Fee por Separado", type text},
            {"Ind. Fact. por Partes", type text},
            {"Ind. Ver Subcampana", type text},
            {"Ind. Nº Pedido", type text},
            {"Ind. Fact. Electrónica", type text},
            {"Ind. PDI Cliente", type text},
            {"Ind. PDI Producto", type text},
            {"Ind. Auditoría Financiera", type text},
            {"Campaña", type text},
            {"SubCampaña", type text},
            {"Alcance", type text},
            {"Centro de Coste", type text},
            {"Observaciones de Campaña", type text},
            {"Ind. Campana Interna", type text},
            {"Presupuesto", Int64.Type},
            {"Estado Presup.", type text},
            {"Nº Pedido", type text},
            {"F. Presupuesto", type date},
            {"F. Envío Presupuesto", type date},
            {"Ind. Presup. Autorizado", type text},
            {"Ind. Presup. con Factura", type text},
            {"Acuerdo", type text},
            {"Tipo Presupuesto", type text},
            {"Serv. Agen. Pre.", type text},
            {"MNP Pre.", type text},
            {"SAG BC", Int64.Type},
            {"MNP BC", Int64.Type},
            {"Observaciones de Presupuesto", type text},
            {"Observaciones de Presupuesto Internas", type text},
            {"Oficina", type text},
            {"Clave Indicación Facturación", type text},
            {"Nº Pedido Servicio Agencia", type text},
            {"Observaciones Cabecera", type text},
            {"Observaciones Cabecera SAG", type text},
            {"Concepto Factura", type text},
            {"Concepto Factura SAG", type text},
            {"Orden", Int64.Type},
            {"F. Ejecución", type date},
            {"F. Grabación", type date},
            {"F. Confirmación", type date},
            {"Año", Int64.Type},
            {"Mes", type text},
            {"Día", Int64.Type},
            {"Día Semana", type text},
            {"Semana", Int64.Type},
            {"Quincena", Int64.Type},
            {"Estado Orden", type text},
            {"Material", type text},
            {"Descripción Material", type text},
            {"Contrato", Int64.Type},
            {"F. Contrato", type date},
            {"Observaciones Contrato", type text},
            {"Título anuncio", type text},
            {"Observaciones", type text},
            {"Observaciones 2", type text},
            {"Observaciones Factura", type text},
            {"MNP", Int64.Type},
            {"MNP Calculado", Int64.Type},
            {"Base Calculo MNP", type text},
            {"SAG", Int64.Type},
            {"Base Calculo SAG", type text},
            {"Divisa", type text},
            {"Origen Orden", type text},
            {"Nombre Usuario Orden", type text},
            {"Objetivo", type text},
            {"Tipo de Orden", type text},
            {"Tipo de Compra", type text},
            {"Tipo de Disciplina", type text},
            {"Grupo Disciplina", type text},
            {"Disciplina", type text},
            {"Ind. Acuerdo", type text},
            {"Tipo Acuerdo", type text},
            {"Ind. Acuerdo Intercambio", type text},
            {"Ind. Rappel", type text},
            {"Ind. Ajuste", type text},
            {"Ind. Intercompany", type text},
            {"Ind. Orden F", type text},
            {"Ind. Orden Facturable", type text},
            {"Tipo Publicidad", type text},
            {"Ind. Tipo Publicidad", type text},
            {"Ind. Auditoria Medio", type text},
            {"Tipo Orden Económico", type text},
            {"Tipo Orden Publicidad", type text},
            {"Tipo Orden Financiera", type text},
            {"Tipo Orden Acciones", type text},
            {"Tipo Orden Serv. Prod.", type text},
            {"Tipo Orden HVP", type text},
            {"Tipo Orden Herramienta-Estudio", type text},
            {"Tipologias", type text},
            {"Nº Factura Cli.", Int64.Type},
            {"Fecha Factura Cli.", type date},
            {"Tipo de Factura", type text},
            {"Fecha Grabación Factura Cli.", type date},
            {"Nº Pedido Factura", type text},
            {"Clave Status Factura", type text},
            {"Obs. Factura", type text},
            {"Obs. Internas Factura", type text},
            {"Obs. Cabecera Factura", type text},
            {"Fecha Envio Factura Cli.", type date},
            {"Fecha Vto. Factura Cli.", type date},
            {"Ind. Fact. Anulada", type text},
            {"Nº Prefactura Cli.", type text},
            {"Ref. Factura", type text},
            {"Ref. Orden", type text},
            {"Nº Factura SAG", type text},
            {"Nº Pedido Factura SAG", type text},
            {"Factura Proveedor", type text},
            {"Fecha Factura Prov.", type date},
            {"Fecha Vto. Factura Prov.", type date},
            {"Fecha Aceptación Factura Prov.", type date},
            {"Fecha Pago Factura Prov.", type date},
            {"Num. Factura del Proveedor", type text},
            {"Imp. Total Factura Proveedor", type number},
            {"Compañía Intercompany", type text},
            {"Cod. Campaña Intercompany", type text},
            {"Campaña Intercompany", type text},
            {"Ind. Presupuesto Intercompany", type text},
            {"Acuerdo Negocio", type text},
            {"Desc. Abrv. Acuerdo Negocio", type text},
            {"Grupo Acuerdo Negocio", type text},
            {"Tipo Acuerdo Cliente", type text},
            {"Forma Consumo", type text},
            {"Ind. Pago Consumo", type text},
            {"Cod. Ajuste", type text},
            {"Tipo de Ajuste", type text},
            {"Ind. Ajuste Aprobado", type text},
            {"Categoría de Ajuste", type text},
            {"Motivo de Ajuste", type text},
            {"Referencia de Ajuste", type text},
            {"Acción Ajuste", type text},
            {"Observaciones Ajuste", type text},
            {"Neto Compra (Sum)", type number},
            {"Neto Venta (Sum)", Int64.Type},
            {"Fecha Solicitud Ajuste", type date},
            {"Fecha Aprobación Ajuste", type date},
            {"Imp. Acuerdo", type number},
            {"F. Inicio Acuerdo", type date},
            {"F. Fin Acuerdo", type date},
            {"Fecha Cobro Factura Cli.", type date},
            {"Fecha Prefactura Cli.", type date}
        }
    )

in

    #"Changed column type";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Carga_New_Oracle_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "Origen", DestinationColumnName = "Origen"], [SourceColumnName = "Org Id", DestinationColumnName = "Org Id"], [SourceColumnName = "Compañía", DestinationColumnName = "Compañía"], [SourceColumnName = "Flex Value Set Id CDC", DestinationColumnName = "Flex Value Set Id CDC"], [SourceColumnName = "Origen Usuario", DestinationColumnName = "Origen Usuario"], [SourceColumnName = "Estado", DestinationColumnName = "Estado"], [SourceColumnName = "Secuencia", DestinationColumnName = "Secuencia"], [SourceColumnName = "Cia", DestinationColumnName = "Cia"], [SourceColumnName = "Cod Compania MMS", DestinationColumnName = "Cod Compania MMS"], [SourceColumnName = "Cuenta", DestinationColumnName = "Cuenta"], [SourceColumnName = "Des. Cuenta", DestinationColumnName = "Des. Cuenta"], [SourceColumnName = "CDC", DestinationColumnName = "CDC"], [SourceColumnName = "Des. CDC", DestinationColumnName = "Des. CDC"], [SourceColumnName = "Cliente", DestinationColumnName = "Cliente"], [SourceColumnName = "Imputación", DestinationColumnName = "Imputación"], [SourceColumnName = "Intercía", DestinationColumnName = "Intercía"], [SourceColumnName = "Libre", DestinationColumnName = "Libre"], [SourceColumnName = "Fecha Contable", DestinationColumnName = "Fecha Contable"], [SourceColumnName = "Mes Contable", DestinationColumnName = "Mes Contable"], [SourceColumnName = "Nombre Lote", DestinationColumnName = "Nombre Lote"], [SourceColumnName = "Factura", DestinationColumnName = "Factura"], [SourceColumnName = "Asiento", DestinationColumnName = "Asiento"], [SourceColumnName = "Divisa", DestinationColumnName = "Divisa"], [SourceColumnName = "Num. Tercero", DestinationColumnName = "Num. Tercero"], [SourceColumnName = "Nom. Tercero", DestinationColumnName = "Nom. Tercero"], [SourceColumnName = "Num. Pedido", DestinationColumnName = "Num. Pedido"], [SourceColumnName = "NIF", DestinationColumnName = "NIF"], [SourceColumnName = "Fecha Factura", DestinationColumnName = "Fecha Factura"], [SourceColumnName = "Mes Factura", DestinationColumnName = "Mes Factura"], [SourceColumnName = "Año Factura", DestinationColumnName = "Año Factura"], [SourceColumnName = "Concepto Pedido", DestinationColumnName = "Concepto Pedido"], [SourceColumnName = "Descripción Linea", DestinationColumnName = "Descripción Linea"], [SourceColumnName = "Porcentaje Imputación", DestinationColumnName = "Porcentaje Imputación"], [SourceColumnName = "Debe", DestinationColumnName = "Debe"], [SourceColumnName = "Haber", DestinationColumnName = "Haber"], [SourceColumnName = "Total", DestinationColumnName = "Total"], [SourceColumnName = "Fichero Origen", DestinationColumnName = "Fichero Origen"], [SourceColumnName = "Id_account", DestinationColumnName = "ID_account"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared Carga_New_Oracle = let
    Source = Lakehouse.Contents(null),
    Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
    #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
    #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
    #"Navigation 3" = #"Navigation 2"{[Name = "Reporting Financiero"]}[Content],
    #"Navigation 4" = #"Navigation 3"{[Name = "1. Entrada de Datos"]}[Content],
    #"Navigation 5" = #"Navigation 4"{[Name = "Dinamicos"]}[Content],

    // Seleccionar todos los CSV cuyo nombre contenga "Oracle"
    #"Filtered Oracle Files" =
        Table.SelectRows(
            #"Navigation 5",
            each
                [Content] <> null
                and Text.Contains([Name], "Oracle", Comparer.OrdinalIgnoreCase)
                and Text.EndsWith([Name], ".csv", Comparer.OrdinalIgnoreCase)
        ),

    // Función para transformar cada fichero Oracle
    TransformOracleFile = (FileContent as binary, FileName as text) as table =>
        let
            ImportedCSV =
                Csv.Document(
                    FileContent,
                    [
                        Delimiter = ",",
                        Columns = 36,
                        Encoding = 65001,
                        QuoteStyle = QuoteStyle.None
                    ]
                ),

            AllColumnsAsText =
                Table.TransformColumnTypes(
                    ImportedCSV,
                    List.Transform(
                        Table.ColumnNames(ImportedCSV),
                        each {_, type text}
                    )
                ),

            RemovedEmptyRows =
                Table.SelectRows(
                    AllColumnsAsText,
                    each [Column1] <> null and Text.Trim([Column1]) <> ""
                ),

            PromotedHeaders =
                Table.PromoteHeaders(
                    RemovedEmptyRows,
                    [PromoteAllScalars = true]
                ),

            RemovedTotal =
                Table.SelectRows(
                    PromotedHeaders,
                    each [Origen] <> "Total General"
                ),

            AddedSourceFile =
                Table.AddColumn(
                    RemovedTotal,
                    "Fichero Origen",
                    each FileName,
                    type text
                )
        in
            AddedSourceFile,

    // Aplicar la función a cada fichero
    #"Added Transformed Data" =
        Table.AddColumn(
            #"Filtered Oracle Files",
            "Datos Oracle",
            each TransformOracleFile([Content], [Name]),
            type table
        ),

    // Combinar todos los ficheros
    #"Combined Oracle Files" =
        if Table.RowCount(#"Added Transformed Data") = 0 then
            error "No se ha encontrado ningún fichero CSV cuyo nombre contenga 'Oracle'."
        else
            Table.Combine(#"Added Transformed Data"[Datos Oracle]),

    // Aplicar los tipos después de combinar
    #"Changed column type" =
        Table.TransformColumnTypes(#"Combined Oracle Files", {{"Debe (Sum)", type number}, {"Haber (Sum)", type number}, {"Total (Sum)", type number}, {"Fecha Contable", type date}, {"Cuenta", type text}}, "es-ES"),

    #"Sorted rows" =
        Table.Sort(
            #"Changed column type",
            {{"Fecha Contable", Order.Ascending}}
        ),
  #"Renamed columns" = Table.RenameColumns(#"Sorted rows", {{"Debe (Sum)", "Debe"}, {"Haber (Sum)", "Haber"}, {"Total (Sum)", "Total"}}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Renamed columns", "Id_account", each "ORACLE-" & [Cuenta]), {{"Id_account", type text}})

in
    #"Added custom";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Carga_PT_extrato_contas_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Carga_New_PT_extrato_contas = let
    Source = Lakehouse.Contents(null),
    Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
    #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
    #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
    #"Navigation 3" = #"Navigation 2"{[Name = "Reporting Financiero"]}[Content],
    #"Navigation 4" = #"Navigation 3"{[Name = "1. Entrada de Datos"]}[Content],
    #"Navigation 5" = #"Navigation 4"{[Name = "Dinamicos"]}[Content],

    // Seleccionar únicamente los Excel de extractos de cuentas de Portugal
    #"Filtered PT Files" =
        Table.SelectRows(
            #"Navigation 5",
            each
                [Content] <> null
                and Text.Contains(
                    [Name],
                    "PTG-Tinkle_Extratos de contas",
                    Comparer.OrdinalIgnoreCase
                )
                and (
                    Text.EndsWith([Name], ".xlsx", Comparer.OrdinalIgnoreCase)
                    or Text.EndsWith([Name], ".xls", Comparer.OrdinalIgnoreCase)
                )
                and not Text.StartsWith([Name], "~$")
        ),

    // Función para transformar cada fichero
    TransformPTFile = (FileContent as binary, FileName as text) as table =>
        let
            ImportedWorkbook =
                Excel.Workbook(
                    FileContent,
                    null,
                    true
                ),

            // Buscar la hoja llamada "Sheet"
            SheetData =
                ImportedWorkbook{[Item = "Sheet", Kind = "Sheet"]}[Data],

            PromotedHeaders =
                Table.PromoteHeaders(
                    SheetData,
                    [PromoteAllScalars = true]
                ),

            // Detectar las cabeceras de cuenta
            AddedContaHeader =
                Table.AddColumn(
                    PromotedHeaders,
                    "Conta Header",
                    each
                        if [Data] <> null
                            and Text.StartsWith(Text.From([Data]), "Conta :")
                        then
                            Text.From([Data])
                        else
                            null,
                    type text
                ),

            // Hacer que cada movimiento herede su cuenta
            FilledDownConta =
                Table.FillDown(
                    AddedContaHeader,
                    {"Conta Header"}
                ),

            // Extraer el texto completo de la cuenta
            AddedContaTexto =
                Table.AddColumn(
                    FilledDownConta,
                    "Conta Texto",
                    each
                        if [Conta Header] <> null
                        then
                            Text.Trim(
                                Text.AfterDelimiter(
                                    [Conta Header],
                                    "Conta : "
                                )
                            )
                        else
                            null,
                    type text
                ),

            // Extraer código de cuenta
            AddedContaCodigo =
                Table.AddColumn(
                    AddedContaTexto,
                    "Conta Codigo",
                    each
                        if [Conta Texto] <> null
                        then
                            Text.Trim(
                                Text.BeforeDelimiter(
                                    [Conta Texto],
                                    " - "
                                )
                            )
                        else
                            null,
                    type text
                ),

            // Extraer descripción de cuenta
            AddedContaNome =
                Table.AddColumn(
                    AddedContaCodigo,
                    "Conta Nome",
                    each
                        if [Conta Texto] <> null then
                            let
                                DepoisCodigo =
                                    Text.Trim(
                                        Text.AfterDelimiter(
                                            [Conta Texto],
                                            " - "
                                        )
                                    ),

                                SemContador =
                                    try
                                        Text.Trim(
                                            Text.BeforeDelimiter(
                                                DepoisCodigo,
                                                " (",
                                                {0, RelativePosition.FromEnd}
                                            )
                                        )
                                    otherwise
                                        DepoisCodigo
                            in
                                SemContador
                        else
                            null,
                    type text
                ),

            // Conservar solo movimientos
            FilteredMovements =
                Table.SelectRows(
                    AddedContaNome,
                    each
                        [Conta Header] <> null
                        and [Data] <> null
                        and not Text.StartsWith(
                            Text.From([Data]),
                            "Conta :"
                        )
                ),

            ChangedTypes =
                Table.TransformColumnTypes(
                    FilteredMovements,
                    {
                        {"Data", type text},
                        {"Diário", Int64.Type},
                        {"N.º Diário", Int64.Type},
                        {"Descrição", type text},
                        {"Débito", type number},
                        {"Crédito", type number},
                        {"Saldo", type number},
                        {"Doc.", type text},
                        {"N.º Doc.", Int64.Type},
                        {"Conta Origem", type text},
                        {"IVA", type text},
                        {"% n/Ded.", Int64.Type},
                        {"IVA Autoliq.", type text},
                        {"Selo", type text},
                        {"Ano", Int64.Type},
                        {"Lançamento", type text},
                        {"Conta Header", type text},
                        {"Conta Texto", type text},
                        {"Conta Codigo", type text},
                        {"Conta Nome", type text}
                    }
                ),

            // Importe neto
            AddedImporteNeto =
                Table.AddColumn(
                    ChangedTypes,
                    "Importe Neto",
                    each
                        (if [Débito] = null then 0 else [Débito])
                        -
                        (if [Crédito] = null then 0 else [Crédito]),
                    type number
                ),

            AddedSociedade =
                Table.AddColumn(
                    AddedImporteNeto,
                    "Sociedade",
                    each "Portugal",
                    type text
                ),

            // Se asume que el nombre termina en MM-YYYY.xlsx
            PeriodoArchivo =
                let
                    NombreSinExtension =
                        Text.BeforeDelimiter(
                            FileName,
                            ".",
                            {0, RelativePosition.FromEnd}
                        ),

                    MesAnio =
                        Text.End(
                            NombreSinExtension,
                            7
                        ),

                    Mes =
                        Text.Start(
                            MesAnio,
                            2
                        ),

                    Anio =
                        Text.End(
                            MesAnio,
                            4
                        )
                in
                    Anio & "-" & Mes,

            AddedPeriodo =
                Table.AddColumn(
                    AddedSociedade,
                    "Periodo",
                    each PeriodoArchivo,
                    type text
                ),

            AddedSourceFile =
                Table.AddColumn(
                    AddedPeriodo,
                    "Fichero Origen",
                    each FileName,
                    type text
                )
        in
            AddedSourceFile,

    // Aplicar la función a cada fichero encontrado
    #"Added Transformed Data" =
        Table.AddColumn(
            #"Filtered PT Files",
            "Datos Portugal",
            each TransformPTFile([Content], [Name]),
            type table
        ),

    // Combinar todos los extractos
    #"Combined PT Files" =
        if Table.RowCount(#"Added Transformed Data") = 0 then
            error "No se ha encontrado ningún fichero cuyo nombre contenga 'PTG-Tinkle_Extratos de contas'."
        else
            Table.Combine(
                #"Added Transformed Data"[Datos Portugal]
            )

in
    #"Combined PT Files";
shared Carga_PT_extrato_contas_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "100", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "New_PT_extrato_contas", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[BindToDefaultDestination = false, DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Carga_HAPA_asientos_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Carga_New_HAPA_asientos = let
    Source = Lakehouse.Contents(null),
    Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
    #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
    #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
    #"Navigation 3" = #"Navigation 2"{[Name = "Reporting Financiero"]}[Content],
    #"Navigation 4" = #"Navigation 3"{[Name = "1. Entrada de Datos"]}[Content],
    #"Navigation 5" = #"Navigation 4"{[Name = "Dinamicos"]}[Content],

    #"Navigation 6" =
        Table.SelectRows(
            #"Navigation 5",
            each Text.Contains([Name], "HAPA-Asientos", Comparer.OrdinalIgnoreCase)
        ){0}[Content],

    #"Imported Excel workbook" = Excel.Workbook(#"Navigation 6", null, true),
    #"Navigation 7" = #"Imported Excel workbook"{[Item = "Hoja1", Kind = "Sheet"]}[Data],
    #"Changed column type" = Table.TransformColumnTypes(#"Navigation 7", {{"Column1", type text}, {"Column3", type text}, {"Column5", type text}, {"Column7", type text}, {"Column8", type text}, {"Column9", type text}, {"Column12", type text}, {"Column19", type text}, {"Column21", type text}, {"Column28", type text}, {"Column29", type text}, {"Column31", type text}, {"Column33", type text}, {"Column34", type text}, {"Column35", type text}, {"Column36", type text}, {"Column39", type text}, {"Column42", type text}}),
    #"Filtered rows" = Table.SelectRows(#"Changed column type", each ([Column1] = "01/04/2026" or [Column1] = "Fecha")),
    #"Promoted headers" = Table.PromoteHeaders(#"Filtered rows", [PromoteAllScalars = true]),
    #"Changed column type 1" = Table.TransformColumnTypes(#"Promoted headers", {{"Fecha", type date}, {"Número de asiento", Int64.Type}, {"Cód. diario", Int64.Type}, {"Fecha grabación", type date}, {"Código cuenta", type text}, {"Debe", type number}, {"Haber", type number}, {"Ejercicio", Int64.Type}, {"Número página", Int64.Type}, {"Debe_1", Int64.Type}, {"Haber_2", Int64.Type}, {"Arrastra Debe", Int64.Type}, {"Arrastra Haber", Int64.Type}, {"Fecha informe", type date}, {"Total asiento", Int64.Type}, {"Total mes", Int64.Type}, {"Total día", Int64.Type}, {"Imprimir sumas anteriores", Int64.Type}, {"Flag final", Int64.Type}, {"Número periodo", Int64.Type}, {"Cód. canal", Int64.Type}, {"Importe divisa", Int64.Type}, {"Importe cambio", Int64.Type}, {"Número de factura", Int64.Type}, {"Fecha vcto.", type date}, {"Cód. empresa", Int64.Type}, {"Fecha asiento", type date}})
in
    #"Changed column type 1";
shared Carga_HAPA_asientos_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "100", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "New_HAPA", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Carga_New_MMS_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "100", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "New_MMS", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Carga_New_Oracle_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[lakehouseName = "lh_tinkle_financiero"]}[Data],
  Navigation_3 = Navigation_2{[Id = "100", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "New_Oracle", ItemKind = "Table"]}[Data]
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Carga_New_Agings_Proveedores_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Carga_New_Agings_Proveedores = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "Reporting Financiero"]}[Content],
  #"Navigation 4" = #"Navigation 3"{[Name = "1. Entrada de Datos"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "Dinamicos"]}[Content],
  #"Navigation 6" = #"Navigation 5"{[Name = "AGINGS"]}[Content],

  #"Navigation 7" =
      Table.SelectRows(
          #"Navigation 6",
          each Text.Contains([Name], "Aging proveedores", Comparer.OrdinalIgnoreCase)
      ){0}[Content],

  #"Imported Excel workbook" = Excel.Workbook(#"Navigation 7", null, true),
  #"Navigation 8" = #"Imported Excel workbook"{[Item = "Datos", Kind = "Sheet"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 8", {{"Column1", type text}, {"Column2", type text}, {"Column3", type text}, {"Column4", type text}, {"Column5", type text}, {"Column9", type text}, {"Column10", type text}, {"Column11", type text}, {"Column12", type text}}),
  #"Filtered rows" = Table.SelectRows(#"Changed column type", each ([Column1] <> null and [Column1] <> "Grand Total")),
  #"Promoted headers" = Table.PromoteHeaders(#"Filtered rows", [PromoteAllScalars = true]),
  #"Replaced value" = Table.ReplaceValue(#"Promoted headers", "", null, Replacer.ReplaceValue, {"Imp. Vencido (Sum)", "Imp. Pendiente (Sum)", "Imp. Factura (Sum)", "IBAN", "Método", "Moneda", "Medio", "Fecha Contable", "Fecha Vencimiento", "Fecha Factura", "Nº Factura", "CIF Proveedor", "Proveedor", "Cod. Proveedor", "Compañía"}),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Replaced value", {{"Cod. Proveedor", type text}, {"Fecha Factura", type date}, {"Fecha Vencimiento", type date}, {"Fecha Contable", type date}, {"Imp. Factura (Sum)", type number}, {"Imp. Pendiente (Sum)", type number}, {"Imp. Vencido (Sum)", type number}}),
  #"Renamed columns" = Table.RenameColumns(#"Changed column type 1", {{"Imp. Factura (Sum)", "Imp_Factura"}, {"Imp. Pendiente (Sum)", "Imp_Pendiente"}, {"Imp. Vencido (Sum)", "Imp_Vencido"}})
in
  #"Renamed columns";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Carga_New_Agings_Clientes_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Carga_New_Agings_Clientes = let

    Source = Lakehouse.Contents(null),

    Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],

    #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],

    #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],

    #"Navigation 3" = #"Navigation 2"{[Name = "Reporting Financiero"]}[Content],

    #"Navigation 4" = #"Navigation 3"{[Name = "1. Entrada de Datos"]}[Content],

    #"Navigation 5" = #"Navigation 4"{[Name = "Dinamicos"]}[Content],

    #"Navigation 6" = #"Navigation 5"{[Name = "AGINGS"]}[Content],

    #"Navigation 7" =
        Table.SelectRows(
            #"Navigation 6",
            each Text.Contains([Name], "Aging clientes", Comparer.OrdinalIgnoreCase)
        ){0}[Content],

    #"Imported Excel workbook" = Excel.Workbook(#"Navigation 7", null, true),

    #"Navigation 8" = #"Imported Excel workbook"{[Item = "HMES___Aging_en_Detalle_todas__", Kind = "Sheet"]}[Data],

    #"Filtered rows" = Table.SelectRows(#"Navigation 8", each ([Column6] <> null)),

    #"Promoted headers" = Table.PromoteHeaders(#"Filtered rows", [PromoteAllScalars = true]),

    #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"Proveedor", type text}, {"Cobrador", type text}, {"Interno", type text}, {"Nombre Cliente", type text}, {"Pais", type text}, {"Nº Factura", type text}, {"F. Envío  Presup.  Medio  Producto  F. Ins.", type text}, {"NIF", type text}, {"Tipo Factura", type text}, {"F.Factura", type date}, {"F. Vto.", type date}, {"Imp. Factura", type number}, {"S. Pendiente", type number}}),

    #"Renamed columns" = Table.RenameColumns(#"Changed column type", {{"Imp. Factura", "Imp_Factura"}, {"S. Pendiente", "S_Pendiente"}})

in

    #"Renamed columns";
shared Carga_New_Agings_Proveedores_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "100", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "New_Agings_Proveedores", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Carga_New_Agings_Clientes_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "100", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "New_Agings_Clientes", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
