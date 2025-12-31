import Foundation
import GRDB

@usableFromInline let decoder = JSONDecoder()

public extension Row {
  @inlinable
  func _decode<V>(
    recordType: (some FetchableRecord).Type,
    column: some ColumnExpression,
    index: Int
  ) throws -> V
    where V: DatabaseValueConvertible
  {
    self[index]
  }

  @inlinable
  func _decode<V>(
    recordType: (some FetchableRecord).Type,
    column: some ColumnExpression,
    index: Int
  ) throws -> V
    where V: DatabaseValueConvertible & StatementColumnConvertible
  {
    self[index]
  }

  @_disfavoredOverload
  @inlinable
  func _decode<V>(
    recordType: (some FetchableRecord).Type,
    column: some ColumnExpression,
    index: Int
  ) throws -> V
    where V: Decodable
  {
    try withUnsafeData(atIndex: index) { data in
      let decoder = recordType.databaseJSONDecoder(for: column.name)
      return try decoder.decode(V.self, from: data ?? Data())
    }
  }
}

public extension PersistenceContainer {
  @inlinable
  mutating func _encode(
    _ value: some DatabaseValueConvertible,
    recordType: (some FetchableRecord).Type,
    column: some ColumnExpression
  ) throws {
    self[column] = value
  }

  @_disfavoredOverload
  @inlinable
  mutating func _encode(
    _ value: some Encodable,
    recordType: (some EncodableRecord).Type,
    column: some ColumnExpression
  ) throws {
    let encoder = recordType.databaseJSONEncoder(for: column.name)
    let data = try encoder.encode(value)
    self[column] = data
  }
}
