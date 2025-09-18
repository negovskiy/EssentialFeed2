//
//  XCTestCase+memoryLeakTracking.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/18/25.
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
