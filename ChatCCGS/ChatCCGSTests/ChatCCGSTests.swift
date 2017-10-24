//
//  ChatCCGSTests.swift
//  ChatCCGSTests
//
//  Created by Marcus Handley on 1/8/17.
//  Copyright © 2017 NullPointerAcception. All rights reserved.
//

import XCTest
@testable import ChatCCGS

class ChatCCGSTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testUnicodeDetection() {
        XCTAssertFalse(RequestHelper.doesContainNonUnicode(message: "ThisShould\"Not Contain any n0n unicode characters"));
        XCTAssertTrue(RequestHelper.doesContainNonUnicode(message: "This should be 👍 because of the 👍"))
        XCTAssertTrue(RequestHelper.doesContainNonUnicode(message: "This containing \"⇒\" ⇒ this should be True"))
        
    }
}
