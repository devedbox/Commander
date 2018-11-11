//
//  CommandLineTests.swift
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

class CommandLineTests: XCTestCase {
  static let allTests = [
    ("testParsing", testParsing),
  ]
  
  func testParsing() {
    var cli = ["commander", "command  ", "subcommand", "--option   ", "-f", "  value"]
    var commandLine = CommandLine(cli.joined(separator: " "))
    
    XCTAssertEqual(commandLine.argc, Int32(cli.count - 1))
    XCTAssertEqual(Set(commandLine.arguments), ["commander", "command", "subcommand", "--option", "-f", "value"])
    XCTAssertEqual(commandLine.arguments, ["commander", "command", "subcommand", "--option", "-f", "value"])
    
    cli = ["commander", "command", "subcmd", "\"args: val0 val1 val3\""]
    commandLine = CommandLine(cli.joined(separator: " "))
    
    XCTAssertEqual(commandLine.argc, Int32(cli.count - 1))
    XCTAssertEqual(Set(commandLine.arguments), Set(cli.map { $0.replacingOccurrences(of: "\"", with: "") }))
    XCTAssertEqual(commandLine.arguments, cli.map { $0.replacingOccurrences(of: "\"", with: "") })
    
    cli = ["  commander", "command ", "  subcmd", "args:\\ val0\\ val1\\ val3"]
    commandLine = CommandLine(cli.joined(separator: " "))
    
    XCTAssertEqual(commandLine.argc, 3)
    XCTAssertEqual(Set(commandLine.arguments), ["commander", "command", "subcmd", "args: val0 val1 val3"])
    XCTAssertEqual(commandLine.arguments, ["commander", "command", "subcmd", "args: val0 val1 val3"])
    
    cli = ["commander  ", " command", " subcmd", "'args: val0   val1 val3'"]
    commandLine = CommandLine(cli.joined(separator: " "))
    
    XCTAssertEqual(commandLine.argc, Int32(cli.count - 1))
    XCTAssertEqual(Set(commandLine.arguments), ["commander", "command", "subcmd", "args: val0   val1 val3"])
    XCTAssertEqual(commandLine.arguments, ["commander", "command", "subcmd", "args: val0   val1 val3"])
    
  }
}
