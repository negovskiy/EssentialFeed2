//
//  ResourceLoadingView.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/13/25.
//

@MainActor
public protocol ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel)
}
