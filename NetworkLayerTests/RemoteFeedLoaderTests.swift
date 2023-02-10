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
        
        sut.load {_ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_Twise_requestDataFromURLTwise() {
        let url = URL(string: "https://a-given-url.com")!
        
        let (sut, client) = makeSUT(url: url)
        
        sut.load {_ in }
        sut.load {_ in }
        
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
    
    func test_lead_deliversErrorOnNon200HTTPResponce() {
        let (sut, client) = makeSUT()

        
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load {capturedErrors.append($0)}
            client.complete(statusCode: code, at: index)
            XCTAssertEqual(capturedErrors, [.invalidData])
        } 
    }
    
    //MARK: - hellpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClinetSpy) {
        let client = HTTPClinetSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    class HTTPClinetSpy: HTTPClinet {
        var messages = [(url: URL, completion:(Error?, HTTPURLResponse?) -> Void)]()
        
        var requestedURLs: [URL]  {
            messages.map { $0.url }
        }
        
        func get(with url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error, nil)
        }
        
        func complete(statusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: messages[index].url, statusCode: code, httpVersion: nil, headerFields: nil)
            messages[index].completion(nil, response)
        }
    }

    
}
