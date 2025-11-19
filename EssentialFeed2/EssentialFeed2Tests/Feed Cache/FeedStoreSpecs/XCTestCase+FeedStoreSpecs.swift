//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 5/29/25.
//

import XCTest
import EssentialFeed2

extension FeedStoreSpecs where Self: XCTestCase {
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(
            sut,
            toRetrieve: .success(CachedFeed(feed: feed, timestamp: timestamp)),
            file: file,
            line: line
        )
    }
    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(
            sut,
            toRetrieveTwice: .success(CachedFeed(feed: feed, timestamp: timestamp)),
            file: file,
            line: line
        )
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNil(
            firstInsertionError,
            "Expected to insert successfully",
            file: file,
            line: line
        )
    }
    
    func assertThatInsertDeliversNoErrorOnNonEmptyCache(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let latestFeed = uniqueImageFeed().local
        let latestTimeStamp = Date()
        let latestInsertionError = insert((latestFeed, latestTimeStamp), to: sut)
        
        XCTAssertNil(
            latestInsertionError,
            "Expected to insert successfully",
            file: file,
            line: line
        )
    }
    
    func assertThatInsertOverridesPreviouslyInsertedCacheValues(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let latestFeed = uniqueImageFeed().local
        let latestTimeStamp = Date()
        insert((latestFeed, latestTimeStamp), to: sut)
        
        expect(
            sut,
            toRetrieve: .success(CachedFeed(feed: latestFeed, timestamp: latestTimeStamp)),
            file: file,
            line: line
        )
    }
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(
            deletionError,
            "Expected to delete successfully",
            file: file,
            line: line
        )
    }
    
    func assertThatDeleteHasNoSideEffectsOnEmptyCache(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        deleteCache(from: sut)
        
        expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
    }
    
    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(
            deletionError,
            "Expected empty cache deletion to succeed without error",
            file: file,
            line: line
        )
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCache(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        insert((uniqueImageFeed().local, Date()), to: sut)
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        do {
            try sut.insert(cache.feed, cache.timestamp)
            return nil
        } catch {
            return error
        }
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        do {
            try sut.deleteCachedFeed()
            return nil
        } catch {
            return error
        }
    }
    
    func expect(
        _ sut: FeedStore,
        toRetrieve expectedResult: Result<CachedFeed?, Error>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let retrievedResult = Result { try sut.retrieve() }
        
        switch (expectedResult, retrievedResult) {
        case (.success(.none), .success(.none)), (.failure, .failure):
            break
            
        case let (.success(.some((expectedFeed, expectedTimestamp))), .success(.some((retrievedFeed, retrievedTimestamp)))):
            XCTAssertEqual(expectedFeed, retrievedFeed, file: file, line: line)
            XCTAssertEqual(expectedTimestamp, retrievedTimestamp, file: file, line: line)
            
        default:
            XCTFail("Expected to retrieve \(expectedResult), but got \(retrievedResult) instead", file: file, line: line)
        }
    }
    
    func expect(
        _ sut: FeedStore,
        toRetrieveTwice expectedResult: Result<CachedFeed?, Error>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
}
