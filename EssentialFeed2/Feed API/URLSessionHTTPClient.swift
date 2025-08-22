//
//  URLSessionHTTPClient.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 4/28/25.
//

import Foundation

private class URLSessionHTTPClientTask: HTTPClientTask {
    let task: URLSessionDataTask
    
    init(task: URLSessionDataTask) {
        self.task = task
    }
    
    func cancel() {
        task.cancel()
    }
}

public class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            let result = Result {
                if let error {
                    throw error
                }
                
                guard let data, let response = response as? HTTPURLResponse else {
                    throw UnexpectedValuesRepresentation()
                }
                
                return (data, response)
            }
            completion(result)
        }
        task.resume()
        
        return URLSessionHTTPClientTask(task: task)
    }
}
