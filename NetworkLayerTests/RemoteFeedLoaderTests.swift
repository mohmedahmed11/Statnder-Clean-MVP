//
//  RemoteFeedLoaderTest.swift
//  NetworkLayerTests
//
//  Created by Mohamed Ahmed on 2/10/23.
//

import XCTest
 
class RemoteFeedLoader {
    func load() {
        HTTPClinet.shared.requestedURL = URL(string: "https://a-url.com")
    }
}

class HTTPClinet {
    static let shared = HTTPClinet()
    
    var requestedURL: URL?
    
    private init() {}
}

final class Remote_Feed_Loader_Tests: XCTestCase {

    func test_init_doseNotRequestDataFromURL() {
        let clinet = HTTPClinet.shared
        let _ = RemoteFeedLoader()
        
        XCTAssertNil(clinet.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let clinet = HTTPClinet.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(clinet.requestedURL)
    }
    
}
