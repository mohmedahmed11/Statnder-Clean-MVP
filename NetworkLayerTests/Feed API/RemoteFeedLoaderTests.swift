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
        expect(sut, toCompleteWith: failuer(.connectivity)) {
            let clinetError = NSError(domain: "test", code: 0)
            client.complete(with: clinetError)
        }
    }
    
    func test_lead_deliversErrorOnNon200HTTPResponce() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failuer(.invalidData)) {
                let json = makeJSON([])
                client.complete(statusCode: code, data: json, at: index)
            }
        } 
    }
    
    func test_lead_deliversErrorOn200HTTPResponce() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failuer(.invalidData)) {
            let invaledData = Data("invaled data".utf8)
            client.complete(statusCode: 200,data: invaledData)
        }
    }
    
    func test_lead_deliversNoItemsOn200HTTPResponceWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = makeJSON([])
            client.complete(statusCode: 200,data: emptyListJSON)
        }
    }
    
    
    
    func test_lead_deliversItemsOn200HTTPResponceWithJSONList() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: UUID(), imageUrl: URL(string: "https://a-url.com")!)
        
        let item2 = makeItem(id: UUID(), description: "a description", location: "a location", imageUrl: URL(string: "https://another-url.com")!)
        
        let itemsJSON = [item1, item2]
        
        expect(sut, toCompleteWith: .success(itemsJSON.map({$0.model}))) {
            let json = makeJSON(itemsJSON.map({$0.json}))
            client.complete(statusCode: 200,data: json)
        }
    }
    
    func test_lead_doseNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https:any-url.com")!
        let clinet = HTTPClinetSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: clinet)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load {capturedResults.append($0)}
        sut = nil
        clinet.complete(statusCode: 200, data: makeJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    
    //MARK: - hellpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClinetSpy) {
        let client = HTTPClinetSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        return (sut, client)
    }
    
    private func failuer(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failuer(error)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageUrl: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageUrl: imageUrl)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageUrl.absoluteString
        ].compactMapValues({$0})
        
        return (item, json)
    }
    
    private func makeJSON(_ items: [[String: Any]]) -> Data {
        return try! JSONSerialization.data(withJSONObject: items)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
       
        let exp = expectation(description: "Waiting for load completion")
        
        sut.load { recivedResult in
            switch (expectedResult, recivedResult) {
            case let (.success(recivedItems), .success(expectedItems)):
                XCTAssertEqual(recivedItems, expectedItems, file: file, line: line)
                
            case let (.failuer(recivedError as RemoteFeedLoader.Error), .failuer(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(recivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expect Result \(expectedResult) got \(recivedResult) instead")
                
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    class HTTPClinetSpy: HTTPClinet {
        var messages = [(url: URL, completion:(HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL]  {
            messages.map { $0.url }
        }
        
        func get(from url: URL, compeletion: @escaping  (HTTPClientResult) -> Void) {
            messages.append((url, compeletion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failuer(error))
        }
        
        func complete(statusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(response, data))
        }
    }

    
}
