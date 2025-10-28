//
//  CommentsUIComposer.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 10/27/25.
//

import Combine
import UIKit
import EssentialFeed2
import EssentialFeed2iOS

public enum CommentsUIComposer {
    
    public static func commentsComposedWith(
        commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>
    ) -> ListViewController {
        let presentationAdapter =
        LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>(loader: commentsLoader)
        let commentsController = makeWith(title: ImageCommentsPresenter.title)
        commentsController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(commentsController),
            resourceView: CommentsViewAdapter(controller: commentsController),
            errorView: WeakRefVirtualProxy(commentsController),
            mapper: { ImageCommentsPresenter.map($0) }
        )
        
        return commentsController
    }
    
    private static func makeWith(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController { coder in
            ListViewController(coder: coder)
        }!
        controller.title = title
        return controller
    }
}

final class CommentsViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    
    init(controller: ListViewController?) {
        self.controller = controller
    }
    
    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map { viewModel in
            CellController(viewModel, ImageCommentCellController(model: viewModel))
        })
    }
}
