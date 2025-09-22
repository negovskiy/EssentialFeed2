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
        
        XCTAssertEqual(app.cells.count, 22)
        XCTAssertEqual(app.cells.firstMatch.images.count, 1)
    }
}
