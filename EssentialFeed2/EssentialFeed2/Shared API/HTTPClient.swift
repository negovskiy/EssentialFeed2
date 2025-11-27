//
//  HTTPClient.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 4/24/25.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL) async throws -> (Data, HTTPURLResponse)
}
