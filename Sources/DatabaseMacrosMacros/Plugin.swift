import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct DatabaseMacrosPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    TableMacro.self,
  ]
}
