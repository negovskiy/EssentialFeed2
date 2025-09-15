//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/15/25.
//

import XCTest
import EssentialFeed2

final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    class Task: FeedImageDataLoaderTask {
        let wrapped: FeedImageDataLoaderTask?
        
        init(wrapped: FeedImageDataLoaderTask?) {
            self.wrapped = wrapped
        }
        
        func cancel() {
            wrapped?.cancel()
        }
    }
    let primary: FeedImageDataLoader
    let fallback: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func loadImageData(
        from url: URL,
        completion: @escaping (
            FeedImageDataLoader.Result
        ) -> Void
    ) -> any EssentialFeed2.FeedImageDataLoaderTask {
        Task(wrapped: primary.loadImageData(from: url) { [weak self] primaryResult in
            switch primaryResult {
            case let .success(primaryData):
                completion(.success(primaryData))
                
            case .failure:
                _ = self?.fallback.loadImageData(from: url) { fallbackResult in
                    switch fallbackResult {
                    case let .success(fallbackData):
                        completion(.success(fallbackData))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            }
        })
    }
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    func test_loadImageData_deliversPrimaryResultOnPrimarySuccess() {
        let primaryData = Data("primary data".utf8)
        let sut = makeSUT(primaryResult: .success(primaryData), fallbackResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .success(primaryData))
    }
    
    func test_loadImageData_deliversFallbackResultOnPrimaryFailure() {
        let fallbackData = Data("fallback data".utf8)
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackData))
        
        expect(sut, toCompleteWith: .success(fallbackData))
    }
    
    func test_loadImageData_deliversFailureOnBothPrimaryAndFallbackFailure() {
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    func test_loadImageData_cancelsPrimaryLoaderTaskOnCancelBeforePrimaryCompleted() {
        let primaryData = Data("primary data".utf8)
        let primaryLoader = FeedImageDataLoaderStub(result: .success(primaryData))
        let fallbackLoader = FeedImageDataLoaderStub(result: .failure(anyNSError()))
        let sut = FeedImageDataLoaderWithFallbackComposite(
            primary: primaryLoader,
            fallback: fallbackLoader
        )
        
        let task = sut.loadImageData(from: anyURL()) { _ in }
        task.cancel()
        XCTAssertTrue(primaryLoader.isTaskCancelled())
        XCTAssertFalse(fallbackLoader.isTaskCancelled())
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        primaryResult: FeedImageDataLoader.Result,
        fallbackResult: FeedImageDataLoader.Result,
        file: StaticString = #file,
        line: UInt = #line
    ) -> FeedImageDataLoaderWithFallbackComposite {
        let primaryLoader = FeedImageDataLoaderStub(result: primaryResult)
        let fallbackLoader = FeedImageDataLoaderStub(result: fallbackResult)
        let sut = FeedImageDataLoaderWithFallbackComposite(
            primary: primaryLoader,
            fallback: fallbackLoader
        )
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(
        _ sut: FeedImageDataLoaderWithFallbackComposite,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = XCTestExpectation(description: "Wait for loading to complete")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(expectedData), .success(receivedData)):
                XCTAssertEqual(
                    expectedData,
                    receivedData,
                    "Expected and received data do not match",
                    file: file,
                    line: line
                )
            
            case (.failure, .failure):
                break
            default:
                XCTFail(
                    "Expected \(expectedResult), but got \(receivedResult)",
                    file: file,
                    line: line
                )
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private class FeedImageDataLoaderStub: FeedImageDataLoader {
        private class TaskWrapper: FeedImageDataLoaderTask {
            var isCanceled = false
            
            func cancel() {
                isCanceled = true
            }
        }
        
        let result: FeedImageDataLoader.Result
        private var task: TaskWrapper?
        
        init(result: FeedImageDataLoader.Result) {
            self.result = result
        }
        
        func loadImageData(
            from url: URL,
            completion: @escaping (FeedImageDataLoader.Result) -> Void
        ) -> any EssentialFeed2.FeedImageDataLoaderTask {
            completion(result)
            let task = TaskWrapper()
            self.task = task
            return task
        }
        
        func isTaskCancelled() -> Bool {
            task?.isCanceled == true
        }
    }
}
