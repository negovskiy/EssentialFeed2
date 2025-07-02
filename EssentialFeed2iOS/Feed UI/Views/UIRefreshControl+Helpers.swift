//
//  UIRefreshControl+Helpers.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 7/2/25.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
