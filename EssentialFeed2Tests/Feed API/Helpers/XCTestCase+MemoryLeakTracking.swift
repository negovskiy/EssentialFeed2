//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 4/26/25.
//

import XCTest

extension XCTestCase {
    
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
