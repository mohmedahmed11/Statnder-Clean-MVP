//
//  RemoteFeedLoader.swift
//  
//
//  Created by Mohamed Ahmed on 2/10/23.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse)
    case failuer(Error)
}

public protocol HTTPClinet {
    func get(with url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClinet
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
   
    public init(url: URL, client: HTTPClinet) {
       self.url = url
       self.client = client
   }
   
    public func load(completion: @escaping (Error) -> Void) {
        client.get(with: url) { result in
            switch result {
            case .success:
                completion(.invalidData)
            case .failuer:
                completion(.connectivity)
            }
        }
   }
}
