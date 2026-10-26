[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared Oracle_historico = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "200.Oracle_historico", ItemKind = "Table"]}[Data],
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Navigation 2", "Origen_actuals", each "ORACLE"), {{"Origen_actuals", type text}}),
  #"Renamed columns" = Table.RenameColumns(#"Added custom", {{"Compañía", "Sociedad"}, {"Fecha Contable", "Fecha"}}),
  #"Renamed columns 1" = Table.RenameColumns(#"Renamed columns", {{"Cuenta", "Cuenta_origen"}, {"Des. Cuenta", "Descripcion"}, {"Total", "Saldo"}}),
  #"Added custom 1" = Table.TransformColumnTypes(Table.AddColumn(#"Renamed columns 1", "Periodo", each Date.StartOfMonth([Fecha])), {{"Periodo", type date}}),
     #"Choose columns" =
        Table.SelectColumns(#"Added custom 1", {"Sociedad", "Cuenta_origen", "Descripcion", "Cliente", "Intercía", "Fecha", "Num. Tercero", "Nom. Tercero", "Debe", "Haber", "Saldo", "Categoria", "Num & Nom Tercero_", "Origen_actuals", "Periodo"})
in
  #"Choose columns";
shared HAPA = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "200.HAPA", ItemKind = "Table"]}[Data],
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Navigation 2", "Origen_actuals", each "HAPA"), {{"Origen_actuals", type text}}),
  #"Renamed columns" = Table.RenameColumns(#"Added custom", {{"Nombre empresa", "Sociedad"}, {"Fecha asiento", "Periodo"}, {"Código cuenta", "Cuenta_origen"}, {"Cuenta", "Descripcion"}}),
  #"Choose columns" = Table.SelectColumns(#"Renamed columns", {
                "Sociedad",
                "Cuenta_origen",
                "Descripcion",
                "Fecha",
                "Periodo",
                "Debe",
                "Haber",
                "Saldo",
                "Origen_actuals"
            })
in
  #"Choose columns";
shared Portugal = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "200.Portugal", ItemKind = "Table"]}[Data],
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Navigation 2", "Origen_actuals", each "PT"), {{"Origen_actuals", type text}}),
  #"Renamed columns" = Table.RenameColumns(#"Added custom", {{"Sociedade", "Sociedad"}, {"Data", "Fecha"}, {"Descrição", "Descripcion"}, {"Débito", "Debe"}, {"Crédito", "Haber"}}),
  #"Extracted text between delimiters" = Table.TransformColumns(#"Renamed columns", {{"Conta Header", each Text.BetweenDelimiters(_, "Conta : ", " -", 0, 0), type text}}),
  #"Inserted conditional column" = Table.AddColumn(#"Extracted text between delimiters", "Cuenta_origen", each if [Conta] = null then [Conta Header] else [Conta]),
  #"Changed column type" = Table.TransformColumnTypes(#"Inserted conditional column", {{"Cuenta_origen", type text}, {"Conta", type text}}),
  #"Choose columns" = Table.SelectColumns(#"Changed column type", {
                "Sociedad",
                "Cuenta_origen",
                "Descripcion",
                "Fecha",
                "Periodo",
                "Debe",
                "Haber",
                "Saldo",
                "Origen_actuals"
            })
in
  #"Choose columns";
shared #"200_Mapping Portugal" = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "200.Mapping Portugal", ItemKind = "Table"]}[Data],
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Navigation 2", "Origen_map", each "PT"), {{"Origen_map", type text}}),
  #"Changed column type" = Table.TransformColumnTypes(#"Added custom", {{"Conta", type text}}),
  #"Renamed columns" = Table.RenameColumns(#"Changed column type", {{"Descrição", "Descripcion"}, {"Mapeo summary", "Descripcion_magnitud"}, {"Mapeo Magnitude", "Cuenta_magnitude"}, {"Conta", "Cuenta"}}),
  #"Trimmed text" = Table.TransformColumns(#"Renamed columns", {{"Descripcion_magnitud", each Text.Trim(_), type nullable text}})
in
  #"Trimmed text";
shared #"200_Mapping_HAPA" = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "200.Mapping_HAPA", ItemKind = "Table"]}[Data],
  #"Renamed columns" = Table.RenameColumns(#"Navigation 2", {{"Descripción", "Descripcion"}, {"Mapeo Magnitude", "Cuenta_magnitude"}}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Renamed columns", "Origen_map", each "HAPA"), {{"Origen_map", type text}}),
  #"Renamed columns 1" = Table.RenameColumns(#"Added custom", {{"Descripción Magnitude", "Descripcion_magnitud"}})
in
  #"Renamed columns 1";
shared #"200_COA_Oracle" = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "200.COA_Oracle", ItemKind = "Table"]}[Data],
  #"Renamed columns" = Table.RenameColumns(#"Navigation 2", {{"SAP-ACCOUNT", "Cuenta_magnitude"}}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Renamed columns", "Origen_map", each "ORACLE"), {{"Origen_map", type text}}),
  #"Renamed columns 1" = Table.RenameColumns(#"Added custom", {{"ORACLE-DESCRIPCION", "Descripcion"}, {"ORACLE-CUENTA", "Cuenta"}}),
  #"Renamed columns 2" = Table.RenameColumns(#"Renamed columns 1", {{"SAP-DESCRIPTION", "Descripcion_magnitud"}})
in
  #"Renamed columns 2";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Dim_mapeo_cuentas_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Dim_mapeo_cuentas = let
  Source = #"200_Mapping Portugal",
  #"Appended query" = Table.Combine({Source, #"200_COA_Oracle", #"200_Mapping_HAPA", #"200_Mapping Portugal"}),
  #"Choose columns" = Table.SelectColumns(#"Appended query", {"Cuenta", "Descripcion", "Cuenta_magnitude", "Origen_map"}),
  #"Renamed columns" = Table.RenameColumns(#"Choose columns", {{"Cuenta", "Cuenta_origen"}}),
  #"Inserted merged column" = Table.AddColumn(#"Renamed columns", "ID_Account", each Text.Combine({[Origen_map], [Cuenta_origen]}, "-"), type text),
  #"Removed duplicates" = Table.Distinct(#"Inserted merged column")
in
  #"Removed duplicates";
shared Fact_Actuals_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "300", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Fact_Actuals", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Dim_Cuentas_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Dim_Cuentas = let
  Source = #"200_Mapping Portugal",
  #"Appended query" = Table.Combine({Source, #"200_COA_Oracle", #"200_Mapping_HAPA", #"200_Mapping Portugal"}),
  #"Filtered rows" = Table.SelectRows(#"Appended query", each [Origen_map] = "ORACLE"),
  #"Inserted merged column" = Table.AddColumn(#"Filtered rows", "ID_Account", each Text.Combine({[Origen_map], [Cuenta]}, "-"), type text),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Inserted merged column", "Cuenta & descr. (magnitud)", each [Cuenta_magnitude] & " - " & [Descripcion_magnitud]), {{"Cuenta & descr. (magnitud)", type text}}),
  #"Added custom 1" = Table.TransformColumnTypes(Table.AddColumn(#"Added custom", "Cuenta & Descripción", each [Cuenta] & " - " & [Descripcion]), {{"Cuenta & Descripción", type text}})
in
  #"Added custom 1";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Fact_Actuals_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Fact_Actuals = let
    TiposEntrada = {
        {"Sociedad", type text},
        {"Cuenta_origen", type text},
        {"Descripcion", type text},
        {"Debe", type number},
        {"Haber", type number},
        {"Saldo", type number},
        {"Origen_actuals", type text}
    },

    Oracle_Normalizado =
        Table.TransformColumnTypes(
            Oracle_historico,
            TiposEntrada,
            [
                Culture = "es-ES",
                MissingField = MissingField.Ignore
            ]
        ),

    HAPA_Normalizado =
        Table.TransformColumnTypes(
            HAPA,
            TiposEntrada,
            [
                Culture = "es-ES",
                MissingField = MissingField.Ignore
            ]
        ),

    Portugal_Normalizado =
        Table.TransformColumnTypes(
            Portugal,
            TiposEntrada,
            [
                Culture = "es-ES",
                MissingField = MissingField.Ignore
            ]
        ),

    Source =
        Table.Combine({
            Oracle_Normalizado,
            HAPA_Normalizado,
            Portugal_Normalizado
        }),

    #"Fecha original" =
        Table.DuplicateColumn(
            Source,
            "Fecha",
            "Fecha_Original"
        ),

    #"Periodo original" =
        Table.DuplicateColumn(
            #"Fecha original",
            "Periodo",
            "Periodo_Original"
        ),

    #"Fecha segura" =
        Table.TransformColumns(
            #"Periodo original",
            {
                {
                    "Fecha",
                    each
                        if _ = null then
                            null
                        else
                            try Date.From(_)
                            otherwise try Date.FromText(Text.Trim(Text.From(_)))
                            otherwise null,
                    type date
                }
            }
        ),

    #"Periodo seguro" =
        Table.RemoveColumns(
            #"Fecha segura",
            {"Periodo"}
        ),

    #"Added Periodo" =
        Table.AddColumn(
            #"Periodo seguro",
            "Periodo",
            each
                if [Fecha] = null then
                    null
                else
                    Date.StartOfMonth([Fecha]),
            type date
        ),
  #"Inserted merged column" = Table.AddColumn(#"Added Periodo", "ID_Account", each Text.Combine({[Origen_actuals], [Cuenta_origen]}, "-"), type text),
  #"Columna condicional insertada" = Table.AddColumn(#"Inserted merged column", "CodigoSociedad", each if Text.Contains([Sociedad], "CONS") then "CONS" else if Text.Contains([Sociedad], "COMM") then "COMM" else if Text.Contains([Sociedad], "JAZZ") then "JAZZ" else if Text.Contains([Sociedad], "EURO") then "EURO" else if Text.Contains([Sociedad], "ONION") then "ONION" else null),

    #"Final types" =
        Table.TransformColumnTypes(#"Columna condicional insertada", {{"Sociedad", type text}, {"Cuenta_origen", type text}, {"Descripcion", type text}, {"Debe", type number}, {"Haber", type number}, {"Saldo", type number}, {"Origen_actuals", type text}, {"Fecha_Original", type text}, {"Periodo_Original", type text}, {"CodigoSociedad", type text}}),
  #"Personalizado agregado" = Table.TransformColumnTypes(Table.AddColumn(#"Final types", "ClienteKey_Oracle", each [Cliente] & "-" & [CodigoSociedad]), {{"ClienteKey_Oracle", type text}})
in
    #"Personalizado agregado";
shared Dim_mapeo_cuentas_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "300", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Dim_Mapeo_Cuentas", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Dim_Cuentas_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "300", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Dim_Cuentas", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
