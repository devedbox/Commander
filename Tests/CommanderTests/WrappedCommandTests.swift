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
import Utility

var wrappedSharedOptions: WrappedTestsCommand.Options = .init()

struct WrappedTestsCommand: CommandRepresentable {
  struct Options: OptionsRepresentable, OptionsPropertyWrapper {
    typealias Argument = String
    
    @Option(k: "t", usage: "The target of the test command")
    var target: String = "Default"
    @Option(k: "v", usage: "verbose")
    var verbose: Bool = false
    
    init() { }
    
    public static func completions(for commandLine: Utility.CommandLine) -> [String] {
      switch commandLine.arguments.last {
      case "--target", "-t":
        return [
          "target0",
          "target1"
        ]
      case "--verbose", "-v": fallthrough
      default:
        return [
          "arg0",
          "arg1",
          "arg2"
        ]
      }
    }
  }
  
  static let symbol: String = "test"
  static var usage: String = "Mocked command for tests"
  
  static func main(_ options: Options) throws {
    
  }
}

struct WrappedTestsArgsCommand: CommandRepresentable {
  struct Options: OptionsRepresentable, OptionsPropertyWrapper {
    typealias Argument = [String: UInt8]
    
    @Option(k: "T", usage: "The target of the test command")
    var target: String = "Default"
    
    init() {
    }
    
    public static func completions(for commandLine: Utility.CommandLine) -> [String] {
      switch commandLine.arguments.last {
      case "--target":
        return [
          "target0",
          "target1",
          "target2",
          "target3",
        ]
      default:
        return ["a", "b", "c"]
      }
    }
  }
  static let children: [CommandDispatchable.Type] = [
    TestsCommand.self
  ]
  static let symbol: String = "test-args"
  static var usage: String = "Mocked command for tests args"
  
  static func main(_ options: Options) throws {
    
  }
}

class WrappedCommandTests: XCTestCase {
  static var allTests = [
    ("testCommand", testCommand),
    ("testHelpCommand", testHelpCommand),
  ]
  
  override func setUp() {
    BuiltIn.Commander.commands = [
      WrappedTestsCommand.self,
      WrappedTestsArgsCommand.self
    ]
    BuiltIn.Commander.usage = "Mocked usage"
  }
  
  func testCommand() {
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "test", "--verbose", "--target", "The target"]))
    BuiltIn.Commander().dispatch()
    XCTAssertEqual(dispatchSuccess(), EXIT_SUCCESS)
    XCTAssertEqual(dispatchFailure(), EXIT_FAILURE)
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander"])
      XCTFail()
    } catch Commander.Error.emptyCommand {
      XCTAssertTrue(true)
      XCTAssertFalse(Commander.Error.emptyCommand.description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "command"])
      XCTFail()
    } catch Commander.Error.invalidCommand(command: let command) {
      XCTAssertTrue(true)
      XCTAssertEqual(command, "command")
      XCTAssertFalse(Error.invalidCommand(command: command).description.isEmpty)
    } catch {
      XCTFail()
    }
  }
  
  func testCompleteCommand() {
    var outputs = String()
    BuiltIn.Commander.outputHandler = { outputs += $0.trimmingCharacters(in: .newlines) }; defer { BuiltIn.Commander.outputHandler = nil }
    
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "generate", "--shell=bash"]))
    XCTAssertEqual(outputs.isEmpty, false); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "generate", "--shell=zsh"]))
    XCTAssertEqual(outputs.isEmpty, false); outputs = ""
    XCTAssertThrowsError(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "generate", "--shell=fish"]))
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "complete", "generate", "--shell=fish"])
      XCTFail()
    } catch Complete.Generate.Error.fishCompletionIsNotSupportedForNow {
      XCTAssertTrue(true)
      XCTAssertFalse(Complete.Generate.Error.fishCompletionIsNotSupportedForNow.description.isEmpty)
    } catch {
      XCTFail()
    }
    XCTAssertEqual(outputs.isEmpty, true); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete"]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", ""]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args -h --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander h"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args -h --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander he"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args -h --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander hel"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args -h --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander help"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "test test-args".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander help "]))
    XCTAssertEqual(outputs.split(separator: " ").set, "test test-args".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander help t"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "test test-args".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander help test"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "test-args".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander help test-args"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "test".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander help test test-args"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander", "help", "test", "test-args"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander te"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args -h --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander tes"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args -h --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "-t -v --target --verbose -h --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test "]))
    XCTAssertEqual(outputs.split(separator: " ").set, "-t -v --target --verbose -h --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test -"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "-t -v --target --verbose -h --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test -t"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "target0 target1".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test -t "]))
    XCTAssertEqual(outputs.split(separator: " ").set, "target0 target1".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test -t s"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "arg0 arg1 arg2".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test -h"]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test -h "]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test -h -"]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test --"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --verbose --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test --t"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --verbose --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test --ta"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --verbose --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test --tar"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --verbose --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test --targ"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --verbose --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test --targe"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --verbose --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test --target"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "target0 target1".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test --target "]))
    XCTAssertEqual(outputs.split(separator: " ").set, "target0 target1".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test --target -"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "-t -v --target --verbose".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test --target --"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --verbose".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test --help"]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test --help "]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test --help -"]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test -h"]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test -h "]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test -h -"]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args -h --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-a"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args -h --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-ar"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args -h --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-arg"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "help test test-args -h --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-args"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "test -T --target -h --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-args "]))
    XCTAssertEqual(outputs.split(separator: " ").set, "test -T --target -h --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-args u"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "test -T --target -h --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-args -"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "-T --target -h --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-args --"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-args --t"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-args --ta"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-args --tar"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-args --targ"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-args --targe"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "--target --help".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-args --target"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "target0 target1 target2 target3".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-args --target "]))
    XCTAssertEqual(outputs.split(separator: " ").set, "target0 target1 target2 target3".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-args --target s"]))
    XCTAssertEqual(outputs.split(separator: " ").set, "a b c".split(separator: " ").set); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-args --help"]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-args --help "]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-args --help -"]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-args -h"]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-args -h "]))
    XCTAssertEqual(outputs, ""); outputs = ""
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "complete", "commander test-args -h -"]))
    XCTAssertEqual(outputs, ""); outputs = ""
  }
  
  func testHelpCommand() {    
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "help"]))
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "--help"]))
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "-h"]))
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "help", "test"]))
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "test", "-h"]))
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "test", "--help"]))
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "help", "test-args"]))
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "test-args", "-h"]))
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "test-args", "test", "-h"]))
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "test-args", "--help"]))
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "test-args", "test", "--help"]))
    
    XCTAssertTrue(Help.Options.validate("h"))
    XCTAssertTrue(Help.Options.validate("help"))
    XCTAssertTrue(Help.Options.validate("-h"))
    XCTAssertTrue(Help.Options.validate("--help"))
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "-h", "-t"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let decoder, decodeError: let error) {
      XCTAssertEqual(options.set, ["t"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: decoder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "--help", "-t"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let decoder, decodeError: let error) {
      XCTAssertEqual(options.set, ["t"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: decoder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "-h", "t", "a"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedArguments(let args) {
      XCTAssertEqual((args as! [String]).set, ["t", "a"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedArguments(args).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "--help", "t", "a"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedArguments(let args) {
      XCTAssertEqual((args as! [String]).set, ["t", "a"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedArguments(args).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "-h", "-t"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["t"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "-h", "--target"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["target"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "-h", "-v"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["v"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "-h", "--verbose"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["verbose"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "-h", "-v", "-t"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["t", "v"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "--help", "-t"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["t"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "--help", "--target"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["target"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "--help", "-v"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["v"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "--help", "--verbose"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["verbose"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "--help", "-v", "-t"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["t", "v"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "-t", "-h"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["t"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "--target", "-h"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["target"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "-v", "-h"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["v"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "--verbose", "-h"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["verbose"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "-v", "-t", "-h"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["t", "v"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "-t", "--help"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["t"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "--target", "--help"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["target"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "-v", "--help"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["v"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "--verbose", "--help"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["verbose"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "test", "-t", "-v", "--help"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let deocder, decodeError: let error) {
      XCTAssertEqual(options.set, ["t", "v"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: deocder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "help", "--help"])
      XCTFail()
    } catch Commander.Error.unrecognizedOptions(let options, path: let path, underlyingError: let error) {
      XCTAssertTrue(true)
      XCTAssertEqual(options, ["help"])
      XCTAssertFalse(Error.unrecognizedOptions(options, path: path, underlyingError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "help", "-h"])
      XCTFail()
    } catch Commander.Error.unrecognizedOptions(let options, path: let path, underlyingError: let error) {
      XCTAssertTrue(true)
      XCTAssertEqual(options, ["h"])
      XCTAssertFalse(Error.unrecognizedOptions(options, path: path, underlyingError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "help", "command"])
      XCTFail()
    } catch Commander.Error.unrecognizedCommands(commands: let commands) {
      XCTAssertTrue(true)
      XCTAssertEqual(commands, ["command"])
      XCTAssertFalse(Error.unrecognizedCommands(commands: commands).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "fake", "-s"])
      XCTFail()
    } catch Commander.Error.invalidCommand(command: let command) {
      XCTAssertTrue(true)
      XCTAssertEqual(command, "fake")
      XCTAssertFalse(Error.invalidCommand(command: command).description.isEmpty)
    } catch {
      XCTFail()
    }
  }
  
  func testSubcommands() {
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "test-args"]))
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "test-args", "test", "--verbose"]))
    XCTAssertNoThrow(try BuiltIn.Commander().dispatch(with: ["commander", "test-args", "test", "-v", "--target", "The target"]))
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander"])
      XCTFail()
    } catch Commander.Error.emptyCommand {
      XCTAssertTrue(true)
      XCTAssertFalse(Error.emptyCommand.description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try BuiltIn.Commander().dispatch(with: ["commander", "command"])
      XCTFail()
    } catch Commander.Error.invalidCommand(command: let command) {
      XCTAssertTrue(true)
      XCTAssertEqual(command, "command")
      XCTAssertFalse(Error.invalidCommand(command: command).description.isEmpty)
    } catch {
      XCTFail()
    }
  }
}
