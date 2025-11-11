//
//  FeedLocalizationTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/29/25.
//

import XCTest
import EssentialFeed2

final class FeedLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        assertThatAllKeysAndValuesPresented(in: bundle, table)
    }
}
