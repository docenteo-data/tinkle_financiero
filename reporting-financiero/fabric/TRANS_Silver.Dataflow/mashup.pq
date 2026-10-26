[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Replace"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared DefaultDestination = Lakehouse.Contents([EnableFolding = false]){[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data]{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data];
shared #"200_New_MMS_trans" = let
    Source = Lakehouse.Contents(null),
    Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
    #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
    #"Navigation 2" = #"Navigation 1"{[Id = "100.New_MMS", ItemKind = "Table"]}[Data],

    #"Added custom" = Table.AddColumn(
        #"Navigation 2",
        "IMPORTE",
        each [Neto Venta _Sum_] - [Neto Compra _Sum_],
        type number
    ),

    #"Added Categoria" = Table.AddColumn(
        #"Added custom",
        "CATEGORIA",
        each
            if Text.Contains(Text.Upper(Text.From([Soporte])), "FEE") then
                "Honorarios"
            else if Text.Contains(Text.From([Soporte]), "Servicios (0)") then
                "Servicios"
            else
                "Produccion",
        type text
    ),

    #"Added CodigoSociedad" = Table.AddColumn(
        #"Added Categoria",
        "CodigoSociedad",
        each
            if Text.Contains([Compañia], "CONS") then
                "CONS"
            else if Text.Contains([Compañia], "COMM") then
                "COMM"
            else if Text.Contains([Compañia], "JAZZ") then
                "JAZZ"
            else if Text.Contains([Compañia], "EURO") then
                "EURO"
            else if Text.Contains([Compañia], "ONION") then
                "ONION"
            else
                null,
        type text
    ),

    #"Added ClienteKey_MMS" = Table.TransformColumnTypes(
        Table.AddColumn(
            #"Added CodigoSociedad",
            "ClienteKey_MMS",
            each Text.From([Cod. Cliente]) & "-" & [CodigoSociedad]
        ),
        {{"ClienteKey_MMS", type text}}
    ),

    #"Inserted CUENTA" = Table.AddColumn(
        #"Added ClienteKey_MMS",
        "CUENTA",
        each if [Neto Compra _Sum_] = 0 then "Venta" else "Compra",
        type text
    ),

    #"Added Comprob" = Table.AddColumn(
        #"Inserted CUENTA",
        "comprob.",
        each
            if [Neto Compra _Sum_] <> 0 and [Neto Venta _Sum_] <> 0 then
                "CompraVenta"
            else
                "OK",
        type text
    ),

    #"Added Ejercicio" = Table.TransformColumnTypes(
        Table.AddColumn(
            #"Added Comprob",
            "Ejercicio",
            each [Año]
        ),
        {{"Ejercicio", Int64.Type}}
    ),

    #"Added NUMMES" = Table.TransformColumnTypes(
        Table.AddColumn(
            #"Added Ejercicio",
            "NUMMES",
            each
                let
                    MesTexto = Text.Lower(Text.Trim(Text.From([Mes])))
                in
                    if MesTexto = "enero" then "01"
                    else if MesTexto = "febrero" then "02"
                    else if MesTexto = "marzo" then "03"
                    else if MesTexto = "abril" then "04"
                    else if MesTexto = "mayo" then "05"
                    else if MesTexto = "junio" then "06"
                    else if MesTexto = "julio" then "07"
                    else if MesTexto = "agosto" then "08"
                    else if MesTexto = "septiembre" then "09"
                    else if MesTexto = "octubre" then "10"
                    else if MesTexto = "noviembre" then "11"
                    else if MesTexto = "diciembre" then "12"
                    else null
        ),
        {{"NUMMES", type text}}
    ),

    #"Added PERIODO" = Table.TransformColumnTypes(
        Table.AddColumn(
            #"Added NUMMES",
            "PERIODO",
            each Text.From([Año]) & Text.PadStart(Text.From([NUMMES]), 2, "0")
        ),
        {{"PERIODO", Int64.Type}}
    ),

    #"Changed column type" = Table.TransformColumnTypes(
        #"Added PERIODO",
        {{"Cod. Cliente", type text}}
    )
in
    #"Changed column type";
shared #"200_MMS_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "200", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "MMS", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared #"200_Portugal_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "200", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Portugal", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared #"200_New_Oracle_trans" = let
    Source = Lakehouse.Contents(null),
    Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
    #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
    #"Navigation 2" = #"Navigation 1"{[Id = "100.New_Oracle", ItemKind = "Table"]}[Data],

    // Función segura para interpretar fechas.
    // Mantiene las fechas válidas y controla textos como 31/12/2025.
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
                ParsedES = try Date.FromText(TextValue, [Culture = "es-ES"]),
                ParsedFallback =
                    if ParsedES[HasError]
                    then try Date.From(value)
                    else ParsedES
            in
                if TextValue = "" then
                    null
                else if ParsedFallback[HasError] then
                    null
                else
                    ParsedFallback[Value],

    // Control específico de las dos columnas de fecha
    #"Controlled dates" =
        Table.TransformColumns(
            #"Navigation 2",
            {
                {"Fecha Contable", each ParseDate(_), type date},
                {"Fecha Factura", each ParseDate(_), type date}
            },
            null,
            MissingField.Ignore
        ),

    #"Inserted conditional column" =
        Table.AddColumn(
            #"Controlled dates",
            "Divisa Reporting",
            each if [Divisa] = "STAT" then "STAT" else "EUR"
        ),

    #"Inserted conditional column 1" =
        Table.AddColumn(
            #"Inserted conditional column",
            "Categoria",
            each
                if [Cuenta] = "" then ""
                else if [Cuenta] = "X600000" then "Produccion"
                else if [Cuenta] = "X700000" then "Produccion"
                else if [Cuenta] = "X705000" then "Honorarios"
                else "Otros"
        ),

    #"Added custom" =
        Table.TransformColumnTypes(
            Table.AddColumn(
                #"Inserted conditional column 1",
                "RevAmount",
                each [#"Total"] * -1
            ),
            {{"RevAmount", Currency.Type}}
        ),

    #"Added Sociedad Reporting" =
        Table.TransformColumnTypes(
            Table.AddColumn(
                #"Added custom",
                "Interco",
                each
                    if [#"Num. Tercero"] = 16710 then "EURO"
                    else if [#"Num. Tercero"] = 40201 then "EURO"
                    else if [#"Num. Tercero"] = 17454 then "COMM"
                    else if [#"Num. Tercero"] = 36527 then "COMM"
                    else if [#"Num. Tercero"] = 11039 then "CONS"
                    else if [#"Num. Tercero"] = 22164 then "CONS"
                    else if [#"Num. Tercero"] = 19291 then "ONION"
                    else if [#"Num. Tercero"] = 40230 then "ONION"
                    else if [#"Num. Tercero"] = 19268 then "JAZZ"
                    else if [#"Num. Tercero"] = 40191 then "JAZZ"
                    else if [#"Num. Tercero"] = 16044 then "PORT"
                    else if [#"Num. Tercero"] = 19320 then "PORT"
                    else if [#"Num. Tercero"] = 40617 then "PORT"
                    else "VARIOS"
            ),
            {{"Interco", type text}}
        ),

    #"Added Mes" =
        Table.AddColumn(
            #"Added Sociedad Reporting",
            "Mes",
            each
                if [Fecha Contable] = null then
                    null
                else
                    Date.ToText([Fecha Contable], "MM"),
            type text
        ),

    #"Added custom 1" =
        Table.TransformColumnTypes(
            Table.AddColumn(
                #"Added Mes",
                "Num & Nom Tercero ",
                each [Num. Tercero] & " - " & [Nom. Tercero]
            ),
            {{"Num & Nom Tercero ", type text}}
        ),

    #"Added custom 2" =
        Table.TransformColumnTypes(
            Table.AddColumn(
                #"Added custom 1",
                "Cuenta & Descripción",
                each [Cuenta] & " - " & [Des. Cuenta]
            ),
            {{"Cuenta & Descripción", type text}}
        ),

    #"Changed column type" =
        Table.TransformColumnTypes(
            #"Added custom 2",
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
                {"Fecha Contable", type date},
                {"Descripción Linea", type text},
                {"Concepto Pedido", type text},
                {"Año Factura", type text},
                {"Mes Factura", type text},
                {"Fecha Factura", type date},
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
                {"Debe", Currency.Type},
                {"Haber", Currency.Type},
                {"Total", Currency.Type},
                {"RevAmount", Currency.Type},
                {"Interco", type text},
                {"Mes", type text}
            }
        )
in
    #"Changed column type";
shared #"200_New_HAPA_trans" = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "100.New_HAPA", ItemKind = "Table"]}[Data],
  #"Removed columns" = Table.RemoveColumns(#"Navigation 2", {"Tipo documento", "Documento", "Número página", "Debe_1", "Haber_2", "Arrastra Debe", "Arrastra Haber", "Texto pié informe", "Total asiento", "Total mes", "Total día", "Imprimir sumas anteriores", "Flag final", "Cód. delegación", "Importe divisa", "Cód. divisa", "Importe cambio", "Cód. proyecto", "Cód. departamento", "Cód. sección", "Serie factura"}),
  #"Added custom" = Table.AddColumn(#"Removed columns", "Saldo", each [Debe] - [Haber]),
  #"Changed column type" = Table.TransformColumnTypes(#"Added custom", {{"Saldo", Currency.Type}, {"Código cuenta", type text}})
in
  #"Changed column type";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "200_New_Agings_Proveedores_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "Compañía", DestinationColumnName = "Compañía"], [SourceColumnName = "Cod. Proveedor", DestinationColumnName = "Cod. Proveedor"], [SourceColumnName = "Proveedor", DestinationColumnName = "Proveedor"], [SourceColumnName = "CIF Proveedor", DestinationColumnName = "CIF Proveedor"], [SourceColumnName = "Nº Factura", DestinationColumnName = "Nº Factura"], [SourceColumnName = "Fecha Factura", DestinationColumnName = "Fecha Factura"], [SourceColumnName = "Fecha Vencimiento", DestinationColumnName = "Fecha Vencimiento"], [SourceColumnName = "Fecha Contable", DestinationColumnName = "Fecha Contable"], [SourceColumnName = "Medio", DestinationColumnName = "Medio"], [SourceColumnName = "Moneda", DestinationColumnName = "Moneda"], [SourceColumnName = "Método", DestinationColumnName = "Método"], [SourceColumnName = "IBAN", DestinationColumnName = "IBAN"], [SourceColumnName = "Imp_Factura", DestinationColumnName = "Imp_Factura"], [SourceColumnName = "Imp_Pendiente", DestinationColumnName = "Imp_Pendiente"], [SourceColumnName = "Imp_Vencido", DestinationColumnName = "Imp_Vencido"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared #"200_New_Agings_Proveedores" = let
    Source = Lakehouse.Contents(null),
    Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
    #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "100.New_Agings_Proveedores", ItemKind = "Table"]}[Data],
  #"Removed duplicates" = Table.Distinct(#"Navigation 2", {"Compañía", "Cod. Proveedor", "Proveedor", "CIF Proveedor", "Nº Factura", "Fecha Factura", "Fecha Vencimiento", "Fecha Contable", "Medio", "Moneda", "Método", "IBAN", "Imp_Factura", "Imp_Pendiente", "Imp_Vencido"})
in
    #"Removed duplicates";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "200_New_Agings_Clientes_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "Proveedor", DestinationColumnName = "Proveedor"], [SourceColumnName = "Cobrador", DestinationColumnName = "Cobrador"], [SourceColumnName = "Interno", DestinationColumnName = "Interno"], [SourceColumnName = "Nombre Cliente", DestinationColumnName = "Nombre Cliente"], [SourceColumnName = "Pais", DestinationColumnName = "Pais"], [SourceColumnName = "Nº Factura", DestinationColumnName = "Nº Factura"], [SourceColumnName = "F. Envío  Presup.  Medio  Producto  F. Ins.", DestinationColumnName = "F. Envío  Presup.  Medio  Producto  F. Ins."], [SourceColumnName = "NIF", DestinationColumnName = "NIF"], [SourceColumnName = "Tipo Factura", DestinationColumnName = "Tipo Factura"], [SourceColumnName = "F.Factura", DestinationColumnName = "F.Factura"], [SourceColumnName = "F. Vto.", DestinationColumnName = "F. Vto."], [SourceColumnName = "Imp_Factura", DestinationColumnName = "Imp_Factura"], [SourceColumnName = "S_Pendiente", DestinationColumnName = "S_Pendiente"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared #"200_New_Agings_Clientes" = let
    Source = Lakehouse.Contents(null),
    Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
    #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "100.New_Agings_Clientes", ItemKind = "Table"]}[Data],
  #"Removed duplicates" = Table.Distinct(#"Navigation 2", {"Proveedor", "Cobrador", "Interno", "Nombre Cliente", "Pais", "Nº Factura", "F. Envío  Presup.  Medio  Producto  F. Ins.", "NIF", "Tipo Factura", "F.Factura", "F. Vto.", "Imp_Factura", "S_Pendiente"})
in
    #"Removed duplicates";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "200_Portugal_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"200_Portugal_trans" = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "100.New_PT_extrato_contas", ItemKind = "Table"]}[Data],
  #"Renamed columns" = Table.RenameColumns(#"Navigation 2", {{"Conta Origem", "Conta"}}),
  #"Replaced value" = Table.ReplaceValue(#"Renamed columns", null, 0, Replacer.ReplaceValue, {"Débito", "Crédito", "Saldo"}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Replaced value", "IMPORTE", each [Débito] - [Crédito]), {{"IMPORTE", Currency.Type}}),
  #"Added custom 1" = Table.AddColumn(#"Added custom", "IMPORTE (miles)", each [IMPORTE] / 1000),
  #"Changed column type" = Table.TransformColumnTypes(#"Added custom 1", {{"IMPORTE (miles)", Currency.Type}, {"Saldo", Currency.Type}, {"Crédito", Currency.Type}, {"Débito", Currency.Type}, {"Conta", Int64.Type}})
in
  #"Changed column type";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "200_HAPA_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"200_HAPA" = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "200.HAPA", ItemKind = "Table"]}[Data],
  #"Filtered rows" = Table.SelectRows(#"Navigation 2", each [Fecha] < pFecha_New_HAPA),
  #"Appended query" = Table.Combine({#"Filtered rows", #"200_New_HAPA_trans"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Appended query", {{"Código cuenta", type text}})
in
  #"Changed column type";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "200_Oracle_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "Origen", DestinationColumnName = "Origen"], [SourceColumnName = "Org Id", DestinationColumnName = "Org Id"], [SourceColumnName = "Compañía", DestinationColumnName = "Compañía"], [SourceColumnName = "Flex Value Set Id CDC", DestinationColumnName = "Flex Value Set Id CDC"], [SourceColumnName = "Origen Usuario", DestinationColumnName = "Origen Usuario"], [SourceColumnName = "Estado", DestinationColumnName = "Estado"], [SourceColumnName = "Secuencia", DestinationColumnName = "Secuencia"], [SourceColumnName = "Cia", DestinationColumnName = "Cia"], [SourceColumnName = "Cod Compania MMS", DestinationColumnName = "Cod Compania MMS"], [SourceColumnName = "Cuenta", DestinationColumnName = "Cuenta"], [SourceColumnName = "Des. Cuenta", DestinationColumnName = "Des. Cuenta"], [SourceColumnName = "CDC", DestinationColumnName = "CDC"], [SourceColumnName = "Des. CDC", DestinationColumnName = "Des. CDC"], [SourceColumnName = "Cliente", DestinationColumnName = "Cliente"], [SourceColumnName = "Imputación", DestinationColumnName = "Imputación"], [SourceColumnName = "Intercía", DestinationColumnName = "Intercía"], [SourceColumnName = "Libre", DestinationColumnName = "Libre"], [SourceColumnName = "Fecha Contable", DestinationColumnName = "Fecha Contable"], [SourceColumnName = "Mes Contable", DestinationColumnName = "Mes Contable"], [SourceColumnName = "Nombre Lote", DestinationColumnName = "Nombre Lote"], [SourceColumnName = "Factura", DestinationColumnName = "Factura"], [SourceColumnName = "Asiento", DestinationColumnName = "Asiento"], [SourceColumnName = "Divisa", DestinationColumnName = "Divisa"], [SourceColumnName = "Num. Tercero", DestinationColumnName = "Num. Tercero"], [SourceColumnName = "Nom. Tercero", DestinationColumnName = "Nom. Tercero"], [SourceColumnName = "Num. Pedido", DestinationColumnName = "Num. Pedido"], [SourceColumnName = "NIF", DestinationColumnName = "NIF"], [SourceColumnName = "Fecha Factura", DestinationColumnName = "Fecha Factura"], [SourceColumnName = "Mes Factura", DestinationColumnName = "Mes Factura"], [SourceColumnName = "Año Factura", DestinationColumnName = "Año Factura"], [SourceColumnName = "Concepto Pedido", DestinationColumnName = "Concepto Pedido"], [SourceColumnName = "Descripción Linea", DestinationColumnName = "Descripción Linea"], [SourceColumnName = "Porcentaje Imputación", DestinationColumnName = "Porcentaje Imputación"], [SourceColumnName = "Debe", DestinationColumnName = "Debe"], [SourceColumnName = "Haber", DestinationColumnName = "Haber"], [SourceColumnName = "Total", DestinationColumnName = "Total"], [SourceColumnName = "Divisa Reporting", DestinationColumnName = "Divisa Reporting"], [SourceColumnName = "Categoria", DestinationColumnName = "Categoria"], [SourceColumnName = "RevAmount", DestinationColumnName = "RevAmount"], [SourceColumnName = "Interco", DestinationColumnName = "Interco"], [SourceColumnName = "Mes", DestinationColumnName = "Mes"], [SourceColumnName = "Num & Nom Tercero_", DestinationColumnName = "Num & Nom Tercero_"], [SourceColumnName = "Cuenta & Descripción", DestinationColumnName = "Cuenta & Descripción"], [SourceColumnName = "Fichero Origen", DestinationColumnName = "Fichero Origen"], [SourceColumnName = "ID_account", DestinationColumnName = "ID_account"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared #"200_Oracle" = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "200.Oracle_historico", ItemKind = "Table"]}[Data],
  #"Filtered rows" = Table.SelectRows(#"Navigation 2", each [Fecha Contable] < pFechaContable_New_Oracle),
  #"Appended query" = Table.Combine({#"Filtered rows", #"200_New_Oracle_trans"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Appended query", {{"Divisa Reporting", type text}, {"Categoria", type text}, {"Cuenta", type text}, {"Origen", type text}, {"Org Id", type text}, {"Compañía", type text}, {"Flex Value Set Id CDC", type text}, {"Origen Usuario", type text}, {"Estado", type text}, {"Secuencia", type text}, {"Cia", type text}, {"Cod Compania MMS", type text}, {"Des. Cuenta", type text}, {"CDC", type text}, {"Des. CDC", type text}, {"Cliente", type text}, {"Imputación", type text}, {"Intercía", type text}, {"Libre", type text}, {"Fecha Contable", type date}, {"Descripción Linea", type text}, {"Concepto Pedido", type text}, {"Año Factura", type text}, {"Mes Factura", type text}, {"Fecha Factura", type date}, {"NIF", type text}, {"Num. Pedido", type text}, {"Nom. Tercero", type text}, {"Num. Tercero", type text}, {"Divisa", type text}, {"Asiento", type text}, {"Factura", type text}, {"Nombre Lote", type text}, {"Mes Contable", type text}, {"Porcentaje Imputación", Int64.Type}, {"Debe", type number}, {"Haber", type number}, {"Total", type number}, {"RevAmount", type number}, {"Interco", type text}, {"Mes", type text}})
in
  #"Changed column type";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "200_MMS_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"200_MMS" = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navegación = #"Navigation 1"{[Id = "200.MMS", ItemKind = "Table"]}[Data],
  #"Consulta anexada" = Table.Combine({Navegación, #"200_New_MMS_trans"}),
  #"Duplicados quitados" = Table.Distinct(#"Consulta anexada", {"País", "Compañia", "Medio", "Cod. Proveedor", "Proveedor", "Nif. Empresa/Proveedor", "Pais Empresa Proveedor", "Grupo HVM Proveedor", "Editorial Comercial", "Status Editorial Comercial", "Agrupación Comercial", "Ind. Editorial ON\OFF", "Cod. Soporte", "Soporte", "Tipo Soporte", "Grupo Comunicación Soporte", "Grupo Soporte", "Exclusivista", "Grupo Negociación", "Grupo Negociación Táctica", "Ind. Auditado Grupo Negociación Táctica", "Grupo Soporte Comercial", "Fecha Baja Soporte", "Fecha Baja Proveedor-Soporte", "Delegación", "Cod. Grupo", "Grupo", "Grupo Principal", "Cod. Cliente", "Cliente", "Marca", "Producto", "Grupo Producto", "Empresa", "Nif. Empresa/Cliente", "Pais Empresa", "Grupo HVM", "Agencia", "Grupo Negocio", "Grupo Facturación", "Ind. Bloqueado", "Ind. Autorizado", "Ind. SAG por Separado", "Ind. Fee por Separado", "Ind. Fact. por Partes", "Ind. Ver Subcampana", "Ind. Nº Pedido", "Ind. Fact. Electrónica", "Ind. PDI Cliente", "Ind. PDI Producto", "Ind. Auditoría Financiera", "Campaña", "SubCampaña", "Alcance", "Centro de Coste", "Observaciones de Campaña", "Ind. Campana Interna", "Presupuesto", "Estado Presup.", "Nº Pedido", "F. Presupuesto", "F. Envío Presupuesto", "Ind. Presup. Autorizado", "Ind. Presup. con Factura", "Acuerdo", "Imp. Acuerdo", "F. Inicio Acuerdo", "F. Fin Acuerdo", "Tipo Presupuesto", "Serv. Agen. Pre.", "MNP Pre.", "SAG BC", "MNP BC", "Observaciones de Presupuesto", "Observaciones de Presupuesto Internas", "Oficina", "Clave Indicación Facturación", "Nº Pedido Servicio Agencia", "Observaciones Cabecera", "Observaciones Cabecera SAG", "Concepto Factura", "Concepto Factura SAG", "Orden", "F. Ejecución", "F. Grabación", "F. Confirmación", "Año", "Mes", "Día", "Día Semana", "Semana", "Quincena", "Estado Orden", "Material", "Descripción Material", "Contrato", "F. Contrato", "Observaciones Contrato", "Título anuncio", "Observaciones", "Observaciones 2", "Observaciones Factura", "MNP", "MNP Calculado", "Base Calculo MNP", "SAG", "Base Calculo SAG", "Divisa", "Origen Orden", "Nombre Usuario Orden", "Objetivo", "Tipo de Orden", "Tipo de Compra", "Tipo de Disciplina", "Grupo Disciplina", "Disciplina", "Ind. Acuerdo", "Tipo Acuerdo", "Ind. Acuerdo Intercambio", "Ind. Rappel", "Ind. Ajuste", "Ind. Intercompany", "Ind. Orden F", "Ind. Orden Facturable", "Tipo Publicidad", "Ind. Tipo Publicidad", "Ind. Auditoria Medio", "Tipo Orden Económico", "Tipo Orden Publicidad", "Tipo Orden Financiera", "Tipo Orden Acciones", "Tipo Orden Serv. Prod.", "Tipo Orden HVP", "Tipo Orden Herramienta-Estudio", "Tipologias", "Nº Factura Cli.", "Fecha Factura Cli.", "Tipo de Factura", "Fecha Grabación Factura Cli.", "Nº Pedido Factura", "Clave Status Factura", "Obs. Factura", "Obs. Internas Factura", "Obs. Cabecera Factura", "Fecha Envio Factura Cli.", "Fecha Cobro Factura Cli.", "Fecha Vto. Factura Cli.", "Ind. Fact. Anulada", "Nº Prefactura Cli.", "Fecha Prefactura Cli.", "Ref. Factura", "Ref. Orden", "Nº Factura SAG", "Nº Pedido Factura SAG", "Factura Proveedor", "Fecha Factura Prov.", "Fecha Vto. Factura Prov.", "Fecha Aceptación Factura Prov.", "Fecha Pago Factura Prov.", "Num. Factura del Proveedor", "Imp. Total Factura Proveedor", "Compañía Intercompany", "Cod. Campaña Intercompany", "Campaña Intercompany", "Ind. Presupuesto Intercompany", "Acuerdo Negocio", "Desc. Abrv. Acuerdo Negocio", "Grupo Acuerdo Negocio", "Tipo Acuerdo Cliente", "Forma Consumo", "Ind. Pago Consumo", "Cod. Ajuste", "Tipo de Ajuste", "Ind. Ajuste Aprobado", "Categoría de Ajuste", "Motivo de Ajuste", "Referencia de Ajuste", "Acción Ajuste", "Observaciones Ajuste", "Fecha Solicitud Ajuste", "Fecha Aprobación Ajuste", "Neto Compra _Sum_", "Neto Venta _Sum_", "IMPORTE", "CATEGORIA", "CUENTA", "comprob.", "Ejercicio", "NUMMES", "PERIODO"}),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Duplicados quitados", {{"CodigoSociedad", type text}})
in
  #"Tipo de columna cambiado";
shared pFechaContable_New_Oracle = let
  Source = #"200_New_Oracle_trans",
  #"Changed type" = Table.TransformColumnTypes(Source, {{"Fecha Contable", type date}}, "es-ES"),
   FechaMinima = List.Min(#"Changed type"[Fecha Contable])
in
    FechaMinima;
shared pFecha_New_HAPA = let
    Source = #"200_New_HAPA_trans",
    #"Changed type" = Table.TransformColumnTypes(Source, {{"Fecha", type date}}, "es-ES"),
    FechaMinima = List.Min(#"Changed type"[Fecha])
in
    FechaMinima;
shared #"200_HAPA_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[lakehouseName = "lh_tinkle_financiero"]}[Data],
  Navigation_3 = Navigation_2{[Id = "200", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "HAPA", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared #"200_Oracle_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "200", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Oracle_historico", ItemKind = "Table"]}[Data]
in
  TableNavigation;
shared #"200_New_Agings_Clientes_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "200", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Aging_Clientes", ItemKind = "Table"]}[Data]
in
  TableNavigation;
shared #"200_New_Agings_Proveedores_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "200", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Aging_Proveedores", ItemKind = "Table"]}[Data]
in
  TableNavigation;
