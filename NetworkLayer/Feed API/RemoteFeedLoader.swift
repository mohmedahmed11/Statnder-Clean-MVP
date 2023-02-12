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
        client.get(with: url) { result in
            switch result {
            case .success(let response, let data):
                if let items = try? FeedItemMapper.map(data, response) {
                    completion(.success(items))
                }else {
                    completion(.failuer(.invalidData))
                }
            case .failuer:
                completion(.failuer(.connectivity))
            }
        }
   }
}

private class FeedItemMapper {
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
     
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageUrl: image)
        }
    }
    
    static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let items = try  JSONDecoder().decode([Item].self, from: data)
        return items.map({$0.item})
    }
}
