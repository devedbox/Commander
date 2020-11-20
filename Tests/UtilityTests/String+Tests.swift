//
//  String+Tests.swift
//  UtilityTests
//
//  Created by devedbox on 2018/11/10.
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

class StringPlusTests: XCTestCase {
  static let allTests = [
    ("testMerging", testMerging),
    ("testCamelcase2dashcase", testCamelcase2dashcase),
  ]
  
  func testMerging() {
    let long = "1234567890"
    let short = "abcdef"
    let merged = "abcdef7890"
    
    XCTAssertEqual(merged, long.merging(short))
    XCTAssertEqual(merged, short.merging(long))
  }
  
  func testCamelcase2dashcase() {
    XCTAssertEqual("stringValue".camelcase2dashcase(), "string-value")
    XCTAssertEqual("stringVAlue".camelcase2dashcase(), "string-v-alue")
    XCTAssertEqual("stringVALue".camelcase2dashcase(), "string-v-a-lue")
    XCTAssertEqual("stringVALUe".camelcase2dashcase(), "string-v-a-l-ue")
    XCTAssertEqual("stringVALUE".camelcase2dashcase(), "string-v-a-l-u-e")
    
    XCTAssertEqual("StringValue".camelcase2dashcase(), "string-value")
    XCTAssertEqual("STringValue".camelcase2dashcase(), "s-tring-value")
    XCTAssertEqual("STRingValue".camelcase2dashcase(), "s-t-ring-value")
    XCTAssertEqual("STRIngValue".camelcase2dashcase(), "s-t-r-ing-value")
    XCTAssertEqual("STRINgValue".camelcase2dashcase(), "s-t-r-i-ng-value")
    XCTAssertEqual("STRINGValue".camelcase2dashcase(), "s-t-r-i-n-g-value")
  }
}
