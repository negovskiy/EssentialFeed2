//
//  FeedImageDataLoaderStub.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/19/25.
//

import Foundation
import EssentialFeed2

class FeedImageDataLoaderStub: FeedImageDataLoader {
        private class TaskWrapperSpy: FeedImageDataLoaderTask {
            var isCanceled = false
            var isSecond = false
            
            func cancel() {
                isCanceled = true
            }
        }
        
        let result: FeedImageDataLoader.Result
        private var task: TaskWrapperSpy?
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(result: FeedImageDataLoader.Result) {
            self.result = result
        }
        
        func loadImageData(
            from url: URL,
            completion: @escaping (FeedImageDataLoader.Result) -> Void
        ) -> any EssentialFeed2.FeedImageDataLoaderTask {
            self.completion = completion
            let task = TaskWrapperSpy()
            self.task = task
            return task
        }
        
        func completeLoading() {
            completion?(result)
        }
        
        func isTaskCancelled() -> Bool {
            task?.isCanceled == true
        }
    }
