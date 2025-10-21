//
//  ImageCommentCellController.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/16/25.
//

import UIKit
import EssentialFeed2

public class ImageCommentCellController {
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
}

extension ImageCommentCellController: CellController {
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date
        cell.messageLabel.text = model.message
        return cell
    }
}
