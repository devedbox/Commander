//
//  OptionTests.swift
//  CommanderTests
//
//  Created by devedbox on 2018/7/4.
//

import XCTest
@testable import Commander

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

        XCTAssertEqual(options.last!, try Option(raws: options).rawValue)
        
        options = ["---option"]
        do {
            _ = try Option(raws: options)
            XCTAssertFalse(true)
        } catch CommanderError.option(.invalidPattern(pattern: _, rawValue: _)) {
            XCTAssertTrue(true)
        } catch _ {
            XCTAssertFalse(true)
        }

        options = ["-o"]
        do {
            _ = try Option(raws: options)
            XCTAssertTrue(true)
        } catch let error {
            debugPrint(error)
            XCTAssertFalse(true)
        }

        options = ["-ou"]
        do {
            let option = try Option(raws: options)
            debugPrint(option.rawValue)
            XCTAssertTrue(true)
        } catch _ {
            XCTAssertFalse(true)
        }
    }
    
    func testComplexOptionWithScope() {
        var options = "--option someScope"
        var option = Option(rawValue: options)
        
        assertEqual(rawValue: "--option someScope")
        
        XCTAssertEqual(option.rawValue, options)
        XCTAssertEqual(option.scopes.map { $1 }, [["someScope"]])
        
        let option1 = "--option1 scope1"
        let option2 = "--option2 scope2"
        options = option1 + " " + option2
        
        option = Option(rawValue: options)
        
        XCTAssertEqual(option.rawValue, options)
        XCTAssertEqual(option.scopes.map { $1 }, [["scope1"], ["scope2"]])
        
        options = "--option scopeKey=scopeValue"
        option = Option(rawValue: options)
        
        XCTAssertEqual(option.rawValue, options)
        XCTAssertEqual(option.scopes.map { $0.0 }, ["--option"])
        XCTAssertEqual(option.scopes.map { $1 }, [["scopeKey=scopeValue"]])
    }
}

extension OptionTests {
    fileprivate func assertEqual(rawValue: Option.RawValue) {
        let option = Option(rawValue: rawValue)
        XCTAssertEqual(rawValue, option.rawValue)
    }
}
