//
//  CommandPathTests.swift
//  CommanderTests
//
//  Created by devedbox on 2018/10/11.
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

// MARK: - Mocks.

struct Level1Command: CommandRepresentable {
  struct Options: OptionsRepresentable {
    enum CodingKeys: String, CodingKeysRepresentable {
      case value
    }
    static let keys: [Options.CodingKeys : Character] = [:]
    static let descriptions: [Options.CodingKeys : OptionDescription] = [:]
    
    let value: String
  }
  
  static let children: [CommandDispatchable.Type] = [
    Level2Command.self,
    Level3Command.self,
    Level4Command.self
  ]
  
  static let symbol: String = "level1"
  static let usage: String = ""
  
  static func main(_ options: Options) throws { }
}

struct Level2Command: CommandRepresentable {
  struct Options: OptionsRepresentable {
    enum CodingKeys: String, CodingKeysRepresentable {
      case value
    }
    static let keys: [Options.CodingKeys : Character] = [:]
    static let descriptions: [Options.CodingKeys : OptionDescription] = [:]
    
    let value: String
  }
  
  static let children: [CommandDispatchable.Type] = [
    Level1Command.self,
    Level3Command.self,
    Level4Command.self
  ]
  
  static let symbol: String = "level2"
  static let usage: String = ""
  
  static func main(_ options: Options) throws { }
}

struct Level3Command: CommandRepresentable {
  struct Options: OptionsRepresentable {
    enum CodingKeys: String, CodingKeysRepresentable {
      case value
    }
    static let keys: [Options.CodingKeys : Character] = [:]
    static let descriptions: [Options.CodingKeys : OptionDescription] = [:]
    
    let value: String
  }
  
  static let children: [CommandDispatchable.Type] = [
    Level2Command.self,
    Level1Command.self,
    Level4Command.self
  ]
  
  static let symbol: String = "level3"
  static let usage: String = ""
  
  static func main(_ options: Options) throws { }
}

struct Level4Command: CommandRepresentable {
  struct Options: OptionsRepresentable {
    enum CodingKeys: String, CodingKeysRepresentable {
      case value
    }
    static let keys: [Options.CodingKeys : Character] = [:]
    static let descriptions: [Options.CodingKeys : OptionDescription] = [:]
    
    let value: String
  }
  
  static let children: [CommandDispatchable.Type] = [
    Level2Command.self,
    Level3Command.self,
    Level1Command.self
  ]
  
  static let symbol: String = "level4"
  static let usage: String = ""
  
  static func main(_ options: Options) throws { }
}

// MARK: - CommandPathTests.

class CommandPathTests: XCTestCase {
  static let allTests = [
    ("testLevel1Paths", testLevel1Paths),
    ("testLevel2Paths", testLevel2Paths),
    ("testMultiLevelPaths", testMultiLevelPaths)
  ]

  func testLevel1Paths() {
    var commandPath = CommandPath(running: Level1Command.self, at: "path1")
    do {
      let result = try commandPath.run(with: ["--value", "value"])
      XCTAssertEqual(result.paths.joined(separator: " "), "path1")
    } catch {
      XCTFail()
    }
    
    commandPath = CommandPath(running: Level2Command.self, at: "path2")
    do {
      let result = try commandPath.run(with: ["--value", "value"])
      XCTAssertEqual(result.paths.joined(separator: " "), "path2")
    } catch {
      XCTFail()
    }
    
    commandPath = CommandPath(running: Level3Command.self, at: "path3")
    do {
      let result = try commandPath.run(with: ["--value", "value"])
      XCTAssertEqual(result.paths.joined(separator: " "), "path3")
    } catch {
      XCTFail()
    }
    
    commandPath = CommandPath(running: Level4Command.self, at: "path4")
    do {
      let result = try commandPath.run(with: ["--value", "value"])
      XCTAssertEqual(result.paths.joined(separator: " "), "path4")
    } catch {
      XCTFail()
    }
  }
  
  func testLevel2Paths() {
    do {
      let commandPath = CommandPath(running: Level1Command.self, at: "path1")
      let result = try commandPath.run(with: ["level2", "--value", "value"])
      XCTAssertEqual(result.paths.joined(separator: " "), "path1 level1")
    } catch { XCTFail() }
    
    do {
      let commandPath = CommandPath(running: Level2Command.self, at: "path2")
      let result = try commandPath.run(with: ["level3", "--value", "value"])
      XCTAssertEqual(result.paths.joined(separator: " "), "path2 level2")
    } catch { XCTFail() }
    
    do {
      let commandPath = CommandPath(running: Level3Command.self, at: "path3")
      let result = try commandPath.run(with: ["level4", "--value", "value"])
      XCTAssertEqual(result.paths.joined(separator: " "), "path3 level3")
    } catch { XCTFail() }
    
    do {
      let commandPath = CommandPath(running: Level4Command.self, at: "path4")
      let result = try commandPath.run(with: ["level1", "--value", "value"])
      XCTAssertEqual(result.paths.joined(separator: " "), "path4 level4")
    } catch { XCTFail() }
  }
  
  func testMultiLevelPaths() {
    do {
      do {
        let commandPath = CommandPath(running: Level1Command.self, at: "path")
        let result = try commandPath.run(with: ["level2", "level3", "level4", "--value", "value"])
        XCTAssertEqual(result.paths.joined(separator: " "), "path level1 level2 level3")
      }
      
      do {
        let commandPath = CommandPath(running: Level1Command.self, at: "path")
        let result = try commandPath.run(with: ["level2", "level4", "level3", "--value", "value"])
        XCTAssertEqual(result.paths.joined(separator: " "), "path level1 level2 level4")
      }
      
      do {
        let commandPath = CommandPath(running: Level1Command.self, at: "path")
        let result = try commandPath.run(with: ["level3", "level4", "level2", "--value", "value"])
        XCTAssertEqual(result.paths.joined(separator: " "), "path level1 level3 level4")
      }
    } catch { XCTFail() }
    
    do {
      do {
        let commandPath = CommandPath(running: Level2Command.self, at: "path")
        let result = try commandPath.run(with: ["level1", "level3", "level4", "--value", "value"])
        XCTAssertEqual(result.paths.joined(separator: " "), "path level2 level1 level3")
      }
      
      do {
        let commandPath = CommandPath(running: Level2Command.self, at: "path")
        let result = try commandPath.run(with: ["level1", "level4", "level3", "--value", "value"])
        XCTAssertEqual(result.paths.joined(separator: " "), "path level2 level1 level4")
      }
      
      do {
        let commandPath = CommandPath(running: Level2Command.self, at: "path")
        let result = try commandPath.run(with: ["level3", "level4", "level1", "--value", "value"])
        XCTAssertEqual(result.paths.joined(separator: " "), "path level2 level3 level4")
      }
    } catch { XCTFail() }
    
    do {
      do {
        let commandPath = CommandPath(running: Level3Command.self, at: "path")
        let result = try commandPath.run(with: ["level1", "level2", "level4", "--value", "value"])
        XCTAssertEqual(result.paths.joined(separator: " "), "path level3 level1 level2")
      }
      
      do {
        let commandPath = CommandPath(running: Level3Command.self, at: "path")
        let result = try commandPath.run(with: ["level1", "level4", "level2", "--value", "value"])
        XCTAssertEqual(result.paths.joined(separator: " "), "path level3 level1 level4")
      }
      
      do {
        let commandPath = CommandPath(running: Level3Command.self, at: "path")
        let result = try commandPath.run(with: ["level2", "level4", "level1", "--value", "value"])
        XCTAssertEqual(result.paths.joined(separator: " "), "path level3 level2 level4")
      }
    } catch { XCTFail() }
    
    do {
      do {
        let commandPath = CommandPath(running: Level4Command.self, at: "path")
        let result = try commandPath.run(with: ["level1", "level2", "level3", "--value", "value"])
        XCTAssertEqual(result.paths.joined(separator: " "), "path level4 level1 level2")
      }
      
      do {
        let commandPath = CommandPath(running: Level4Command.self, at: "path")
        let result = try commandPath.run(with: ["level1", "level3", "level2", "--value", "value"])
        XCTAssertEqual(result.paths.joined(separator: " "), "path level4 level1 level3")
      }
      
      do {
        let commandPath = CommandPath(running: Level4Command.self, at: "path")
        let result = try commandPath.run(with: ["level2", "level3", "level1", "--value", "value"])
        XCTAssertEqual(result.paths.joined(separator: " "), "path level4 level2 level3")
      }
    } catch { XCTFail() }
  }
}
