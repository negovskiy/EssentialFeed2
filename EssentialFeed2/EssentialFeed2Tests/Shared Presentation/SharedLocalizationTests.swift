//
//  SharedLocalizationTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/10/25.
//

import XCTest
import EssentialFeed2

final class SharedLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: FeedPresenter.self)
        
        assertThatAllKeysAndValuesPresented(in: bundle, table)
    }
}
