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

    let (columns, selections, decodes, encodes, _) = declaration
      .memberBlock
      .members
      .reduce(into: ([String](), [String](), [String](), [String](), 0)) { partialResult, member in
        guard
          let variable = member.decl.as(VariableDeclSyntax.self),
          let binding = variable.bindings.first,
          let pattern = binding.pattern.as(IdentifierPatternSyntax.self)
        else {
          return
        }

        let varName = pattern.identifier.trimmedDescription

        partialResult.0.append(#"static let \#(varName) = Column("\#(varName)")"#)
        partialResult.1.append(#"Column("\#(varName)")"#)
        partialResult.2.append(#"self.\#(varName) = row[\#(partialResult.4)]"#)
        partialResult.3.append(#"container[Columns.\#(varName)] = \#(varName)"#)
        partialResult.4 += 1
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
