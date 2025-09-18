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
}
