[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Replace"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Carga Oracle historico desde Checklist_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "Origen", DestinationColumnName = "Origen"], [SourceColumnName = "Org Id", DestinationColumnName = "Org Id"], [SourceColumnName = "Compañía", DestinationColumnName = "Compañía"], [SourceColumnName = "Flex Value Set Id CDC", DestinationColumnName = "Flex Value Set Id CDC"], [SourceColumnName = "Origen Usuario", DestinationColumnName = "Origen Usuario"], [SourceColumnName = "Estado", DestinationColumnName = "Estado"], [SourceColumnName = "Secuencia", DestinationColumnName = "Secuencia"], [SourceColumnName = "Cia", DestinationColumnName = "Cia"], [SourceColumnName = "Cod Compania MMS", DestinationColumnName = "Cod Compania MMS"], [SourceColumnName = "Cuenta", DestinationColumnName = "Cuenta"], [SourceColumnName = "Des. Cuenta", DestinationColumnName = "Des. Cuenta"], [SourceColumnName = "CDC", DestinationColumnName = "CDC"], [SourceColumnName = "Des. CDC", DestinationColumnName = "Des. CDC"], [SourceColumnName = "Cliente", DestinationColumnName = "Cliente"], [SourceColumnName = "Imputación", DestinationColumnName = "Imputación"], [SourceColumnName = "Intercía", DestinationColumnName = "Intercía"], [SourceColumnName = "Libre", DestinationColumnName = "Libre"], [SourceColumnName = "Fecha Contable", DestinationColumnName = "Fecha Contable"], [SourceColumnName = "Mes Contable", DestinationColumnName = "Mes Contable"], [SourceColumnName = "Nombre Lote", DestinationColumnName = "Nombre Lote"], [SourceColumnName = "Factura", DestinationColumnName = "Factura"], [SourceColumnName = "Asiento", DestinationColumnName = "Asiento"], [SourceColumnName = "Divisa", DestinationColumnName = "Divisa"], [SourceColumnName = "Num. Tercero", DestinationColumnName = "Num. Tercero"], [SourceColumnName = "Nom. Tercero", DestinationColumnName = "Nom. Tercero"], [SourceColumnName = "Num. Pedido", DestinationColumnName = "Num. Pedido"], [SourceColumnName = "NIF", DestinationColumnName = "NIF"], [SourceColumnName = "Fecha Factura", DestinationColumnName = "Fecha Factura"], [SourceColumnName = "Mes Factura", DestinationColumnName = "Mes Factura"], [SourceColumnName = "Año Factura", DestinationColumnName = "Año Factura"], [SourceColumnName = "Concepto Pedido", DestinationColumnName = "Concepto Pedido"], [SourceColumnName = "Descripción Linea", DestinationColumnName = "Descripción Linea"], [SourceColumnName = "Porcentaje Imputación", DestinationColumnName = "Porcentaje Imputación"], [SourceColumnName = "Debe", DestinationColumnName = "Debe"], [SourceColumnName = "Haber", DestinationColumnName = "Haber"], [SourceColumnName = "Total", DestinationColumnName = "Total"], [SourceColumnName = "Divisa Reporting", DestinationColumnName = "Divisa Reporting"], [SourceColumnName = "Categoria", DestinationColumnName = "Categoria"], [SourceColumnName = "RevAmount", DestinationColumnName = "RevAmount"], [SourceColumnName = "Interco", DestinationColumnName = "Interco"], [SourceColumnName = "Mes", DestinationColumnName = "Mes"], [SourceColumnName = "Num & Nom Tercero ", DestinationColumnName = "Num & Nom Tercero_"], [SourceColumnName = "Cuenta & Descripción", DestinationColumnName = "Cuenta & Descripción"], [SourceColumnName = "Fichero Origen", DestinationColumnName = "Fichero Origen"], [SourceColumnName = "ID_account", DestinationColumnName = "ID_account"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared #"Carga Oracle historico desde Checklist" = let
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

    #"Navigation 5" =
        #"Navigation 4"{
            [Name = "Arranque"]
        }[Content],

    #"Navigation 6" =
        #"Navigation 5"{
            [Name = "1-Checklist 2026 03(v11) - copia.xlsm"]
        }[Content],

    // Lectura del Excel sin forzar tipos automáticamente
    #"Imported Excel workbook" =
        Excel.Workbook(
            #"Navigation 6",
            [
                DelayTypes = true,
                InferSheetDimensions = true
            ]
        ),

    #"Navigation 7" =
        #"Imported Excel workbook"{
            [Item = "Oracle", Kind = "Sheet"]
        }[Data],

    #"Promoted headers" =
        Table.PromoteHeaders(
            #"Navigation 7",
            [PromoteAllScalars = true]
        ),

    // Si alguna de estas columnas desaparece del Excel,
    // el refresh no falla por ello
    #"Removed columns 1" =
        Table.RemoveColumns(
            #"Promoted headers",
            {
                "CDEC",
                "Desc.CDEC",
                "FECHA CONTAB",
                "ACCOUNT",
                "DESCRIPTION",
                "Nombre Cliente",
                "Seccion",
                "DESCRIP.CTA.",
                "TIPO",
                "CodCDC"
            },
            MissingField.Ignore
        ),

    /*
        Función segura para fechas.

        Admite:
        - valores que ya sean date
        - datetime
        - datetimezone
        - texto como 31/12/2025
        - null / vacío

        Si el contenido no se puede interpretar como fecha,
        devuelve null en vez de cancelar el dataflow.
    */
    ParseDate = (value as any) as nullable date =>
        if value = null then
            null
        else if Value.Is(value, type date) then
            value
        else if Value.Is(value, type datetime) then
            Date.From(value)
        else if Value.Is(value, type datetimezone) then
            Date.From(value)
        else
            let
                TextValue = Text.Trim(Text.From(value)),
                ParsedES =
                    try Date.FromText(
                        TextValue,
                        [Culture = "es-ES"]
                    ),
                ParsedGeneric =
                    if ParsedES[HasError] then
                        try Date.From(value)
                    else
                        ParsedES
            in
                if TextValue = "" then
                    null
                else if ParsedGeneric[HasError] then
                    null
                else
                    ParsedGeneric[Value],

    // Primero convertimos todos los campos que NO son fechas
    #"Changed column type" =
        Table.TransformColumnTypes(
            #"Removed columns 1",
            {
                {"Divisa Reporting", type text},
                {"Categoria", type text},
                {"Cuenta", type text},
                {"Origen", type text},
                {"Org Id", type text},
                {"Compañía", type text},
                {"Flex Value Set Id CDC", type text},
                {"Origen Usuario", type text},
                {"Estado", type text},
                {"Secuencia", type text},
                {"Cia", type text},
                {"Cod Compania MMS", type text},
                {"Des. Cuenta", type text},
                {"CDC", type text},
                {"Des. CDC", type text},
                {"Cliente", type text},
                {"Imputación", type text},
                {"Intercía", type text},
                {"Libre", type text},
                {"Descripción Linea", type text},
                {"Concepto Pedido", type text},
                {"Año Factura", type text},
                {"Mes Factura", type text},
                {"NIF", type text},
                {"Num. Pedido", type text},
                {"Nom. Tercero", type text},
                {"Num. Tercero", type text},
                {"Divisa", type text},
                {"Asiento", type text},
                {"Factura", type text},
                {"Nombre Lote", type text},
                {"Mes Contable", type text},
                {"Porcentaje Imputación", Int64.Type},
                {"Debe (Sum)", Currency.Type},
                {"Haber (Sum)", Currency.Type},
                {"Total (Sum)", Currency.Type},
                {"RevAmount", Currency.Type},
                {"Interco", type text},
                {"Mes", type text}
            },
            [
                Culture = "es-ES",
                MissingField = MissingField.Ignore
            ]
        ),

    // Conversión controlada de las fechas
    #"Parsed dates" =
        Table.TransformColumns(
            #"Changed column type",
            {
                {
                    "Fecha Contable",
                    each ParseDate(_),
                    type date
                },
                {
                    "Fecha Factura",
                    each ParseDate(_),
                    type date
                }
            },
            null,
            MissingField.Ignore
        ),

    // Concatenaciones protegidas frente a null
    #"Added custom 1" =
        Table.AddColumn(
            #"Parsed dates",
            "Num & Nom Tercero ",
            each
                Text.Combine(
                    List.RemoveNulls(
                        {
                            try Text.From([Num. Tercero]) otherwise null,
                            try Text.From([Nom. Tercero]) otherwise null
                        }
                    ),
                    " - "
                ),
            type text
        ),

    #"Added custom 2" =
        Table.AddColumn(
            #"Added custom 1",
            "Cuenta & Descripción",
            each
                Text.Combine(
                    List.RemoveNulls(
                        {
                            try Text.From([Cuenta]) otherwise null,
                            try Text.From([Des. Cuenta]) otherwise null
                        }
                    ),
                    " - "
                ),
            type text
        ),

    #"Added custom" =
        Table.AddColumn(
            #"Added custom 2",
            "Fichero Origen",
            each null,
            type text
        ),

    #"Renamed columns" =
        Table.RenameColumns(
            #"Added custom",
            {
                {"Debe (Sum)", "Debe"},
                {"Haber (Sum)", "Haber"},
                {"Total (Sum)", "Total"}
            },
            MissingField.Ignore
        ),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Renamed columns", {{"Debe", type number}, {"Haber", type number}, {"Total", type number}, {"RevAmount", type number}}),
  #"Added custom 3" = Table.TransformColumnTypes(Table.AddColumn(#"Changed column type 1", "ID_account", each "ORACLE-" & [Cuenta]), {{"ID_account", type text}})

in
    #"Added custom 3";
shared DefaultDestination = Lakehouse.Contents([EnableFolding = false]){[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data]{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data];
shared #"Carga Oracle historico desde Checklist_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "200", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Oracle_historico", ItemKind = "Table"]}[Data]
in
  TableNavigation;
