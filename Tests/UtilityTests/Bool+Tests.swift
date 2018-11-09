//
//  Bool+Tests.swift
//  UtilityTests
//
//  Created by devedbox on 2018/11/9.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import XCTest
@testable import Utility

final class BoolPlusTests: XCTestCase {
  static let allTests = [
    ("testTrue", testTrue),
    ("testFalse", testFalse),
    ("testAnd", testAnd),
    ("testOr", testOr),
    ("testToggle", testToggle),
  ]
  
  func testTrue() {
    XCTAssertNotNil(true.true { () })
    XCTAssertNil(false.true { () })
    XCTAssertEqual(true.true { true }, true)
    XCTAssertNotEqual(false.true { true }, true)
  }
  
  func testFalse() {
    XCTAssertNotNil(false.false { () })
    XCTAssertNil(true.false { () })
    XCTAssertEqual(false.false { false }, false)
    XCTAssertNotEqual(true.false { false }, false)
  }
  
  func testAnd() {
    XCTAssertTrue(true.and { true }.and { true })
    XCTAssertFalse(true.and { false }.and { true })
    XCTAssertFalse(true.and { true }.and { false })
    XCTAssertFalse(false.and { true }.and { true })
  }
  
  func testOr() {
    XCTAssertTrue(true.or { true }.or { true })
    XCTAssertTrue(true.or { false }.or { true })
    XCTAssertTrue(true.or { true }.or { false })
    XCTAssertFalse(false.or { false }.or { false })
  }
  
  func testToggle() {
    var bool = true
    bool.toggle()
    XCTAssertFalse(bool)
    bool.toggle()
    XCTAssertTrue(bool)
  }
}
