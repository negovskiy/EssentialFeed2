//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/15/25.
//

import XCTest
import EssentialFeed2

final class ImageCommentsLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        assertThatAllKeysAndValuesPresented(in: bundle, table)
    }
}
