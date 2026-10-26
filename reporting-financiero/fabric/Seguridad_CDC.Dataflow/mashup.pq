[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "RLS_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared RLS = let
  Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("TY5LDsIgEIavQlgbzyClbozURpeNixFRiTgkPEzqnVx4hl5MwNC4mcX3z/8YBsoQgbTa2JEuKGvTocfFQHfmCuQQAUdIaHeovLxzp31QwWYHr4oAF4CwkzImWwSrwgaeWjnCowta3nzCm9nUqKudPkCEdQpzXiOq1EWn0wQwkC3dvGD9TC0IZdea/bVPbyC9ljlF9JXvrZzelnRx+qhXgvuuKluILuejvBVlOzcIi1oCacD70i2adB4FLk8FroLGu1FL5YuBG4jnMvZiMaRn/ss6fgE=", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [Usuario = _t, CDC = _t, eMail = _t])
in
  Source;
shared RLS_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "b31820dc-4b4f-4696-9a96-bbee438e9306"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4d2305f1-7ef6-42c3-87ed-aed12f143ac2"]}[Data],
  Navigation_3 = Navigation_2{[Id = "100", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "RLS", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
