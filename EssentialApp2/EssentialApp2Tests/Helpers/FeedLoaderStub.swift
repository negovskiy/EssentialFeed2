//
//  FeedLoaderStub.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/18/25.
//

import EssentialFeed2

class FeedLoaderStub: FeedLoader {
    let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
