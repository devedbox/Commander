//
//  CommandTests.swift
//  CommanderTests
//
//  Created by devedbox on 2018/10/6.
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
    } catch CommanderDecoder.Error.unrecognizedOptions(let options) {
      XCTAssertTrue(true)
      XCTAssertEqual(options, ["help"])
      XCTAssertFalse(CommanderDecoder.Error.unrecognizedOptions(options).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try Commander().dispatch(with: ["commander", "help", "-h"])
      XCTFail()
    } catch CommanderDecoder.Error.unrecognizedOptions(let options) {
      XCTAssertTrue(true)
      XCTAssertEqual(options, ["h"])
      XCTAssertFalse(CommanderDecoder.Error.unrecognizedOptions(options).description.isEmpty)
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
