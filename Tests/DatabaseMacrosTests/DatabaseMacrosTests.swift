import DatabaseMacros
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
          self.x = row[0]
        }

        func encode(to container: inout PersistenceContainer) throws {
          container[Columns.x] = x
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
          self.x = row[0]
        }

        func encode(to container: inout PersistenceContainer) throws {
          container[Columns.x] = x
        }
      }
      """
    }
  }

  @Test
  func `column transformer override`() {
    assertMacro {
      """
      @Table
      struct MyType {
        @Column(transformer: CodableValueTransformer<Foo>.self)
        var foo: Foo
      }
      """
    } expansion: {
      """
      struct MyType {
        @Column(transformer: CodableValueTransformer<Foo>.self)
        var foo: Foo
      }

      extension MyType {
        enum Columns {
          static let foo = Column("foo")
        }

        static var databaseSelection: [any SQLSelectable] {
          [Columns.foo]
        }

        init(row: Row) throws {
          self.foo = try CodableValueTransformer<Foo>.fromDatabaseValue(row[0])
        }

        func encode(to container: inout PersistenceContainer) throws {
          container[Columns.foo] = try CodableValueTransformer<Foo>.toDatabaseValue(foo)
        }
      }
      """
    }
  }
}
#endif
