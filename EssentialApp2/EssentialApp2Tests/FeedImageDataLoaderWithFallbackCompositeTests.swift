//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/15/25.
//

import XCTest
import EssentialApp2
import EssentialFeed2

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase, FeedImageDataLoaderTestCase {
    func test_loadImageData_deliversPrimaryResultOnPrimarySuccess() {
        let primaryData = Data("primary data".utf8)
        let (sut, primaryLoader, fallbackLoader) = makeSUT(
            primaryResult: .success(primaryData),
            fallbackResult: .failure(anyNSError())
        )
        
        expect(sut, toCompleteWith: .success(primaryData), when: {
            primaryLoader.completeLoading()
            fallbackLoader.completeLoading()
        })
    }
    
    func test_loadImageData_deliversFallbackResultOnPrimaryFailure() {
        let fallbackData = Data("fallback data".utf8)
        let (sut, primaryLoader, fallbackLoader) = makeSUT(
            primaryResult: .failure(anyNSError()),
            fallbackResult: .success(fallbackData)
        )
        
        expect(sut, toCompleteWith: .success(fallbackData), when: {
            primaryLoader.completeLoading()
            fallbackLoader.completeLoading()
        })
    }
    
    func test_loadImageData_deliversFailureOnBothPrimaryAndFallbackFailure() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT(
            primaryResult: .failure(anyNSError()),
            fallbackResult: .failure(anyNSError())
        )
        
        expect(sut, toCompleteWith: .failure(anyNSError()), when: {
            primaryLoader.completeLoading()
            fallbackLoader.completeLoading()
        })
    }
    
    func test_loadImageData_cancelsPrimaryLoaderTaskOnCancelBeforePrimaryCompleted() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT(
            primaryResult: .failure(anyNSError()),
            fallbackResult: .failure(anyNSError())
        )
        
        let task = sut.loadImageData(from: anyURL()) { _ in }
        task.cancel()
        XCTAssertTrue(primaryLoader.isTaskCancelled())
        XCTAssertFalse(fallbackLoader.isTaskCancelled())
    }
    
    func test_loadImageData_cancelsFallbackLoaderTaskOnCancelAfterPrimaryFailed() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT(
            primaryResult: .failure(anyNSError()),
            fallbackResult: .failure(anyNSError())
        )
        
        let task = sut.loadImageData(from: anyURL()) { _ in }
        primaryLoader.completeLoading()
        task.cancel()
        XCTAssertFalse(primaryLoader.isTaskCancelled())
        XCTAssertTrue(fallbackLoader.isTaskCancelled())
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        primaryResult: FeedImageDataLoader.Result,
        fallbackResult: FeedImageDataLoader.Result,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (FeedImageDataLoaderWithFallbackComposite, FeedImageDataLoaderStub, FeedImageDataLoaderStub) {
        let primaryLoader = FeedImageDataLoaderStub(result: primaryResult)
        let fallbackLoader = FeedImageDataLoaderStub(result: fallbackResult)
        let sut = FeedImageDataLoaderWithFallbackComposite(
            primary: primaryLoader,
            fallback: fallbackLoader
        )
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, primaryLoader, fallbackLoader)
    }
}
