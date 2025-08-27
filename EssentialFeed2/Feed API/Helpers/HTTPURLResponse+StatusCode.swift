//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 8/27/25.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { 200 }
    
    var isOk: Bool {
        statusCode == Self.OK_200
    }
}
