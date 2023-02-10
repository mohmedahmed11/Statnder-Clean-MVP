//
//  RemoteFeedLoader.swift
//  
//
//  Created by Mohamed Ahmed on 2/10/23.
//

import Foundation

public protocol HTTPClinet {
   func get(with url: URL)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClinet
   
    public init(url: URL, client: HTTPClinet) {
       self.url = url
       self.client = client
   }
   
    public func load() {
       client.get(with: url)
   }
}
