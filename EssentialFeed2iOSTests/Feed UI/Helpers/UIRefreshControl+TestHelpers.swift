//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/29/25.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
