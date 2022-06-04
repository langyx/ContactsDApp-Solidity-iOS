//
//  ContactsDAppTests.swift
//  ContactsDAppTests
//
//  Created by Yannis LANG on 16/05/2022.
//

import XCTest
import YLKSecurity

class ContactsDAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_YLKSecurity_saveAndGetValue_shouldBeSame() async throws {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomValue = String((0..<Int.random(in: 5...20)).map{ _ in letters.randomElement()! })
        let randomKey = String((0..<Int.random(in: 5...20)).map{ _ in letters.randomElement()! })
        
        try YLKSecurity.save(value: randomValue, for: randomKey)
        let retrievedValue = try await YLKSecurity.getValue(for: randomKey)
        XCTAssertEqual(retrievedValue, randomValue)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
