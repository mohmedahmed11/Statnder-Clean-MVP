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

     init(session: URLSession) {
         self.session = session
     }

    func get(from url: URL, compeletion: @escaping (HTTPClientResult) -> Void) {
         session.dataTask(with: url) { _, _, error in
             if let error = error {
                 compeletion(.failuer(error))
             }
         }.resume()
     }
 }

 class URLSessionHTTPClientTests: XCTestCase {

     func test_getFromURL_resumeDataTaskWithURL() {
         let url = URL(string: "http://any-url.com")!
         let task = URLSessionDataTaskSpy()
         let session = URLSessionSpy()
         session.stub(url: url, task: task)
         
         let sut = URLSessionHTTPClient(session: session)
         
         sut.get(from: url) { _ in }

         XCTAssertEqual(task.resumeCountCall, 1)
     }
     
     func test_getFromURL_failsOnRequestError() {
         let url = URL(string: "http://any-url.com")!
         let error = NSError(domain: "any error", code: 1)
         let session = URLSessionSpy()
         
         session.stub(url: url, error: error)
         
         let sut = URLSessionHTTPClient(session: session)
         let exp = expectation(description: "waite for completion")
         
         sut.get(from: url) { result in
             switch result {
             case let .failuer(recivedError as NSError):
                 XCTAssertEqual(recivedError, error)
             default:
                 XCTFail("expected failuer with \(error) but we go \(result) instade")
                 
             }
             exp.fulfill()
         }
         
         wait(for: [exp], timeout: 1.0)

     }

     // MARK: - Helpers
     
     private class URLSessionSpy: URLSession {
         
         private var stubs = [URL: Stub]()
         
         private struct Stub {
             var task: URLSessionDataTask
             var error: Error?
         }
         
         func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
             stubs[url] = Stub(task: task, error: error)
         }

         override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
             guard let stub = stubs[url] else {
                 fatalError("could not fild stub for \(url)")
             }
             completionHandler(nil, nil, stub.error)
             return stub.task
         }
     }

     private class FakeURLSessionDataTask: URLSessionDataTask {
         override func resume() {}
     }
     
     private class URLSessionDataTaskSpy: URLSessionDataTask {
         var resumeCountCall = 0
         
         override func resume() {
             resumeCountCall += 1
         }
     }

 }
