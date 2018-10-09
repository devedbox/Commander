//
//  CommandTests.swift
//  CommanderTests
//
//  Created by devedbox on 2018/10/6.
//
//  Copyright (c) 2018 devedbox
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
@testable import Commander

var sharedOptions: TestsCommand.Options = .init(target: "")

struct TestsCommand: CommandRepresentable {
  struct Options: OptionsRepresentable {
    enum CodingKeys: String, CodingKeysRepresentable {
      case target
    }
    static var keys: [TestsCommand.Options.CodingKeys : Character] = [:]
    static var descriptions: [TestsCommand.Options.CodingKeys: OptionDescription] = [
      .target: .usage("The target of the test command")
    ]
    let target: String
  }
  
  static let symbol: String = "test"
  static var usage: String = "Mocked command for tests"
  
  static func main(_ options: TestsCommand.Options) throws {
    
  }
}

struct TestsArgsCommand: CommandRepresentable {
  struct Options: OptionsRepresentable {
    typealias ArgumentsResolver = AnyArgumentsResolver<[String: UInt8]>
    enum CodingKeys: String, CodingKeysRepresentable {
      case target
    }
    static var keys: [TestsArgsCommand.Options.CodingKeys : Character] = [
      .target: "T"
    ]
    static var descriptions: [Options.CodingKeys: OptionDescription] = [
      .target: .usage("The target of the test command")
    ]
    let target: String
  }
  
  static let symbol: String = "test-args"
  static var usage: String = "Mocked command for tests args"
  
  static func main(_ options: Options) throws {
    
  }
}

class CommandTests: XCTestCase {
  static var allTests = [
    ("testHelpCommand", testHelpCommand),
  ]
  
  override func setUp() {
    Commander.commands = [
      TestsCommand.self,
      TestsArgsCommand.self
    ]
    Commander.usage = "Mocked usage"
  }
  
  func testCommand() {
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "test", "--target", "The target"]))
    
    do {
      try Commander().dispatch(with: ["commander"])
      XCTFail()
    } catch CommanderError.emptyCommand {
      XCTAssertTrue(true)
      XCTAssertFalse(CommanderError.emptyCommand.description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try Commander().dispatch(with: ["commander", "command"])
      XCTFail()
    } catch CommanderError.invalidCommand(command: let command) {
      XCTAssertTrue(true)
      XCTAssertEqual(command, "command")
      XCTAssertFalse(CommanderError.invalidCommand(command: command).description.isEmpty)
    } catch {
      XCTFail()
    }
  }
  
  func testHelpCommand() {    
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "help"]))
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "--help"]))
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "-h"]))
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "help", "test"]))
    
    do {
      try Commander().dispatch(with: ["commander", "help", "--help"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options) {
      XCTAssertTrue(true)
      XCTAssertEqual(options, ["help"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try Commander().dispatch(with: ["commander", "help", "-h"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options) {
      XCTAssertTrue(true)
      XCTAssertEqual(options, ["h"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try Commander().dispatch(with: ["commander", "help", "command"])
      XCTFail()
    } catch CommanderError.helpUnrecognizedCommands(commands: let commands) {
      XCTAssertTrue(true)
      XCTAssertEqual(commands, ["command"])
      XCTAssertFalse(CommanderError.helpUnrecognizedCommands(commands: commands).description.isEmpty)
    } catch {
      XCTFail()
    }
  }
}
