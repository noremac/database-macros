// swift-tools-version: 6.2

import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "DatabaseMacros",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .tvOS(.v13),
    .watchOS(.v6),
    .macCatalyst(.v13)
  ],
  products: [
    .library(
      name: "DatabaseMacros",
      targets: ["DatabaseMacros"]
    ),
    .executable(
      name: "DatabaseMacrosClient",
      targets: ["DatabaseMacrosClient"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/groue/GRDB.swift",
      from: "7.9.0"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-macro-testing",
      from: "0.6.4"
    ),
    .package(
      url: "https://github.com/swiftlang/swift-syntax",
      from: "602.0.0"
    ),
  ],
  targets: [
    .macro(
      name: "DatabaseMacrosMacros",
      dependencies: [
        .product(
          name: "SwiftSyntaxMacros",
          package: "swift-syntax"
        ),
        .product(
          name: "SwiftCompilerPlugin",
          package: "swift-syntax"
        )
      ]
    ),
    .target(
      name: "DatabaseMacros",
      dependencies: ["DatabaseMacrosMacros"]
    ),
    .executableTarget(
      name: "DatabaseMacrosClient",
      dependencies: [
        "DatabaseMacros",
        .product(name: "GRDB", package: "GRDB.swift"),
      ]
    ),
    .testTarget(
      name: "DatabaseMacrosTests",
      dependencies: [
        "DatabaseMacrosMacros",
        .product(
          name: "MacroTesting",
          package: "swift-macro-testing"
        ),
      ]
    ),
  ]
)
