//
//  ResourceErrorView.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/13/25.
//

@MainActor
public protocol ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel)
}
