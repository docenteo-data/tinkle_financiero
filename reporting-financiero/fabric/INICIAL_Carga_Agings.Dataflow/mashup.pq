[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Carga Aging Clientes historico_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"Carga Aging Clientes historico" = let
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
  #"Navigation 6" = #"Navigation 5"{[Name = "2026 03 31- AGING Clientes Grupo Tinkle TOTAL HMES.xlsx"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(#"Navigation 6", null, true),
  #"Navigation 7" = #"Imported Excel workbook"{[Item = "DATOS", Kind = "Sheet"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 7", {{"Column1", type text}, {"Column2", type text}, {"Column3", type text}, {"Column4", type text}, {"Column5", type text}, {"Column7", type text}, {"Column8", type text}, {"Column9", type text}, {"Column14", type text}, {"Column15", type text}, {"Column18", type text}}),
  #"Promoted headers" = Table.PromoteHeaders(#"Changed column type", [PromoteAllScalars = true]),
  #"Choose columns" = Table.SelectColumns(#"Promoted headers", {"Proveedor", "Cobrador", "Interno", "Nombre Cliente", "Pais", "Nº Factura", "F. Envío  Presup.  Medio  Producto  F. Ins.", "NIF", "Tipo Factura", "F.Factura", "F. Vto.", "Imp, Factura", "S, Pendiente"}),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Choose columns", {{"Nº Factura", type text}, {"F.Factura", type date}, {"F. Vto.", type date}, {"Imp, Factura", type number}, {"S, Pendiente", type number}}),
  #"Renamed columns" = Table.RenameColumns(#"Changed column type 1", {{"Imp, Factura", "Imp_Factura"}, {"S, Pendiente", "S_Pendiente"}})

in
    #"Renamed columns";
shared #"Carga Aging Clientes historico_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "200", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Aging_Clientes", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Carga Aging Proveedores historico_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"Carga Aging Proveedores historico" = let
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
  #"Navigation 6" = #"Navigation 5"{[Name = "2026 03 31(01) Cartera Prov - TOTAL.xlsx"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(#"Navigation 6", null, true),
  #"Navigation 7" = #"Imported Excel workbook"{[Item = "Datos", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(#"Navigation 7", [PromoteAllScalars = true]),
  #"Filtered rows" = Table.SelectRows(#"Promoted headers", each ([Compañía] <> null)),
  #"Replaced value" = Table.ReplaceValue(#"Filtered rows", "", null, Replacer.ReplaceValue, {"Proveedor", "CIF Proveedor", "Nº Factura", "Fecha Factura", "Fecha Vencimiento", "Fecha Contable", "Medio", "Moneda", "Método", "IBAN", "Imp. Factura (Sum)", "Imp. Pendiente (Sum)", "Imp. Vencido (Sum)"}),
  #"Choose columns" = Table.SelectColumns(#"Replaced value", {"Compañía", "Cod. Proveedor", "Proveedor", "CIF Proveedor", "Nº Factura", "Fecha Factura", "Fecha Vencimiento", "Fecha Contable", "Medio", "Moneda", "Método", "IBAN", "Imp. Factura (Sum)", "Imp. Pendiente (Sum)", "Imp. Vencido (Sum)"}),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Choose columns", {{"Compañía", type text}, {"Cod. Proveedor", type text}, {"Proveedor", type text}, {"CIF Proveedor", type text}, {"Nº Factura", type text}, {"Fecha Factura", type date}, {"Fecha Vencimiento", type date}, {"Fecha Contable", type date}, {"Imp. Vencido (Sum)", type number}, {"Imp. Pendiente (Sum)", type number}, {"Imp. Factura (Sum)", type number}, {"Medio", type text}, {"Moneda", type text}, {"Método", type text}, {"IBAN", type text}}),
  #"Renamed columns" = Table.RenameColumns(#"Changed column type 1", {{"Imp. Factura (Sum)", "Imp_Factura"}, {"Imp. Pendiente (Sum)", "Imp_Pendiente"}, {"Imp. Vencido (Sum)", "Imp_Vencido"}})

in
    #"Renamed columns";
shared #"Carga Aging Proveedores historico_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "200", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Aging_Proveedores", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
