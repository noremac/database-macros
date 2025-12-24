import DatabaseMacros
import GRDB

let maxItemCount = 100_000

func makeDBQueue(seed: Bool = true) throws -> DatabaseQueue {
  let dbQueue = try DatabaseQueue()

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

  try migrator.migrate(dbQueue)

  if seed {
    try dbQueue.write { db in
      for i in 0..<maxItemCount {
        try FullCodableItem(
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

struct Foo: Codable {
  var a: Int
  var b: Int
  var c: Int
}

struct FullCodableItem: Codable, FetchableRecord, PersistableRecord {
  static var databaseTableName: String {
    "item"
  }

  var id: Int?
  var a: Int?
  var b: Int?
  var c: Int?
  var foo: Foo?
}

@Table
struct FullTableItem: FetchableRecord, PersistableRecord {
  static var databaseTableName: String {
    "item"
  }

  var id: Int?
  var a: Int?
  var b: Int?
  var c: Int?
  var foo: Foo?
}

struct LightCodableItem: Codable, FetchableRecord, PersistableRecord {
  static var databaseTableName: String {
    "item"
  }

  var id: Int?
  var a: Int?
  var b: Int?
  var c: Int?
}

@Table
struct LightTableItem: FetchableRecord, PersistableRecord {
  static var databaseTableName: String {
    "item"
  }

  var id: Int?
  var a: Int?
  var b: Int?
  var c: Int?
}
