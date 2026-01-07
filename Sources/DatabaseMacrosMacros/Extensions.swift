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

  var columnAttribute: AttributeSyntax? {
    for attribute in attributes {
      switch attribute {
      case .attribute(let attr):
        if attr.attributeName.tokens(viewMode: .all).map(\.tokenKind) == [.identifier("Column")] {
          return attr
        }
      default:
        continue
      }
    }

    return nil
  }

  var columnNameOverride: String? {
    guard
      let attr = columnAttribute,
      case .argumentList(let list) = attr.arguments
    else {
      return nil
    }

    for argument in list {
      if let expression = argument.expression.as(StringLiteralExprSyntax.self), expression.segments.count == 1 {
        return expression.segments.first?.trimmedDescription
      }
    }

    return nil
  }

  var columnTransformerName: String? {
    guard
      let attr = columnAttribute,
      case .argumentList(let list) = attr.arguments
    else {
      return nil
    }

    for argument in list {
      if argument.label?.trimmedDescription == "transformer", let member = argument.expression.as(MemberAccessExprSyntax.self), let base = member.base {
        return base.trimmedDescription
//        let description = argument.expression.trimmedDescription
//        if description.hasSuffix(".self") {
//          return String(description.dropLast(5))
//        }
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
