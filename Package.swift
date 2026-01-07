// swift-tools-version: 6.2

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "DatabaseMacros",
  platforms: [
    .macOS(.v13),
    .iOS(.v13),
    .tvOS(.v13),
    .watchOS(.v6),
    .macCatalyst(.v13),
  ],
  products: [
    .library(
      name: "DatabaseMacros",
      targets: ["DatabaseMacros"]
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
    .package(
      url: "https://github.com/ordo-one/package-benchmark",
      from: "1.29.0"
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
        ),
      ]
    ),
    .target(
      name: "DatabaseMacros",
      dependencies: [
        "DatabaseMacrosMacros",
        .product(name: "GRDB", package: "GRDB.swift"),
      ]
    ),
    .executableTarget(
      name: "DatabaseMacrosBenchmarks",
      dependencies: [
        "DatabaseMacros",
        .product(name: "GRDB", package: "GRDB.swift"),
        .product(name: "Benchmark", package: "package-benchmark"),
      ],
      path: "Benchmarks/DatabaseMacrosBenchmarks",
      plugins: [
        .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
      ]
    ),
    .testTarget(
      name: "DatabaseMacrosTests",
      dependencies: [
        "DatabaseMacros",
        .product(
          name: "MacroTesting",
          package: "swift-macro-testing"
        ),
      ]
    ),
  ]
)
