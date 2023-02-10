//
//  RemoteFeedLoaderTest.swift
//  NetworkLayerTests
//
//  Created by Mohamed Ahmed on 2/10/23.
//

import XCTest
 
class RemoteFeedLoader {
    
}

class HTTPClinet {
    var requestedURL: String?
}

final class Remote_Feed_Loader_Tests: XCTestCase {

    func test_init_doseNotRequestDataFromURL() {
        let clinet = HTTPClinet()
        let _ = RemoteFeedLoader()
        
        XCTAssertNil(clinet.requestedURL)
    }
    
}
