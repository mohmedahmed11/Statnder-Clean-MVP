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

    init(session: URLSession = .shared) {
         self.session = session
     }

    func get(from url: URL, compeletion: @escaping  (HTTPClientResult) -> Void) {
         session.dataTask(with: url) { _, _, error in
             if let error = error {
                 compeletion(.failuer(error))
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
         let url = URL(string: "https://any-url.com")!
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
         let url = URL(string: "https://any-url.com")!
         let error = NSError(domain: "any error", code: 1)
         URLProtocolStub.stub(data: nil, response: nil, error: error)
         
         let exp = expectation(description: "waite for completion")
         
         makeSUT().get(from: url) { result in
             switch result {
             case let .failuer(recivedError as NSError):
                 XCTAssertNotNil(recivedError)
             default:
                 XCTFail("expected failuer with \(error) but we go \(result) instade")
                 
             }
             exp.fulfill()
         }
         
         wait(for: [exp], timeout: 1.0)
     }

     // MARK: - Helpers
     
     private func makeSUT() -> URLSessionHTTPClient{
         return URLSessionHTTPClient()
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
