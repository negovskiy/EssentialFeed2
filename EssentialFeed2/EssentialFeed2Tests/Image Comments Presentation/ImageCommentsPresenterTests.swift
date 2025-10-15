//
//  ImageCommentsPresenterTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/15/25.
//

import XCTest
import EssentialFeed2

class ImageCommentsPresenterTests: XCTestCase {
    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
    // MARK: - Helpers
    func localized( _ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
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
