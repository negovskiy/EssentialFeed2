//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 5/29/25.
//

import XCTest
import EssentialFeed2

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    
    func assertThatInsertDeliversErrorOnInsertionError(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        
        XCTAssertNotNil(
            insertionError,
            "Expected insertion to fail",
            file: file,
            line: line
        )
    }
    
    func assertThatInsertHasNoSideEffectsOnInsertionError(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(
            sut,
            toRetrieve: .success(.empty),
            file: file,
            line: line
        )
    }
}
