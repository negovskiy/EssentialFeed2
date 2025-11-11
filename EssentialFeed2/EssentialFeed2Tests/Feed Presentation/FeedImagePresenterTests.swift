//
//  FeedImagePresenterTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 7/23/25.
//

import XCTest
import EssentialFeed2

class FeedImagePresenterTests: XCTestCase {
    func test_map_createsViewModel() {
        let image = uniqueImage()
        
        let viewModel = FeedImagePresenter.map(image)
        
        XCTAssertEqual(viewModel.description, image.description)
        XCTAssertEqual(viewModel.location, image.location)
    }
}

