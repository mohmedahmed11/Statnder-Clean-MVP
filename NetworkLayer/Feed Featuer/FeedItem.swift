//
//  FeedItem.swift
//  
//
//  Created by Mohamed Ahmed on 2/10/23.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageUrl: URL
}
