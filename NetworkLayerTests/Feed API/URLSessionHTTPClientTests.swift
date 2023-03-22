//
//  URLSessionHTTPClientTests.swift
//  NetworkLayerTests
//
//  Created by Mohamed Ahmed on 3/16/23.
//

import XCTest
import NetworkLayer

class URLSessionHTTPClient {
     private let session: URLSession
    
    struct UnexpectedValuesRepresentation: Error {}

    init(session: URLSession = .shared) {
         self.session = session
     }

    func get(from url: URL, compeletion: @escaping  (HTTPClientResult) -> Void) {
         session.dataTask(with: url) { data, response, error in
             if let error = error {
                 compeletion(.failuer(error))
             }else if let data = data, let response = response as? HTTPURLResponse {
                 compeletion(.success(response, data))
             } else {
                 compeletion(.failuer(UnexpectedValuesRepresentation()))
             }
         }.resume()
     }
 }

 class URLSessionHTTPClientTests: XCTestCase {
     
     override func setUp() {
         super.setUp()
         URLProtocolStub.startInterceptingRequests()
     }
     
     override func tearDown() {
         super.tearDown()
         URLProtocolStub.stopInterceptingRequests()
     }
     
     func test_getFromURL_performGETRequestWithURL() {
         let url = anyURL()
         let exp = expectation(description: "waite for completion")
         
         URLProtocolStub.observeRequests { request in
             XCTAssertEqual(request.url, url)
             XCTAssertEqual(request.httpMethod , "GET")
             exp.fulfill()
         }
         
         makeSUT().get(from: url) { _ in }
         
         wait(for: [exp], timeout: 1.0)
     }

     func test_getFromURL_failsOnRequestError() {
         let requestError = anyNSError()
         
         let recivedError = resultErrorFor(data: nil, response: nil, error: requestError)
         
         XCTAssertNotNil(recivedError)
     }
     
     func test_getFromURL_failsOnAllInvaliedRepresentaionCases() {
         XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
         XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(),  error: nil))
         XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
         XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
         XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
         XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
         XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
         XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
         XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
     }
     
     func test_getFromURL_suceedsOnHTTPURLResponseWithData() {
         let data = anyData()
         let response = anyHTTPURLResponse()
         let recivedValues = resultValuesFor(data: data, response: response, error: nil)
         
         XCTAssertEqual(recivedValues?.data, data)
         XCTAssertEqual(recivedValues?.response.url, response.url)
         XCTAssertEqual(recivedValues?.response.statusCode, response.statusCode)
     }
     
     func test_getFromURL_suceedsWithEmptyDataOnHTTPURLResponseWithNilData() {
         let response = anyHTTPURLResponse()
         let recivedValues = resultValuesFor(data: nil, response: response, error: nil)
 
         let emptyData = Data()
         XCTAssertEqual(recivedValues?.data, emptyData)
         XCTAssertEqual(recivedValues?.response.url, response.url)
         XCTAssertEqual(recivedValues?.response.statusCode, response.statusCode)
   
     }

     // MARK: - Helpers
     
     private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient{
         let sut = URLSessionHTTPClient()
         trackForMemoryLeaks(sut, file: file, line: line)
         return sut
     }
     
     private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
         let result = resultFor(data: data, response: response, error: error, file: file, line: line)

         switch result {
         case let .success(response, data):
             return (data, response)
         default:
             XCTFail("expected success but we go \(result) instade", file: file, line: line)
             return nil
         }
     }
     
     private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
         let result = resultFor(data: data, response: response, error: error, file: file, line: line)
         
         switch result {
         case let .failuer(error):
             return error
         default:
             XCTFail("expected failuer  but we go \(result) instade", file: file, line: line)
             return nil
         }
         
     }
     
     private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> HTTPClientResult {
         URLProtocolStub.stub(data: data, response: response, error: error)
         let sut = makeSUT(file: file, line: line)
         let exp = expectation(description: "waite for completion")
         
         var recivedResult: HTTPClientResult!
         sut.get(from: anyURL()) { result in
             recivedResult = result
             exp.fulfill()
         }
         
         wait(for: [exp], timeout: 1.0)
         return recivedResult
     }
     
     private func anyURL() -> URL {
         return URL(string: "https://any-url.com")!
     }
     
     private func anyData() -> Data {
         return Data("any data".utf8)
     }
     
     private func anyNSError() -> NSError {
         return NSError(domain: "any error", code: 1)
     }
     
     private func anyHTTPURLResponse() -> HTTPURLResponse {
         return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
     }
     
     private func nonHTTPURLResponse() -> URLResponse {
         return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
     }
     
     private class URLProtocolStub: URLProtocol {
         
         private static var stub: Stub?
         private static var requestObserve: ((URLRequest) -> Void)?
         
         private struct Stub {
             var data: Data?
             var response: URLResponse?
             var error: Error?
         }
         
         static func observeRequests(observe: @escaping (URLRequest) -> Void) {
             requestObserve = observe
         }
         
         static func startInterceptingRequests() {
             URLProtocol.registerClass(URLProtocolStub.self)
         }
         
         static func stopInterceptingRequests() {
             URLProtocol.unregisterClass(URLProtocolStub.self)
             stub = nil
             requestObserve = nil
         }
         
         static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
             stub = Stub(data: data, response: response, error: error)
         }
         
         override class func canInit(with request: URLRequest) -> Bool {
             requestObserve?(request)
             return true
         }
         
         override class func canonicalRequest(for request: URLRequest) -> URLRequest {
             return request
         }
         
         override func startLoading() {
             
             if let error = URLProtocolStub.stub?.error {
                 client?.urlProtocol(self, didFailWithError: error)
             }
             
             if let data = URLProtocolStub.stub?.data {
                 client?.urlProtocol(self, didLoad: data)
             }
             
             if let response = URLProtocolStub.stub?.response {
                 client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed )
             }
             
             client?.urlProtocolDidFinishLoading(self)
         }
         
         override func stopLoading() {}

     }

 }
