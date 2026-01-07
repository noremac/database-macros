import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct TableMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    guard let declaration = declaration.as(StructDeclSyntax.self) else {
      return []
    }

    let columnVars = declaration.memberBlock.members.compactMap { member in
      if let variable = member.decl.as(VariableDeclSyntax.self),
         variable.isValidColumnVar
      {
        variable
      } else {
        nil
      }
    }

    var columns = [String]()
    var selections = [String]()
    var decodes = [String]()
    var encodes = [String]()

    for (idx, variable) in columnVars.enumerated() {
      guard let pattern = variable.bindings.first?.pattern.as(IdentifierPatternSyntax.self) else {
        return []
      }

      let varName = pattern.identifier.trimmedDescription
      let columnName = variable.columnNameOverride ?? varName

      columns.append(#"static let \#(varName) = Column("\#(columnName)")"#)
      selections.append(#"Columns.\#(varName)"#)

      if let transform = variable.columnTransformerName {
        decodes.append(#"self.\#(varName) = try \#(transform).fromDatabaseValue(row[\#(idx)])"#)
        encodes.append(#"container[Columns.\#(varName)] = try \#(transform).toDatabaseValue(\#(varName))"#)
      } else {
        decodes.append(#"self.\#(varName) = row[\#(idx)]"#)
        encodes.append(#"container[Columns.\#(varName)] = \#(varName)"#)
      }
    }

    let decl: DeclSyntax = """
    extension \(type) {
      enum Columns {
        \(raw: columns.joined(separator: "\n    "))
      }

      static var databaseSelection: [any SQLSelectable] {
        [\(raw: selections.joined(separator: ", "))]
      }

      init(row: Row) throws {
        \(raw: decodes.joined(separator: "\n    "))
      }

      func encode(to container: inout PersistenceContainer) throws {
        \(raw: encodes.joined(separator: "\n    "))
      }
    }
    """

    let ext = decl.cast(ExtensionDeclSyntax.self)
    return [ext]
  }
}
