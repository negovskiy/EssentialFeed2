//
//  FeedViewController.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/25/25.
//

import UIKit
import EssentialFeed2

public typealias CellController = UITableViewDataSource
& UITableViewDelegate & UITableViewDataSourcePrefetching

final public class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
    @IBOutlet public var errorView: ErrorView?
    
    @IBAction private func refresh() {
        onRefresh?()
    }
    
    public var onRefresh: (() -> Void)?
    
    private var loadingControllers: [IndexPath: CellController] = [:]
    
    private var tableModel = [CellController]() {
        didSet { tableView.reloadData() }
    }
    
    private var onViewDidAppear: ((ListViewController) -> Void)?
    
    public convenience init?(coder: NSCoder, onRefresh: (() -> Void)?) {
        self.init(coder: coder)
        self.onRefresh = onRefresh
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
                
        onViewDidAppear = { vc in
            vc.onViewDidAppear = nil
            vc.refresh()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeTableHeaderToFit()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        onViewDidAppear?(self)
    }
    
    public func display(_ cellControllers: [CellController]) {
        loadingControllers = [:]
        tableModel = cellControllers
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView?.message = viewModel.message
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let controller = cellController(forRowAt: indexPath)
        return controller.tableView(tableView, cellForRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let controller = removeLoadingController(forRowAt: indexPath)
        controller?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let controller = cellController(forRowAt: indexPath)
            controller.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let controller = cellController(forRowAt: indexPath)
            controller.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> CellController {
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }
    
    private func removeLoadingController(forRowAt indexPath: IndexPath) -> CellController? {
        let controller = loadingControllers[indexPath]
        loadingControllers[indexPath] = nil
        return controller
    }
}
