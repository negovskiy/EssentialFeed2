//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 5/29/25.
//

import XCTest
import EssentialFeed2

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
    
    func assertThatRetrieveDeliversFailureOnRetrievalError(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(
            sut,
            toRetrieve: .failure(anyNSError()),
            file: file,
            line: line
        )
    }
    
    func assertThatRetrieveHasNoSideEffectsOnFailure(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(
            sut,
            toRetrieveTwice: .failure(anyNSError()),
            file: file,
            line: line
        )
    }
}
