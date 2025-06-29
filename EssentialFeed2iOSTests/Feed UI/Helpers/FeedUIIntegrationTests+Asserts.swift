//
//  FeedUIIntegrationTests+Asserts.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/29/25.
//

import XCTest
import EssentialFeed2
import EssentialFeed2iOS

extension FeedUIIntegrationTests {
    func assertThat(
        _ sut: FeedViewController,
        isRendering feed: [FeedImage],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard sut.numberOfRenderedFeedImageView() == feed.count else {
            return XCTFail(
                "Expected \(feed.count) rendered feed image view(s), but got \(sut.numberOfRenderedFeedImageView()) instead",
                file: file,
                line: line
            )
        }
        
        for (index, image) in feed.enumerated() {
            assertThat(sut, hasViewConfiguredFor: image, at: index)
        }
    }
    
    func assertThat(
        _ sut: FeedViewController,
        hasViewConfiguredFor image: FeedImage,
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail(
                "Expected to render a FeedImageCell, but \(String(describing: view)) was rendered.",
                file: file,
                line: line
            )
        }
        
        let shouldLocationBeVisible = image.location != nil
        
        XCTAssertEqual(
            cell.isShowingLocation,
            shouldLocationBeVisible,
            "Expected isShowingLocation to be \(shouldLocationBeVisible)",
            file: file,
            line: line
        )
        
        XCTAssertEqual(
            cell.locationText,
            image.location,
            "Expected to show the correct location, but \(String(describing: cell.locationText)) was shown.",
            file: file,
            line: line
        )
        
        XCTAssertEqual(
            cell.descriptionText,
            image.description,
            "Expected to show the correct description, but \(String(describing: cell.descriptionText)) was shown.",
            file: file,
            line: line
        )
    }
}
