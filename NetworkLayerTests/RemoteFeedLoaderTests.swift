//
//  RemoteFeedLoaderTest.swift
//  NetworkLayerTests
//
//  Created by Mohamed Ahmed on 2/10/23.
//

import XCTest
 
class RemoteFeedLoader {
    let client: HTTPClinet
    let url: URL
    
    init(url: URL, client: HTTPClinet) {
        self.url = url
        self.client = client
    }
    
    func load() {
        client.get(with: url)
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
        let url = URL(string: "https://a-url.com")!
        let clinet = HTTPClinetSpy()
        let _ = RemoteFeedLoader(url: url, client: clinet)
        
        XCTAssertNil(clinet.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let clinet = HTTPClinetSpy()
        let sut = RemoteFeedLoader(url: url, client: clinet)
        
        sut.load()
        
        XCTAssertEqual(clinet.requestedURL, url )
    }
    
}
