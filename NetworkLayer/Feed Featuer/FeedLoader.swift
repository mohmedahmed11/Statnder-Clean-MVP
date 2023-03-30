//
//  FeedLoader.swift
//  
//
//  Created by Mohamed Ahmed on 2/10/23.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failuer(Error)
}

public protocol FeedLoader {
    
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
 
