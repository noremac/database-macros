import DatabaseMacros
import GRDB

let maxItemCount = 100_000

extension DatabaseWriter {
  func migrate() throws {
    var migrator = DatabaseMigrator()

    migrator.registerMigration("add item table") { db in
      try db.create(table: "item") { table in
        table.primaryKey("id", .integer)
        table.column("a", .integer)
        table.column("b", .integer)
        table.column("c", .integer)
        table.column("foo", .jsonText)
      }
    }

    try migrator.migrate(self)
  }
}

func makeDBQueue(seed: Bool = true) throws -> DatabaseQueue {
  let dbQueue = try DatabaseQueue()
  try dbQueue.migrate()

  if seed {
    try dbQueue.write { db in
      for i in 0..<maxItemCount {
        try FullItem_Codable(
          id: i,
          a: i,
          b: i,
          c: i,
          foo: .init(
            a: i,
            b: i,
            c: i
          )
        ).save(db)
      }
    }
  }

  return dbQueue
}

struct Foo: Codable, DatabaseValueConvertible {
  var a: Int
  var b: Int
  var c: Int
}

struct FullItem_Codable: Codable, FetchableRecord, PersistableRecord {
  static var databaseTableName: String {
    "item"
  }

  var id: Int
  var a: Int?
  var b: Int?
  var c: Int?
  var foo: Foo?
}

@Table
struct FullItem_Table_Transformer: FetchableRecord, PersistableRecord {
  static var databaseTableName: String {
    "item"
  }

  var id: Int
  var a: Int?
  var b: Int?
  var c: Int?

  @Column(transformer: OptionalCodableValueTransformer<Foo>.self)
  var foo: Foo?
}

@Table
struct FullItem_Table_DatabaseValueConvertible: FetchableRecord, PersistableRecord {
  static var databaseTableName: String {
    "item"
  }

  var id: Int
  var a: Int?
  var b: Int?
  var c: Int?
  var foo: Foo?
}

struct IntOnlyItem_Codable: Codable, FetchableRecord, PersistableRecord {
  static var databaseTableName: String {
    "item"
  }

  var id: Int
  var a: Int?
  var b: Int?
  var c: Int?
}

@Table
struct IntOnlyItem_Table: FetchableRecord, PersistableRecord {
  static var databaseTableName: String {
    "item"
  }

  var id: Int
  var a: Int?
  var b: Int?
  var c: Int?
}
