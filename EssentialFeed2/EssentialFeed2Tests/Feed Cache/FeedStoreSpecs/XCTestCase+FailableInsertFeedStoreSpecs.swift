//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 5/29/25.
//

import XCTest
import EssentialFeed2

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    
    func assertThatDeleteDeliversErrorOnDeletionError(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(
            deletionError,
            "Expected deletion to fail",
            file: file,
            line: line
        )
    }
    
    func assertThatDeleteHasNoSideEffectsOnDeletionError(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        deleteCache(from: sut)
        
        expect(
            sut,
            toRetrieve: .success(.none),
            file: file,
            line: line
        )
    }
}
