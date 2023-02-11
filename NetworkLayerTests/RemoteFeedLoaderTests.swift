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
        expect(sut, toCompleteWith: .failuer(.connectivity)) {
            let clinetError = NSError(domain: "test", code: 0)
            client.complete(with: clinetError)
        }
    }
    
    func test_lead_deliversErrorOnNon200HTTPResponce() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failuer(.invalidData)) {
                client.complete(statusCode: code, at: index)
            }
        } 
    }
    
    func test_lead_deliversErrorOn200HTTPResponce() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .failuer(.invalidData)) {
            let invaledData = Data("invaled data".utf8)
            client.complete(statusCode: 200,data: invaledData)
        }
    }
    
    func test_lead_deliversNoItemsOn200HTTPResponceWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = Data("[]".utf8)
            client.complete(statusCode: 200,data: emptyListJSON)
        }
    }
    
    
    
    func test_lead_deliversItemsOn200HTTPResponceWithJSONList() {
        let (sut, client) = makeSUT()
        
        let item1 = FeedItem(id: UUID(), description: nil, location: nil, imageUrl: URL(string: "https://a-url.com")!)
        let item1JSON = [
            "id": item1.id.uuidString,
            "image": item1.imageUrl.absoluteString
        ]
        
        let item2 = FeedItem(id: UUID(), description: "a description", location: "a location", imageUrl: URL(string: "https://another-url.com")!)
        let item2JSON = [
            "id": item2.id.uuidString,
            "description": item2.description,
            "location": item2.location,
            "image": item2.imageUrl.absoluteString
        ]
        
        let itemsJSON = [item1JSON, item2JSON]
        
        expect(sut, toCompleteWith: .success([item1, item2])) {
            let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
            client.complete(statusCode: 200,data: json)
        }
    }
    
    
    //MARK: - hellpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClinetSpy) {
        let client = HTTPClinetSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
       
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load {capturedResults.append($0)}
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    class HTTPClinetSpy: HTTPClinet {
        var messages = [(url: URL, completion:(HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL]  {
            messages.map { $0.url }
        }
        
        func get(with url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failuer(error))
        }
        
        func complete(statusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(response, data))
        }
    }

    
}
