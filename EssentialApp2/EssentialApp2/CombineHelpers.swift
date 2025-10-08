//
//  CombineHelpers.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 10/8/25.
//

import Foundation
import Combine
import EssentialFeed2

public extension FeedImageDataLoader {
    typealias Publisher = AnyPublisher<Data, Error>
    
    func loadImageDataPublisher(from url: URL) -> AnyPublisher<Data, Error> {
        var task: FeedImageDataLoaderTask?
        
        return Deferred {
            Future { completion in
                task = self.loadImageData(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Data {
    func caching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput:  { data in
            cache.saveIgnoringResult(data, for: url)
        })
        .eraseToAnyPublisher()
    }
}

private extension FeedImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        saveImageData(data, for: url) { _ in }
    }
}

public extension FeedLoader {
    typealias Publisher = AnyPublisher<[FeedImage], Error>
    
    func loadPublisher() -> AnyPublisher<[FeedImage], Error> {
        Deferred {
            Future(self.load)
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func fallback(
        to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>
    ) -> AnyPublisher<Output, Failure> {
        self.catch { _ in
            fallbackPublisher()
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == [FeedImage] {
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput:  { data in
            cache.saveIgnoringResult(data)
        })
        .eraseToAnyPublisher()
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}

extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
        ImmediateWhenOnMainQueueScheduler.shared
    }
    
    struct ImmediateWhenOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
        var now: SchedulerTimeType {
            DispatchQueue.main.now
        }
        
        var minimumTolerance: SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }
        
        static let shared = Self()
        
        private static let key = DispatchSpecificKey<UInt8>()
        private static let value = UInt8.max
        
        private init() {
            DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
        }
        
        private func isMainQueue() -> Bool {
            DispatchQueue.getSpecific(key: Self.key) == Self.value
        }
        
        func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            guard isMainQueue() else {
                return DispatchQueue.main.schedule(options: options, action)
            }
            
            
            action()
        }
        
        func schedule(
            after date: DispatchQueue.SchedulerTimeType,
            tolerance: DispatchQueue.SchedulerTimeType.Stride,
            options: DispatchQueue.SchedulerOptions?,
            _ action: @escaping () -> Void
        ) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }
        
        func schedule(
            after date: SchedulerTimeType,
            interval: SchedulerTimeType.Stride,
            tolerance: SchedulerTimeType.Stride,
            options: SchedulerOptions?,
            _ action: @escaping () -> Void
        ) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
    }
}
