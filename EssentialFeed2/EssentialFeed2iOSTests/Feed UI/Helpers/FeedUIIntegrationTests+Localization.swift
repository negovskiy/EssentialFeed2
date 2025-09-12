//
//  FeedUIIntegrationTests+Localization.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/29/25.
//

import Foundation
import XCTest
import EssentialFeed2

extension FeedUIIntegrationTests {
    func localized( _ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = String(localized: String.LocalizationValue(key), table: table, bundle: bundle)
        
        if key == value {
            XCTFail(
                "Missing localized string for \(key)",
                file: file,
                line: line
            )
        }
        
        return value
    }
}
