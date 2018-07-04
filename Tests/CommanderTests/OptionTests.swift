//
//  OptionTests.swift
//  CommanderTests
//
//  Created by devedbox on 2018/7/4.
//

import XCTest
@testable import Commander

internal func XCTOptionRawAssertEqual(_ optionRaws: [Option.RawValue], option: Option) {
    XCTAssertEqual(optionRaws.first!, option.option)
}

internal func XCTOptionScopesAssertEqual(_ optionRaws: [Option.RawValue], option: Option) {
    var optionRaws = optionRaws; optionRaws.remove(at: 0)
    XCTAssertEqual(optionRaws, option.scopes)
}

class OptionTests: XCTestCase {
    static var allTests = [
        ("testExample", testExample),
    ]
    
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
    
    func testSimleOptionArrayLiteral() {
        var options = ["--option"]
        
        XCTOptionRawAssertEqual(options, option: try! Option(optionRaws: options))
        XCTOptionScopesAssertEqual(options, option: try! Option(optionRaws: options))
        
        options = ["---option"]
        do {
            _ = try Option(option: options.last!)
            XCTAssertFalse(true)
        } catch CommanderError.option(.invalidPattern(pattern: _, rawValue: _)) {
            XCTAssertTrue(true)
        } catch _ {
            XCTAssertFalse(true)
        }
        
        options = ["-o"]
        do {
            _ = try Option(option: options.last!)
            XCTAssertTrue(true)
        } catch _ {
            XCTAssertFalse(true)
        }
        
        options = ["-ou"]
        do {
            _ = try Option(option: options.last!)
            XCTAssertTrue(true)
        } catch _ {
            XCTAssertFalse(true)
        }
    }
}
