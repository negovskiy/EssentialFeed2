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
