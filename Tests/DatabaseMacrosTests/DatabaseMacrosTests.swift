import MacroTesting
import Testing

#if canImport(DatabaseMacrosMacros)
import DatabaseMacrosMacros

@Suite(.macros([TableMacro.self]), .snapshots(record: .failed))
struct DatabaseMacrosTests {
  @Test
  func basic() {
    assertMacro {
      """
      @Table
      struct MyType {
        var x: Int
        var y: Int
        var z: Int
      }
      """
    } expansion: {
      """
      struct MyType {
        var x: Int
        var y: Int
        var z: Int
      }

      extension MyType {
        enum Columns {
          static let x = Column("x")
          static let y = Column("y")
          static let z = Column("z")
        }

        static var databaseSelection: [any SQLSelectable] {
          [Column("x"), Column("y"), Column("z")]
        }

        init(row: Row) throws {
          self.x = row[0]
          self.y = row[0]
          self.z = row[0]
        }

        func encode(to container: inout PersistenceContainer) throws {
          container[Columns.x] = x
          container[Columns.y] = y
          container[Columns.z] = z
        }
      }
      """
    }
  }
}
#endif
