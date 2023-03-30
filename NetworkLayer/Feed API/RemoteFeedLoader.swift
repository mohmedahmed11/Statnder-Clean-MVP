//
//  RemoteFeedLoader.swift
//  
//
//  Created by Mohamed Ahmed on 2/10/23.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClinet
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
   
    public init(url: URL, client: HTTPClinet) {
       self.url = url
       self.client = client
   }
   
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let response, let data):
                completion(FeedItemMapper.map(data, from: response))
            case .failuer:
                completion(.failuer(Error.connectivity))
            }
        }
   }
}
