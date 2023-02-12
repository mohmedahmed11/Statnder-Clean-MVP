//
//  FeedItemMapper.swift
//  NetworkLayer
//
//  Created by Mohamed Ahmed on 2/12/23.
//

import Foundation

internal final class FeedItemMapper {
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
     
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageUrl: image)
        }
    }
    
    private static var OK_200: Int { return 200 }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let items = try  JSONDecoder().decode([Item].self, from: data)
        return items.map({$0.item})
    }
}
