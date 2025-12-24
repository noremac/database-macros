import SwiftSyntax
import SwiftSyntaxMacros

extension VariableDeclSyntax {
  var isValidColumnVar: Bool {
    isInstance && !isComputed
  }

  var isInstance: Bool {
    for modifier in modifiers {
      for token in modifier.tokens(viewMode: .all) {
        if token.tokenKind == .keyword(.static) || token.tokenKind == .keyword(.class) {
          return false
        }
      }
    }
    return true
  }

  func columnNameOverride() -> String? {
    for attribute in attributes {
      switch attribute {
      case .attribute(let attr):
        if attr.attributeName.tokens(viewMode: .all).map(\.tokenKind) == [.identifier("Column")] {
          guard case .argumentList(let list) = attr.arguments else {
            return nil
          }

          for argument in list {
            if let expression = argument.expression.as(StringLiteralExprSyntax.self), expression.segments.count == 1 {
              return expression.segments.first?.trimmedDescription
            }
          }
        }
      default:
        break
      }
    }
    return nil
  }

  func accessorsMatching(_ predicate: (TokenKind) -> Bool) -> [AccessorDeclSyntax] {
    let accessors: [AccessorDeclListSyntax.Element] = bindings.compactMap { patternBinding in
      switch patternBinding.accessorBlock?.accessors {
      case .accessors(let accessors):
        accessors
      default:
        nil
      }
    }.flatMap(\.self)
    return accessors.compactMap { accessor in
      if predicate(accessor.accessorSpecifier.tokenKind) {
        accessor
      } else {
        nil
      }
    }
  }

  var isComputed: Bool {
    if accessorsMatching({ $0 == .keyword(.get) }).isEmpty {
      bindings.contains { binding in
        if case .getter = binding.accessorBlock?.accessors {
          true
        } else {
          false
        }
      }
    } else {
      true
    }
  }
}
