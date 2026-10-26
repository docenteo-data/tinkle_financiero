[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Carga historica revenues_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"Carga historica revenues" = let
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
  Navegación = #"Navigation 4"{[Name = "Arranque"]}[Content],
  #"Navegación 1" = Navegación{[Name = "Revenue 2026 FT3.xlsx"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(#"Navegación 1", null, true),
  #"Filas filtradas" = Table.SelectRows(#"Libro de Excel importado", each Text.Contains([Name], "Revenue by")),
  #"Filas filtradas 1" = Table.SelectRows(#"Filas filtradas", each ([Name] <> "Revenue by client FT3 2026")),
  #"Data expandido" = Table.ExpandTableColumn(#"Filas filtradas 1", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22", "Column23", "Column24", "Column25", "Column26", "Column27"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22", "Column23", "Column24", "Column25", "Column26", "Column27"}),
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Data expandido", [PromoteAllScalars = true]),
  #"Filas filtradas 2" = Table.SelectRows(#"Encabezados promovidos", each ([Compañía] = null or [Compañía] = "ES TINKLE COMMUNICATIONS" or [Compañía] = "ES TINKLE CONSULTANTS" or [Compañía] = "ES TINKLE EUROPEAN" or [Compañía] = "ES TINKLE JAZZ" or [Compañía] = "ES TINKLE ONION") and ([Nombre Cliente] <> null and [Nombre Cliente] <> "#N/A" and [Nombre Cliente] <> "#N/D")),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Filas filtradas 2", {{"Revenue by client B1 2025 ", "Origen"}}),
  #"Elegir columnas" = Table.SelectColumns(#"Columnas con nombre cambiado", {"Origen", "Compañía", "Nombre Cliente", "Cliente", "enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre", "Compañía Magnitude", "Codigo MMS", "Code Magnitude", "Empresa", "Nombre MMS", "Codigo cliente Magnitude"}),
  #"Valor reemplazado" = Table.ReplaceValue(#"Elegir columnas", "", null, Replacer.ReplaceValue, {"Origen", "Compañía", "Nombre Cliente", "Cliente", "enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre", "Compañía Magnitude", "Codigo MMS", "Code Magnitude", "Empresa", "Nombre MMS", "Codigo cliente Magnitude"}),
  #"Rellenado hacia abajo" = Table.FillDown(#"Valor reemplazado", {"Compañía"}),
  #"Columnas con dinamización anulada" = Table.UnpivotOtherColumns(#"Rellenado hacia abajo", {"Origen", "Compañía", "Nombre Cliente", "Cliente", "Compañía Magnitude", "Codigo MMS", "Code Magnitude", "Empresa", "Nombre MMS", "Codigo cliente Magnitude"}, "Atributo", "Valor"),
  #"Columnas con nombre cambiado 1" = Table.RenameColumns(#"Columnas con dinamización anulada", {{"Atributo", "Mes"}}),
  #"Últimos caracteres insertados 1" = Table.AddColumn(#"Columnas con nombre cambiado 1", "Año", each Text.End([Origen], 5), type text),
  #"Texto recortado 1" = Table.TransformColumns(#"Últimos caracteres insertados 1", {{"Año", each Text.Trim(_), type text}}),
  #"Columnas reordenadas" = Table.ReorderColumns(#"Texto recortado 1", {"Origen", "Compañía", "Nombre Cliente", "Cliente", "Compañía Magnitude", "Codigo MMS", "Code Magnitude", "Empresa", "Nombre MMS", "Codigo cliente Magnitude", "Año", "Mes", "Valor"}),
  #"Consulta anexada" = Table.Combine({#"Columnas reordenadas", #"Revenue by client FT3 2026"}),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Consulta anexada", {{"Origen", type text}, {"Compañía", type text}, {"Nombre Cliente", type text}, {"Cliente", type text}, {"Compañía Magnitude", type text}, {"Codigo MMS", type text}, {"Code Magnitude", type text}, {"Empresa", type text}, {"Nombre MMS", type text}, {"Codigo cliente Magnitude", type text}, {"Año", type text}, {"Mes", type text}, {"Valor", type number}})

in
    #"Tipo de columna cambiado";
shared #"Revenue by client FT3 2026" = let
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
  Navegación = #"Navigation 4"{[Name = "Arranque"]}[Content],
  #"Navegación 1" = Navegación{[Name = "Revenue 2026 FT3.xlsx"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(#"Navegación 1", null, true),
  #"Filas filtradas 1" = Table.SelectRows(#"Libro de Excel importado", each ([Name] = "Revenue by client FT3 2026")),
  #"Data expandido" = Table.ExpandTableColumn(#"Filas filtradas 1", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22", "Column23", "Column24", "Column25", "Column26", "Column27"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22", "Column23", "Column24", "Column25", "Column26", "Column27"}),
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Data expandido", [PromoteAllScalars = true]),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Encabezados promovidos", {{"Revenue by client FT3 2026", "Origen"}}),
  #"Elegir columnas" = Table.SelectColumns(#"Columnas con nombre cambiado", {"Origen", "Compañía", "Nombre Cliente", "Cliente", "enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre", "Compañía Magnitude", "Codigo MMS", "Code Magnitude", "Empresa"}),
  #"Valor reemplazado" = Table.ReplaceValue(#"Elegir columnas", "", null, Replacer.ReplaceValue, {"Origen", "Compañía", "Nombre Cliente", "Cliente", "enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre", "Compañía Magnitude", "Codigo MMS", "Code Magnitude", "Empresa"}),
  #"Rellenado hacia abajo" = Table.FillDown(#"Valor reemplazado", {"Compañía"}),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Rellenado hacia abajo", {{"enero", type number}, {"febrero", type number}, {"marzo", type number}, {"abril", type number}, {"mayo", type number}, {"junio", type number}, {"julio", type number}, {"agosto", type number}, {"septiembre", type number}, {"octubre", type number}, {"noviembre", type number}, {"diciembre", type number}}),
  #"Errores reemplazados" = Table.ReplaceErrorValues(#"Tipo de columna cambiado 1", {{"enero", null}, {"febrero", null}, {"marzo", null}, {"abril", null}, {"mayo", null}, {"junio", null}, {"julio", null}, {"agosto", null}, {"septiembre", null}, {"octubre", null}, {"noviembre", null}, {"diciembre", null}}),
  #"Columnas con dinamización anulada" = Table.UnpivotOtherColumns(#"Errores reemplazados", {"Origen", "Compañía", "Nombre Cliente", "Cliente", "Compañía Magnitude", "Codigo MMS", "Code Magnitude", "Empresa"}, "Atributo", "Valor"),
  #"Columnas con nombre cambiado 1" = Table.RenameColumns(#"Columnas con dinamización anulada", {{"Atributo", "Mes"}}),
  #"Últimos caracteres insertados 1" = Table.AddColumn(#"Columnas con nombre cambiado 1", "Año", each Text.End([Origen], 5), type text),
  #"Texto recortado 1" = Table.TransformColumns(#"Últimos caracteres insertados 1", {{"Año", each Text.Trim(_), type text}}),
  #"Columnas reordenadas" = Table.ReorderColumns(#"Texto recortado 1", {"Origen", "Compañía", "Nombre Cliente", "Cliente", "Compañía Magnitude", "Codigo MMS", "Code Magnitude", "Empresa",
"Año", "Mes", "Valor"}),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Columnas reordenadas", {{"Mes", type text}, {"Año", type text}, {"Empresa", type text}, {"Code Magnitude", type text}, {"Codigo MMS", type text}, {"Compañía Magnitude", type text}, {"Cliente", type text}, {"Nombre Cliente", type text}, {"Compañía", type text}, {"Origen", type text}, {"Valor", type number}})

in
    #"Tipo de columna cambiado";
shared #"Carga historica revenues_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "200", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Revenues", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
