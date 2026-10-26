[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared #"B01 JAZZ" = let
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
  #"Navigation 3" = #"Navigation 2"{[Name = "Reporting Financiero"]}[Content],
  #"Navigation 4" = #"Navigation 3"{[Name = "1. Entrada de Datos"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "Arranque"]}[Content],
  #"Navigation 6" = #"Navigation 5"{[Name = "1-Checklist 2026 03(v11) - copia.xlsm"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(#"Navigation 6", null, true),
  #"Navigation 7" = #"Imported Excel workbook"{[Item = "B01 JAZZ", Kind = "Sheet"]}[Data],
  #"Filtered rows" = Table.SelectRows(#"Navigation 7", each ([Column1] <> null and [Column1] <> 1 and [Column1] <> "Income Statement")),
  #"Removed columns" = Table.RemoveColumns(#"Filtered rows", {"Column1"}),
  #"Promoted headers 1" = Table.PromoteHeaders(#"Removed columns", [PromoteAllScalars = true]),
  #"Filtered rows 1" = Table.SelectRows(#"Promoted headers 1", each ([Column1] <> null)),
  #"Renamed columns" = Table.RenameColumns(#"Filtered rows 1", {{"Column1", "Cuenta"}}),
  #"Choose columns" = Table.SelectColumns(#"Renamed columns", {"Cuenta", "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Choose columns", {{"Cuenta", type text}, {"Enero", type number}, {"Febrero", type number}, {"Marzo", type number}, {"Abril", type number}, {"Mayo", type number}, {"Junio", type number}, {"Julio", type number}, {"Agosto", type number}, {"Septiembre", type number}, {"Octubre", type number}, {"Noviembre", type number}, {"Diciembre", type number}}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Changed column type", "Sociedad", each "JAZZ"), {{"Sociedad", type text}})

in
    #"Added custom";
shared #"B01 ONION" = let
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
  #"Navigation 3" = #"Navigation 2"{[Name = "Reporting Financiero"]}[Content],
  #"Navigation 4" = #"Navigation 3"{[Name = "1. Entrada de Datos"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "Arranque"]}[Content],
  #"Navigation 6" = #"Navigation 5"{[Name = "1-Checklist 2026 03(v11) - copia.xlsm"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(#"Navigation 6", null, true),
  #"Navigation 7" = #"Imported Excel workbook"{[Item = "B01 ONION", Kind = "Sheet"]}[Data],
  #"Filtered rows" = Table.SelectRows(#"Navigation 7", each ([Column1] <> null and [Column1] <> 1 and [Column1] <> "Income Statement")),
  #"Removed columns" = Table.RemoveColumns(#"Filtered rows", {"Column1"}),
  #"Promoted headers 1" = Table.PromoteHeaders(#"Removed columns", [PromoteAllScalars = true]),
  #"Filtered rows 1" = Table.SelectRows(#"Promoted headers 1", each ([Column1] <> null)),
  #"Renamed columns" = Table.RenameColumns(#"Filtered rows 1", {{"Column1", "Cuenta"}}),
  #"Choose columns" = Table.SelectColumns(#"Renamed columns", {"Cuenta", "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Choose columns", {{"Cuenta", type text}, {"Enero", type number}, {"Febrero", type number}, {"Marzo", type number}, {"Abril", type number}, {"Mayo", type number}, {"Junio", type number}, {"Julio", type number}, {"Agosto", type number}, {"Septiembre", type number}, {"Octubre", type number}, {"Noviembre", type number}, {"Diciembre", type number}}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Changed column type", "Sociedad", each "ONION"), {{"Sociedad", type text}})

in
    #"Added custom";
shared #"B01 PORT" = let
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
  #"Navigation 3" = #"Navigation 2"{[Name = "Reporting Financiero"]}[Content],
  #"Navigation 4" = #"Navigation 3"{[Name = "1. Entrada de Datos"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "Arranque"]}[Content],
  #"Navigation 6" = #"Navigation 5"{[Name = "1-Checklist 2026 03(v11) - copia.xlsm"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(#"Navigation 6", null, true),
  #"Navigation 7" = #"Imported Excel workbook"{[Item = "B01 PORT", Kind = "Sheet"]}[Data],
  #"Filtered rows" = Table.SelectRows(#"Navigation 7", each ([Column1] <> null and [Column1] <> 1 and [Column1] <> "Income Statement")),
  #"Removed columns" = Table.RemoveColumns(#"Filtered rows", {"Column1"}),
  #"Promoted headers 1" = Table.PromoteHeaders(#"Removed columns", [PromoteAllScalars = true]),
  #"Filtered rows 1" = Table.SelectRows(#"Promoted headers 1", each ([Column1] <> null)),
  #"Renamed columns" = Table.RenameColumns(#"Filtered rows 1", {{"Column1", "Cuenta"}}),
  #"Choose columns" = Table.SelectColumns(#"Renamed columns", {"Cuenta", "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Choose columns", {{"Cuenta", type text}, {"Enero", type number}, {"Febrero", type number}, {"Marzo", type number}, {"Abril", type number}, {"Mayo", type number}, {"Junio", type number}, {"Julio", type number}, {"Agosto", type number}, {"Septiembre", type number}, {"Octubre", type number}, {"Noviembre", type number}, {"Diciembre", type number}}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Changed column type", "Sociedad", each "PORTUGAL"), {{"Sociedad", type text}})

in
    #"Added custom";
shared #"B01 CONS" = let
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
  #"Navigation 3" = #"Navigation 2"{[Name = "Reporting Financiero"]}[Content],
  #"Navigation 4" = #"Navigation 3"{[Name = "1. Entrada de Datos"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "Arranque"]}[Content],
  #"Navigation 6" = #"Navigation 5"{[Name = "1-Checklist 2026 03(v11) - copia.xlsm"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(#"Navigation 6", null, true),
  #"Navigation 7" = #"Imported Excel workbook"{[Item = "B01 CONS", Kind = "Sheet"]}[Data],
  #"Filtered rows" = Table.SelectRows(#"Navigation 7", each ([Column1] <> null and [Column1] <> 1 and [Column1] <> "Income Statement")),
  #"Removed columns" = Table.RemoveColumns(#"Filtered rows", {"Column1"}),
  #"Promoted headers 1" = Table.PromoteHeaders(#"Removed columns", [PromoteAllScalars = true]),
  #"Filtered rows 1" = Table.SelectRows(#"Promoted headers 1", each ([Column1] <> null)),
  #"Renamed columns" = Table.RenameColumns(#"Filtered rows 1", {{"Column1", "Cuenta"}}),
  #"Choose columns" = Table.SelectColumns(#"Renamed columns", {"Cuenta", "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Choose columns", {{"Cuenta", type text}, {"Enero", type number}, {"Febrero", type number}, {"Marzo", type number}, {"Abril", type number}, {"Mayo", type number}, {"Junio", type number}, {"Julio", type number}, {"Agosto", type number}, {"Septiembre", type number}, {"Octubre", type number}, {"Noviembre", type number}, {"Diciembre", type number}}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Changed column type", "Sociedad", each "CONS"), {{"Sociedad", type text}})

in
    #"Added custom";
shared #"B01 TOTAL (Checklist)" = let
    #"Appended query" = Table.Combine({
        #"B01 CONS",
        #"B01 JAZZ",
        #"B01 ONION",
        #"B01 PORT"
    }),

    #"Added Año" = Table.AddColumn(
        #"Appended query",
        "Año",
        each 2026,
        Int64.Type
    ),

    #"Unpivoted columns" = Table.UnpivotOtherColumns(
        #"Added Año",
        {"Cuenta", "Sociedad", "Año"},
        "Mes",
        "Value"
    ),

    #"Added Fecha" = Table.AddColumn(
        #"Unpivoted columns",
        "Fecha",
        each #date(
            [Año],
            List.PositionOf(
                {
                    "Enero","Febrero","Marzo","Abril","Mayo","Junio",
                    "Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"
                },
                [Mes]
            ) + 1,
            1
        ),
        type date
    ),

    #"Added Año Mes" = Table.TransformColumnTypes(Table.AddColumn(#"Added Fecha", "Año Mes", each Date.ToText([Fecha], "yyyy - MM")), {{"Año Mes", type text}}),

    #"Reordered columns" = Table.ReorderColumns(
        #"Added Año Mes",
        {
            "Cuenta",
            "Sociedad",
            "Año",
            "Mes",
            "Fecha",
            "Año Mes",
            "Value"
        }
    )
in
    #"Reordered columns";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "FORECASTS y BUDGET_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"FORECASTS y BUDGET" = let
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
  #"Navigation 3" = #"Navigation 2"{[Name = "Reporting Financiero"]}[Content],
  #"Navigation 4" = #"Navigation 3"{[Name = "1. Entrada de Datos"]}[Content],
  Navegación = #"Navigation 4"{[Name = "Arranque"]}[Content],
  #"Navegación 1" = Navegación{[Name = "TINKLE FORECAST 2026 FT3.xlsm"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(#"Navegación 1", null, true),
  #"Filas filtradas" = Table.SelectRows(#"Libro de Excel importado", each ([Name] = "ESP066 COMMUNICATIONS" or [Name] = "ESP067 EUROPEAN" or [Name] = "ESP068 JAZZ" or [Name] = "ESP069 ONION" or [Name] = "ESP070 CONSULTANTS" or [Name] = "PTE019")),
  #"Data expandido" = Table.ExpandTableColumn(#"Filas filtradas", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22", "Column23", "Column24", "Column25", "Column26", "Column27", "Column28", "Column29", "Column30", "Column31", "Column32", "Column33", "Column34", "Column35", "Column36", "Column37", "Column38", "Column39", "Column40", "Column41", "Column42", "Column43", "Column44", "Column45"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22", "Column23", "Column24", "Column25", "Column26", "Column27", "Column28", "Column29", "Column30", "Column31", "Column32", "Column33", "Column34", "Column35", "Column36", "Column37", "Column38", "Column39", "Column40", "Column41", "Column42", "Column43", "Column44", "Column45"}),
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Data expandido", [PromoteAllScalars = true]),
  #"Encabezados promovidos 1" = Table.PromoteHeaders(#"Encabezados promovidos", [PromoteAllScalars = true]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos 1", {{"Income Statement", type text}, {"Column44", type text}, {"Column45", Int64.Type}}, "es"),
  #"Filas filtradas 1" = Table.SelectRows(#"Tipo de columna cambiado", each Text.StartsWith([Income Statement], "R")),
  #"Filas filtradas 2" = Table.SelectRows(#"Filas filtradas 1", each ([Income Statement] <> "R" and [Income Statement] <> "Revenue IFRS15")),
  #"Columnas quitadas" = Table.RemoveColumns(#"Filas filtradas 2", {"Column15", "Column28", "Column29", "Column42", "Column43", "Column45", "Column46", "ESP066 COMMUNICATIONS_25", "Sheet", "false"}),
  #"Columnas con dinamización anulada" = Table.UnpivotOtherColumns(#"Columnas quitadas", {"ESP066 COMMUNICATIONS", "Income Statement", "Column44"}, "Atributo", "Valor"),
  #"Dividir columna por delimitador" = Table.SplitColumn(#"Columnas con dinamización anulada", "Atributo", Splitter.SplitTextByDelimiter("_"), {"Atributo.1", "Atributo.2"}),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Dividir columna por delimitador", {{"Atributo.2", Int64.Type}}),
  #"Columna condicional insertada" = Table.AddColumn(#"Tipo de columna cambiado 1", "Forecast", each if [Atributo.2] = null then "FT3 2026" else if [Atributo.2] <= 12 then "B1 2026" else if [Atributo.2] <= 24 then "FT8 2025" else null),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Columna condicional insertada", {{"Atributo.1", "Año_mes"}}),
  #"Fecha de análisis insertada" = Table.AddColumn(#"Columnas con nombre cambiado", "Analizar", each Date.From(DateTimeZone.From([Año_mes])), type nullable date),
  #"Columnas con nombre cambiado 3" = Table.RenameColumns(#"Fecha de análisis insertada", {{"Analizar", "Fecha"}}),
  #"Tipo de columna cambiado 2" = Table.TransformColumnTypes(#"Columnas con nombre cambiado 3", {{"Año_mes", Int64.Type}}, "es"),
  #"Columnas quitadas 1" = Table.RemoveColumns(#"Tipo de columna cambiado 2", {"Atributo.2", "Income Statement"}),
  #"Tipo de columna cambiado 3" = Table.TransformColumnTypes(#"Columnas quitadas 1", {{"Valor", type number}, {"Forecast", type text}}),
  #"Primeros caracteres insertados" = Table.AddColumn(#"Tipo de columna cambiado 3", "Primeros caracteres", each Text.Start(Text.From([Forecast]), 3), type text),
  #"Columnas con nombre cambiado 1" = Table.RenameColumns(#"Primeros caracteres insertados", {{"Primeros caracteres", "Tipo Forecast"}, {"Column44", "Cuenta"}, {"ESP066 COMMUNICATIONS", "Sociedad"}}),
  #"Últimos caracteres insertados" = Table.AddColumn(#"Columnas con nombre cambiado 1", "Últimos caracteres", each Text.End(Text.From([Año_mes]), 2), type text),
  #"Columnas con nombre cambiado 2" = Table.RenameColumns(#"Últimos caracteres insertados", {{"Últimos caracteres", "Mes_num"}}),
  #"Columnas reordenadas" = Table.ReorderColumns(#"Columnas con nombre cambiado 2", {"Sociedad", "Cuenta", "Año_mes", "Forecast", "Fecha", "Tipo Forecast", "Mes_num", "Valor"}),
  #"Columna condicional insertada 1" = Table.AddColumn(#"Columnas reordenadas", "Personalizado", each if Text.Contains([Sociedad], "COMMUNICATIONS") then "COMM" else if Text.Contains([Sociedad], "JAZZ") then "JAZZ" else if Text.Contains([Sociedad], "ONION") then "ONION" else if Text.Contains([Sociedad], "CONSULTANTS") then "CONS" else if Text.Contains([Sociedad], "PTE") then "PORTUGAL" else null),
  #"Tipo de columna cambiado 4" = Table.TransformColumnTypes(#"Columna condicional insertada 1", {{"Personalizado", type text}}),
  #"Columnas con nombre cambiado 4" = Table.RenameColumns(#"Tipo de columna cambiado 4", {{"Personalizado", "CodigoSociedad"}}),
  #"Primeros caracteres insertados 1" = Table.AddColumn(#"Columnas con nombre cambiado 4", "Primeros caracteres", each Text.Start(Text.From([Año_mes]), 4), type text),
  #"Columnas con nombre cambiado 5" = Table.RenameColumns(#"Primeros caracteres insertados 1", {{"Primeros caracteres", "Año"}})

in
    #"Columnas con nombre cambiado 5";
shared #"FORECASTS y BUDGET_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "200", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Presupuestos", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
