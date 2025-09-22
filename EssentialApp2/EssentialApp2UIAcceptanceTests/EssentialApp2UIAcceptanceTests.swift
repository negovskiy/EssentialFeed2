//
//  EssentialApp2UIAcceptanceTests.swift
//  EssentialApp2UIAcceptanceTests
//
//  Created by Andrey Negovskiy on 9/22/25.
//

import XCTest

final class EssentialApp2UIAcceptanceTests: XCTestCase {
    func test_onLaunch_displayRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        
        app.launch()
        
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 22)
        
        let feedImage = app.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(feedImage.exists)
    }
}
