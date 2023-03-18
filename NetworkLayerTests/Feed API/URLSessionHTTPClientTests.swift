//
//  URLSessionHTTPClientTests.swift
//  NetworkLayerTests
//
//  Created by Mohamed Ahmed on 3/16/23.
//

import XCTest
import NetworkLayer

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {
     private let session: HTTPSession

     init(session: HTTPSession) {
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

     func test_getFromURL_resumeDataTaskWithURL() {
         let url = URL(string: "http://any-url.com")!
         let task = HTTPSessionTaskSpy()
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
     
     private class URLSessionSpy: HTTPSession {
         
         private var stubs = [URL: Stub]()
         
         private struct Stub {
             var task: HTTPSessionTask
             var error: Error?
         }
         
         func stub(url: URL, task: HTTPSessionTask = FakeURLSessionDataTask(), error: Error? = nil) {
             stubs[url] = Stub(task: task, error: error)
         }

        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
             guard let stub = stubs[url] else {
                 fatalError("could not fild stub for \(url)")
             }
             completionHandler(nil, nil, stub.error)
             return stub.task
         }
     }

     private class FakeURLSessionDataTask: HTTPSessionTask {
        func resume() {}
     }
     
     private class HTTPSessionTaskSpy: HTTPSessionTask {
         var resumeCountCall = 0
         
        func resume() {
             resumeCountCall += 1
         }
     }

 }
