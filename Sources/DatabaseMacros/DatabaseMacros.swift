@attached(extension, names: named(Columns), named(databaseSelection), named(init(row:)), named(encode(to:)))
public macro Table() = #externalMacro(module: "DatabaseMacrosMacros", type: "TableMacro")
