import DatabaseMacros
import Foundation
import GRDB

let decoder = JSONDecoder()

struct Foo: Codable, DatabaseValueConvertible {
  var a: Int
  var b: Int
  var c: Int

  static func databaseJSONDecoder() -> JSONDecoder {
    decoder
  }
}

@Table
struct Item: Codable, FetchableRecord, PersistableRecord {
  var x: Int?
  var y: Int?
  var z: Int?
  var zz: Foo
}

let dbQueue = try DatabaseQueue()

var migrator = DatabaseMigrator()
migrator.registerMigration("add item table") { db in
  try db.create(table: "item") { table in
    table.primaryKey("x", .integer)
    table.column("y", .integer).notNull()
    table.column("z", .integer).notNull()
    table.column("zz", .jsonText).notNull()
  }
}

try migrator.migrate(dbQueue)

let count = 100_000

let writeStart = ProcessInfo.processInfo.systemUptime

try dbQueue.write { db in
  for i in 0..<count {
    try Item(
      x: i,
      y: i,
      z: i,
      zz: .init(a: i, b: i, c: i)
    ).save(db)
  }
}

let writeEnd = ProcessInfo.processInfo.systemUptime

sleep(1)

let readStart = ProcessInfo.processInfo.systemUptime

try dbQueue.read { db in
  let items = try Item.fetchAll(db)
  precondition(items.count == count)
}

let readEnd = ProcessInfo.processInfo.systemUptime

let data = Data(#"{"a":0,"b":0,"c":0}"#.utf8)

let thingStart = ProcessInfo.processInfo.systemUptime

for _ in 0..<count {
  try! decoder.decode(Foo.self, from: data)
}

let thingEnd = ProcessInfo.processInfo.systemUptime

print((writeEnd - writeStart) * 1000)
print((readEnd - readStart) * 1000)
print((thingEnd - thingStart) * 1000)
