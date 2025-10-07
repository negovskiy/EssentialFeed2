//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/3/25.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
    }
}
