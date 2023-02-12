//
//  HTTPClient.swift
//  NetworkLayer
//
//  Created by Mohamed Ahmed on 2/12/23.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse, Data)
    case failuer(Error)
}

public protocol HTTPClinet {
    func get(with url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
