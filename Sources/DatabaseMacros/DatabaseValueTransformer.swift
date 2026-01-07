import Foundation
import GRDB

public protocol DatabaseValueTransformer {
  associatedtype DatabaseValue: DatabaseValueConvertible, StatementColumnConvertible
  associatedtype Value

  static func fromDatabaseValue(_ databaseValue: DatabaseValue) throws -> Value

  static func toDatabaseValue(_ value: Value) throws -> DatabaseValue
}

@usableFromInline let decoder = JSONDecoder()
@usableFromInline let encoder = JSONEncoder()

public enum CodableValueTransformer<Value: Codable>: DatabaseValueTransformer {
  @inlinable
  public static func fromDatabaseValue(_ databaseValue: Data) throws -> Value {
    try decoder.decode(Value.self, from: databaseValue)
  }

  @inlinable
  public static func toDatabaseValue(_ value: Value) throws -> Data {
    try encoder.encode(value)
  }
}

public enum OptionalCodableValueTransformer<Value: Codable>: DatabaseValueTransformer {
  @inlinable
  public static func fromDatabaseValue(_ databaseValue: Data?) throws -> Value? {
    guard let databaseValue else {
      return nil
    }
    return try decoder.decode(Value.self, from: databaseValue)
  }

  @inlinable
  public static func toDatabaseValue(_ value: Value?) throws -> Data? {
    guard let value else {
      return nil
    }
    return try encoder.encode(value)
  }
}
