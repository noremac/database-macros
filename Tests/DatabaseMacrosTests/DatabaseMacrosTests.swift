import MacroTesting
import Testing

#if canImport(DatabaseMacrosMacros)
import DatabaseMacrosMacros

@Suite(.macros([TableMacro.self]), .snapshots(record: .failed), .serialized)
struct DatabaseMacrosTests {
  @Test
  func basic() {
    assertMacro {
      """
      @Table
      struct MyType {
        var x: Int
      }
      """
    } expansion: {
      """
      struct MyType {
        var x: Int
      }

      extension MyType {
        enum Columns {
          static let x = Column("x")
        }

        static var databaseSelection: [any SQLSelectable] {
          [Columns.x]
        }

        init(row: Row) throws {
          self.x = try row._decode(recordType: Self.self, column: Columns.x, index: 0)
        }

        func encode(to container: inout PersistenceContainer) throws {
          try container._encode(x, recordType: Self.self, column: Columns.x)
        }
      }
      """
    }
  }

  @Test
  func `column name override`() {
    assertMacro {
      """
      @Table
      struct MyType {
        @Column("other")
        var x: Int
      }
      """
    } expansion: {
      """
      struct MyType {
        @Column("other")
        var x: Int
      }

      extension MyType {
        enum Columns {
          static let x = Column("other")
        }

        static var databaseSelection: [any SQLSelectable] {
          [Columns.x]
        }

        init(row: Row) throws {
          self.x = try row._decode(recordType: Self.self, column: Columns.x, index: 0)
        }

        func encode(to container: inout PersistenceContainer) throws {
          try container._encode(x, recordType: Self.self, column: Columns.x)
        }
      }
      """
    }
  }
}
#endif
