//
//  CellController.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/21/25.
//

import UIKit

public struct CellController {
    private let id: any Hashable & Sendable
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?
    
    public init(_ id: any Hashable & Sendable,_ dataSource: UITableViewDataSource) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = dataSource as? UITableViewDelegate
        self.dataSourcePrefetching = dataSource as? UITableViewDataSourcePrefetching
    }
}

extension CellController: nonisolated Equatable {
    public nonisolated static func == (lhs: CellController, rhs: CellController) -> Bool {
        AnyHashable(lhs.id) == AnyHashable(rhs.id)
    }
}

extension CellController: nonisolated Hashable {
    public nonisolated func hash(into hasher: inout Hasher) {
        let id = AnyHashable(self.id)
        hasher.combine(id)
    }
}
