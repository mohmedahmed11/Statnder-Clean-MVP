//
//  RemoteFeedLoaderTest.swift
//  NetworkLayerTests
//
//  Created by Mohamed Ahmed on 2/10/23.
//

import XCTest
 
class RemoteFeedLoader {
    func load() {
        HTTPClinet.shared.get(with: URL(string: "https://a-url.com")!)
    }
}

class HTTPClinet {
    static var shared = HTTPClinet()
    
    func get(with url: URL) {}
}

class HTTPClinetSpy: HTTPClinet {
    
    var requestedURL: URL?
    
    override func get(with url: URL) {
        requestedURL = url
    }
}

final class Remote_Feed_Loader_Tests: XCTestCase {

    func test_init_doseNotRequestDataFromURL() {
        let clinet = HTTPClinetSpy()
        HTTPClinet.shared = clinet
        let _ = RemoteFeedLoader()
        
        XCTAssertNil(clinet.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let clinet = HTTPClinetSpy()
        HTTPClinet.shared = clinet
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(clinet.requestedURL)
    }
    
}
