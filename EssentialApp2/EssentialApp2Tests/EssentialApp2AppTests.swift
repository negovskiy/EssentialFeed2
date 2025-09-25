//
//  EssentialApp2AppTests.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/24/25.
//

import XCTest
import SwiftUI
import EssentialFeed2iOS
@testable import EssentialApp2
import ViewInspector

class EssentialApp2AppTests: XCTestCase {
    func test_appScene_usesRootViewControllerWrapper() {
        let sut = EssentialApp2App()
        let sceneType = String(describing: type(of: sut.body))
        
        let expectedViewControllerType = RootViewControllerWrapper.self
        let expectedViewControllerName = String(describing: expectedViewControllerType)
        
        XCTAssertTrue(sceneType.contains(expectedViewControllerName))
    }
}
