//
//  UITableView+Dequeueing.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/28/25.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        dequeueReusableCell(withIdentifier: String(describing: T.self)) as! T
    }
}
