//
//  RemoteFeedLoader.swift
//  
//
//  Created by Mohamed Ahmed on 2/10/23.
//

import Foundation

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClinet
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failuer(Error)
    }
   
    public init(url: URL, client: HTTPClinet) {
       self.url = url
       self.client = client
   }
   
    public func load(completion: @escaping (Result) -> Void) {
        client.get(with: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let response, let data):
                completion(FeedItemMapper.map(data, from: response))
            case .failuer:
                completion(.failuer(.connectivity))
            }
        }
   }
}
