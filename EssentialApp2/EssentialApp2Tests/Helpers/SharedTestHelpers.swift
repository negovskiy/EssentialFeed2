//
//  SharedTestHelpers.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/15/25.
//

import XCTest

extension XCTestCase {
    func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0, userInfo: nil)
    }
    
    func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
    
    func trackForMemoryLeaks<T: AnyObject>(
        _ object: T,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(
                object,
                "Instance should have been deallocated. Potential memory leak.",
                file: file,
                line: line
            )
        }
    }
}
