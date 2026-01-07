import Benchmark

let seededDBQueue = try! makeDBQueue()

let benchmarks: @Sendable () -> Void = {
  Benchmark("FullCodable") { benchmark in
    try! seededDBQueue.read { db in
      benchmark.startMeasurement()
      defer {
        benchmark.stopMeasurement()
      }

      for _ in benchmark.scaledIterations {
        let items = try FullCodableItem.fetchAll(db)
        precondition(items.count == maxItemCount)
      }
    }
  }

  Benchmark("FullTable") { benchmark in
    try! seededDBQueue.read { db in
      benchmark.startMeasurement()
      defer {
        benchmark.stopMeasurement()
      }

      for _ in benchmark.scaledIterations {
        let items = try FullTableItem.fetchAll(db)
        precondition(items.count == maxItemCount)
      }
    }
  }

  Benchmark("X") { benchmark in
    try! seededDBQueue.read { db in
      benchmark.startMeasurement()
      defer {
        benchmark.stopMeasurement()
      }

      for _ in benchmark.scaledIterations {
        let items = try X.fetchAll(db)
        precondition(items.count == maxItemCount)
      }
    }
  }

  Benchmark("LightCodable") { benchmark in
    try! seededDBQueue.read { db in
      benchmark.startMeasurement()
      defer {
        benchmark.stopMeasurement()
      }

      for _ in benchmark.scaledIterations {
        let items = try LightCodableItem.fetchAll(db)
        precondition(items.count == maxItemCount)
      }
    }
  }

  Benchmark("LightTable") { benchmark in
    try! seededDBQueue.read { db in
      benchmark.startMeasurement()
      defer {
        benchmark.stopMeasurement()
      }

      for _ in benchmark.scaledIterations {
        let items = try LightTableItem.fetchAll(db)
        precondition(items.count == maxItemCount)
      }
    }
  }
}
