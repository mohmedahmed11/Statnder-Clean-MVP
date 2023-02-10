//
//  RemoteFeedLoaderTest.swift
//  NetworkLayerTests
//
//  Created by Mohamed Ahmed on 2/10/23.
//

import XCTest
import NetworkLayer

final class Remote_Feed_Loader_Tests: XCTestCase {

    func test_init_doseNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_Twise_requestDataFromURLTwise() {
        let url = URL(string: "https://a-given-url.com")!
        
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url] )
    }
    
    func test_lead_deliversErrorOnClineError() {
        let (sut, client) = makeSUT()

        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load {capturedErrors.append($0)}
        
        let clinetError = NSError(domain: "test", code: 0)
        client.complete(with: clinetError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    //MARK: - hellpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClinetSpy) {
        let client = HTTPClinetSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    class HTTPClinetSpy: HTTPClinet {
        var requestedURLs = [URL]()
        var completions = [(Error) -> Void]()
        
        func get(with url: URL, completion: @escaping (Error) -> Void) {
            completions.append(completion)
            requestedURLs.append(url)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](error)
        }
    }

    
}
