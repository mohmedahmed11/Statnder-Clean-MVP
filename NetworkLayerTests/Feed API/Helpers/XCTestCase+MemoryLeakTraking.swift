//
//  XCTestCase+MemoryLeakTraking.swift
//  NetworkLayerTests
//
//  Created by Mohamed Ahmed on 3/19/23.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, file: file, line: line)
        }
    }
}
