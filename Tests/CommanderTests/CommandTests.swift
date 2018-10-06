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
    enum CodingKeys: String, CodingKey, StringRawRepresentable {
      case target
    }
    static var description: [(TestsCommand.Options.CodingKeys, OptionKeyDescription)] = [
      (.target, .usage("The target of the test command"))
    ]
    let target: String
  }
  
  static let symbol: String = "test"
  static var usage: String = "Mocked command for tests"
  
  static func main(_ options: TestsCommand.Options) throws {
    
  }
}

class CommandTests: XCTestCase {
  static var allTests = [
    ("testHelpCommand", testHelpCommand),
  ]
  
  override func setUp() {
    Commander.commands = [
      TestsCommand.self
    ]
    Commander.runningPath = "commander"
  }
  
  func testHelpCommand() {
    XCTAssertNoThrow(try HelpCommand.run(with: []))
  }
}
