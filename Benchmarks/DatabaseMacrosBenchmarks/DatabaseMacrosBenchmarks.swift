import Benchmark
import GRDB

let benchmarks: @Sendable () -> Void = {
  let seededDBQueue = try! makeDBQueue()

  Benchmark("Write - codable") { benchmark in
    let dbQueue = try DatabaseQueue()
    try dbQueue.migrate()

    try dbQueue.write { db in
      benchmark.startMeasurement()
      defer {
        benchmark.stopMeasurement()
      }

      for i in 0..<maxItemCount {
        try FullItem_Codable(id: i, a: i, b: i, c: i, foo: .init(a: i, b: i, c: i)).insert(db)
      }
    }
  }

  Benchmark("Write - table convertible") { benchmark in
    let dbQueue = try DatabaseQueue()
    try dbQueue.migrate()

    try dbQueue.write { db in
      benchmark.startMeasurement()
      defer {
        benchmark.stopMeasurement()
      }

      for i in 0..<maxItemCount {
        try FullItem_Table_DatabaseValueConvertible(id: i, a: i, b: i, c: i, foo: .init(a: i, b: i, c: i)).insert(db)
      }
    }
  }

  Benchmark("Write - table transformer") { benchmark in
    let dbQueue = try DatabaseQueue()
    try dbQueue.migrate()

    try dbQueue.write { db in
      benchmark.startMeasurement()
      defer {
        benchmark.stopMeasurement()
      }

      for i in 0..<maxItemCount {
        try FullItem_Table_Transformer(id: i, a: i, b: i, c: i, foo: .init(a: i, b: i, c: i)).insert(db)
      }
    }
  }

  Benchmark("FullItem - codable") { benchmark in
    try! seededDBQueue.read { db in
      benchmark.startMeasurement()
      defer {
        benchmark.stopMeasurement()
      }

      for _ in benchmark.scaledIterations {
        let items = try FullItem_Codable.fetchAll(db)
        precondition(items.count == maxItemCount)
      }
    }
  }

  Benchmark("FullItem - table convertible") { benchmark in
    try! seededDBQueue.read { db in
      benchmark.startMeasurement()
      defer {
        benchmark.stopMeasurement()
      }

      for _ in benchmark.scaledIterations {
        let items = try FullItem_Table_DatabaseValueConvertible.fetchAll(db)
        precondition(items.count == maxItemCount)
      }
    }
  }

  Benchmark("FullItem - table transformer") { benchmark in
    try! seededDBQueue.read { db in
      benchmark.startMeasurement()
      defer {
        benchmark.stopMeasurement()
      }

      for _ in benchmark.scaledIterations {
        let items = try FullItem_Table_Transformer.fetchAll(db)
        precondition(items.count == maxItemCount)
      }
    }
  }

  Benchmark("IntOnly - codable") { benchmark in
    try! seededDBQueue.read { db in
      benchmark.startMeasurement()
      defer {
        benchmark.stopMeasurement()
      }

      for _ in benchmark.scaledIterations {
        let items = try IntOnlyItem_Codable.fetchAll(db)
        precondition(items.count == maxItemCount)
      }
    }
  }

  Benchmark("IntOnly - table") { benchmark in
    try! seededDBQueue.read { db in
      benchmark.startMeasurement()
      defer {
        benchmark.stopMeasurement()
      }

      for _ in benchmark.scaledIterations {
        let items = try IntOnlyItem_Table.fetchAll(db)
        precondition(items.count == maxItemCount)
      }
    }
  }
}
