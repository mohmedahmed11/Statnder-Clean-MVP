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

     func test_getFromURL_failsOnRequestError() {
         URLProtocolStub.startInterceptingRequests()
         let url = URL(string: "https://any-url.com")!
         let error = NSError(domain: "any error", code: 1)
         URLProtocolStub.stub(url: url, data: nil, response: nil, error: error)
         
         let sut = URLSessionHTTPClient()
         
         let exp = expectation(description: "waite for completion")
         
         sut.get(from: url) { result in
             switch result {
             case let .failuer(recivedError as NSError):
                 XCTAssertNotNil(recivedError)
             default:
                 XCTFail("expected failuer with \(error) but we go \(result) instade")
                 
             }
             exp.fulfill()
         }
         
         wait(for: [exp], timeout: 1.0)
         URLProtocolStub.stopInterceptingRequests()
     }

     // MARK: - Helpers
     
     private class URLProtocolStub: URLProtocol {
         
         private static var stubs = [URL: Stub]()
         
         private struct Stub {
             var data: Data?
             var response: URLResponse?
             var error: Error?
         }
         
         static func startInterceptingRequests() {
             URLProtocol.registerClass(URLProtocolStub.self)
         }
         
         static func stopInterceptingRequests() {
             URLProtocol.unregisterClass(URLProtocolStub.self)
             stubs = [:]
         }
         
         static func stub(url: URL, data: Data?, response: URLResponse?, error: Error? = nil) {
             stubs[url] = Stub(data: data, response: response, error: error)
         }
         
         override class func canInit(with request: URLRequest) -> Bool {
             guard let url = request.url else { return false }
             
             return URLProtocolStub.stubs[url] != nil
         }
         
         override class func canonicalRequest(for request: URLRequest) -> URLRequest {
             return request
         }
         
         override func startLoading() {
             guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
             
             if let error = stub.error {
                 client?.urlProtocol(self, didFailWithError: error)
             }
             
             if let data = stub.data {
                 client?.urlProtocol(self, didLoad: data)
             }
             
             if let response = stub.response {
                 client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
             }
             
             client?.urlProtocolDidFinishLoading(self)
         }
         
         override func stopLoading() {}

     }

 }
