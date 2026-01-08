//
//  AsyncLoadResourcePresentationAdapter.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 12/2/25.
//

import EssentialFeed2
import EssentialFeed2iOS

@MainActor
final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    
    var presenter: LoadResourcePresenter<Resource, View>?
    private let loader: () async throws -> Resource
    private var cancellable: Task<Void, Never>?
    private var isLoading: Bool = false
    
    init(loader: @escaping () async throws -> Resource) {
        self.loader = loader
    }
    
    func loadResource() {
        guard !isLoading else { return }
        
        presenter?.didStartLoading()
        isLoading = true
        
        cancellable = Task.immediate { @MainActor [weak self] in
            defer { self?.isLoading = false }
            
            do {
                if let resource = try await self?.loader() {
                    if Task.isCancelled { return }
                    self?.presenter?.didFinishLoading(resource)
                }
            } catch {
                if Task.isCancelled { return }
                self?.presenter?.didFinishLoadingWithError(error)
            }
        }
    }
    
    deinit {
        cancellable?.cancel()
    }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        loadResource()
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
        cancellable = nil
        isLoading = false
    }
}
