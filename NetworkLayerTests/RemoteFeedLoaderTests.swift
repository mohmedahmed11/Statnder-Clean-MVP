//
//  RemoteFeedLoaderTest.swift
//  NetworkLayerTests
//
//  Created by Mohamed Ahmed on 2/10/23.
//

import XCTest
 
class RemoteFeedLoader {
    let client: HTTPClinet
    
    init(client: HTTPClinet) {
        self.client = client
    }
    
    func load() {
        client.get(with: URL(string: "https://a-url.com")!)
    }
}

protocol HTTPClinet {
    func get(with url: URL)
}

class HTTPClinetSpy: HTTPClinet {
    
    var requestedURL: URL?
    
    func get(with url: URL) {
        requestedURL = url
    }
}

final class Remote_Feed_Loader_Tests: XCTestCase {

    func test_init_doseNotRequestDataFromURL() {
        let clinet = HTTPClinetSpy()
        let _ = RemoteFeedLoader(client: clinet)
        
        XCTAssertNil(clinet.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let clinet = HTTPClinetSpy()
        let sut = RemoteFeedLoader(client: clinet)
        
        sut.load()
        
        XCTAssertNotNil(clinet.requestedURL)
    }
    
}
