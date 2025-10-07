//
//  SharedTestHelpers.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 5/16/25.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0, userInfo: nil)
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let json = ["items": items]
    return try! JSONSerialization.data(withJSONObject: json)
}

extension HTTPURLResponse {
    convenience init(statusCode code: Int) {
        self.init(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!
    }
}

