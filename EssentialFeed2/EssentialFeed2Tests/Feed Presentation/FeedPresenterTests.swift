//
//  FeedPresenterTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 7/2/25.
//

import XCTest
import EssentialFeed2

class FeedPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
    }
    
    func test_map_createsViewModel() {
        let feed = uniqueImageFeed().models
        
        let viewModel = FeedPresenter.map(feed)
        
        XCTAssertEqual(viewModel.feed, feed)
    }
    
    // MARK: - Helpers
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
