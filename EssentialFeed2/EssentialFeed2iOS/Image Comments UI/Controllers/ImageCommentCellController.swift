//
//  ImageCommentCellController.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/16/25.
//

import UIKit
import EssentialFeed2

public class ImageCommentCellController: NSObject, CellController {
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date
        cell.messageLabel.text = model.message
        return cell
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {}
}
