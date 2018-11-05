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
import Foundation
@testable import Commander

var sharedOptions: TestsCommand.Options = .init(target: "", verbose: false)

struct TestsCommand: CommandRepresentable {
  struct Options: OptionsRepresentable {
    enum CodingKeys: String, CodingKeysRepresentable {
      case target
      case verbose
    }
    static var keys: [TestsCommand.Options.CodingKeys : Character] = [
      .target: "t",
      .verbose: "v"
    ]
    static var descriptions: [TestsCommand.Options.CodingKeys: OptionDescription] = [
      .target: .default(value: "Default", usage: "The target of the test command"),
      .verbose: .default(value: false, usage: "verbose")
    ]
    let target: String
    let verbose: Bool
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
      .target: .default(value: "Default", usage: "The target of the test command")
    ]
    let target: String
  }
  static let subcommands: [AnyCommandRepresentable.Type] = [
    TestsCommand.self
  ]
  static let symbol: String = "test-args"
  static var usage: String = "Mocked command for tests args"
  
  static func main(_ options: Options) throws {
    
  }
}

class CommandTests: XCTestCase {
  static var allTests = [
    ("testCommand", testCommand),
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
    Commander().dispatch()
    XCTAssertEqual(dispatchFailure(), EXIT_FAILURE)
    
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
  
  func testListCommand() {
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "list", "--type=command"]))
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "list", "test-args", "--type=command"]))
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "list", "--type=options"]))
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "list", "test", "--type=options"]))
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "list", "--type=optionsS"]))
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "list", "test-args", "--type=optionsS"]))
    
    var outputs = String()
    Commander.outputHandler = { outputs += $0.trimmingCharacters(in: .newlines) }; defer { Commander.outputHandler = nil }

    try! Commander().dispatch(with: ["commander", "list", "--type=command"])
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args".split(separator: " ").set); outputs = ""

    try! Commander().dispatch(with: ["commander", "list", "test-args", "--type=command"])
    XCTAssertEqual(outputs.split(separator: " ").set, "test -T --target".split(separator: " ").set); outputs = ""
    
    try! Commander().dispatch(with: ["commander", "list", "--type=options"])
    XCTAssertEqual(outputs, ""); outputs = ""
    
    try! Commander().dispatch(with: ["commander", "list", "test", "--type=options"])
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --verbose".split(separator: " ").set); outputs = ""
    
    try! Commander().dispatch(with: ["commander", "list", "test-args", "--type=optionsS"])
    XCTAssertEqual(outputs.split(separator: " ").set, "-T --target".split(separator: " ").set); outputs = ""
  }
  
  func testCompleteCommand() {
    var outputs = String()
    Commander.outputHandler = { outputs += $0.trimmingCharacters(in: .newlines) }; defer { Commander.outputHandler = nil }
    
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "generate", "--shell=bash"]))
    XCTAssertEqual(outputs.isEmpty, false); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete"]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", ""]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander h"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander he"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander hel"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander help"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "test test-args".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander help "]))
    XCTAssertEqual(outputs.split(separator: " ").set, "test test-args".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander help t"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "test test-args".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander help test"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "test-args".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander help test-args"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "test".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander help test test-args"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander te"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander tes"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "-t -v --target --verbose".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test "]))
    XCTAssertEqual(outputs.split(separator: " ").set, "-t -v --target --verbose".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test -"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "-t -v --target --verbose".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test -t"]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test -t "]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test -t s"]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test --"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --verbose".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test --t"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --verbose".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test --ta"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --verbose".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test --tar"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --verbose".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test --targ"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --verbose".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test --targe"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --verbose".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test --target"]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test --target "]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test --target s"]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test-"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test-a"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test-ar"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test-arg"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test-args"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "test -T --target".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test-args "]))
    XCTAssertEqual(outputs.split(separator: " ").set, "test -T --target".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test-args u"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "test -T --target".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test-args -"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "-T --target".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test-args --"]))
    XCTAssertEqual(outputs, "--target"); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test-args --t"]))
    XCTAssertEqual(outputs, "--target"); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test-args --ta"]))
    XCTAssertEqual(outputs, "--target"); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test-args --tar"]))
    XCTAssertEqual(outputs, "--target"); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test-args --targ"]))
    XCTAssertEqual(outputs, "--target"); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test-args --targe"]))
    XCTAssertEqual(outputs, "--target"); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test-args --target"]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test-args --target "]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "complete", "commander test-args --target s"]))
    XCTAssertEqual(outputs, ""); outputs = ""
  }
  
  func testHelpCommand() {    
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "help"]))
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "--help"]))
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "-h"]))
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "help", "test"]))
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "test", "-h"]))
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "test", "--help"]))
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "help", "test-args"]))
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "test-args", "-h"]))
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "test-args", "test", "-h"]))
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "test-args", "--help"]))
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "test-args", "test", "--help"]))
    
    XCTAssertTrue(Help.validate(options: ["h"]))
    XCTAssertTrue(Help.validate(options: ["help"]))
    XCTAssertFalse(Help.validate(options: ["h", "h"]))
    
    do {
      try Commander().dispatch(with: ["commander", "help", "--help"])
      XCTFail()
    } catch CommanderError.unrecognizedOptions(let options, path: let path) {
      XCTAssertTrue(true)
      XCTAssertEqual(options, ["help"])
      XCTAssertFalse(CommanderError.unrecognizedOptions(options, path: path).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try Commander().dispatch(with: ["commander", "help", "-h"])
      XCTFail()
    } catch CommanderError.unrecognizedOptions(let options, path: let path) {
      XCTAssertTrue(true)
      XCTAssertEqual(options, ["h"])
      XCTAssertFalse(CommanderError.unrecognizedOptions(options, path: path).description.isEmpty)
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
    
    do {
      try Commander().dispatch(with: ["commander", "fake", "-s"])
      XCTFail()
    } catch CommanderError.invalidCommand(command: let command) {
      XCTAssertTrue(true)
      XCTAssertEqual(command, "fake")
      XCTAssertFalse(CommanderError.invalidCommand(command: command).description.isEmpty)
    } catch {
      XCTFail()
    }
  }
  
  func testSubcommands() {
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "test-args"]))
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "test-args", "test"]))
    
    XCTAssertNoThrow(try Commander().dispatch(with: ["commander", "test-args", "test", "--target", "The target"]))
    
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
}
