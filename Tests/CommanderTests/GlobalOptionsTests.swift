//
//  GlobalOptionsTests.swift
//  CommanderTests
//
//  Created by devedbox on 2018/10/12.
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
@testable import Utility

class MockCommander: CommanderRepresentable {
  static var errorHandler: ((Swift.Error) throws -> Swift.Void)? = nil
  
  struct TestsCommand: CommandRepresentable {
    struct Options: OptionsRepresentable {
      typealias SharedOptions = MockCommander.Options
      enum CodingKeys: String, OptionKeysRepresentable, CodingKey {
        case mockDir = "mock-dir"
        case target
      }
      typealias OptionKeys = CodingKeys
      
      static var keys: [TestsCommand.Options.CodingKeys : Character] = [
        .mockDir: "C",
        .target: "T"
      ]
      static var descriptions: [TestsCommand.Options.CodingKeys: OptionDescription] = [
        .mockDir: .usage("The mock dir"),
        .target: .default(value: "Default", usage: "The target of the test command")
      ]
      let mockDir: String
      let target: String
      
      init() { mockDir = ""; target = "" }
    }
    
    static let symbol: String = "test"
    static var usage: String = "Mocked command for tests"
    
    static func main(_ options: TestsCommand.Options) throws {
      
    }
  }
  
  struct TestsArgsCommand: CommandRepresentable {
    struct Options: OptionsRepresentable {
      typealias SharedOptions = MockCommander.Options
      typealias Argument = [String: UInt8]
      enum CodingKeys: String, OptionKeysRepresentable, CodingKey {
        case target
      }
      typealias OptionKeys = CodingKeys
      
      static var keys: [TestsArgsCommand.Options.CodingKeys : Character] = [
        .target: "T"
      ]
      static var descriptions: [Options.CodingKeys: OptionDescription] = [
        .target: .default(value: "Default", usage: "The target of the test command")
      ]
      var target: String
      
      init() { target = "" }
    }
    static let children: [CommandDispatchable.Type] = [
      TestsCommand.self
    ]
    static let symbol: String = "test-args"
    static var usage: String = "Mocked command for tests args"
    
    static func main(_ options: Options) throws {
      
    }
  }
  
  struct Options: OptionsRepresentable {
    enum CodingKeys: String, OptionKeysRepresentable, CodingKey {
      case mockDir = "mock-dir"
      case verbose
    }
    typealias OptionKeys = CodingKeys
    
    static var keys: [MockCommander.Options.CodingKeys : Character] = [
      .mockDir: "C",
      .verbose: "v"
    ]
    
    static var descriptions: [MockCommander.Options.CodingKeys : OptionDescription] = [
      .mockDir: .usage("The mock dir"),
      .verbose: .default(value: false, usage: "")
    ]
    
    let mockDir: String
    let verbose: Bool
    
    init() { mockDir = ""; verbose = false  }
  }
  static var outputHandler: ((String) -> Void)? = nil
  
  static var commands: [CommandDispatchable.Type] = [
    MockCommander.TestsCommand.self,
    MockCommander.TestsArgsCommand.self
  ]
  
  static var usage: String = "Mocked usage"
}

class GlobalOptionsTests: XCTestCase {
  static let allTests = [
    ("testGlobalOptions", testGlobalOptions)
  ]
  
  func testGlobalOptions() {
    XCTAssertTrue(MockCommander.Options.completions(for: Utility.CommandLine("")).isEmpty)
    
    XCTAssertNoThrow(try MockCommander().dispatch(with: ["commander", "test", "-C=path"]))
    XCTAssertNoThrow(try MockCommander().dispatch(with: ["commander", "test", "-C=path", "-v"]))
    XCTAssertNoThrow(try MockCommander().dispatch(with: ["commander", "test", "--mock-dir", "path"]))
    XCTAssertNoThrow(try MockCommander().dispatch(with: ["commander", "test", "--mock-dir", "path", "--verbose"]))
    XCTAssertNoThrow(try MockCommander().dispatch(with: ["commander", "test-args", "-C=path"]))
    XCTAssertNoThrow(try MockCommander().dispatch(with: ["commander", "test-args", "-C=path", "-v"]))
    XCTAssertNoThrow(try MockCommander().dispatch(with: ["commander", "test-args", "--mock-dir", "path"]))
    XCTAssertNoThrow(try MockCommander().dispatch(with: ["commander", "test-args", "--mock-dir", "path", "--verbose"]))
    
    do {
      try MockCommander().dispatch(with: ["commander", "test", "--verbose"])
      XCTFail()
    } catch OptionsDecoder.Error.decodingError(DecodingError.keyNotFound(let key, let ctx)) {
      XCTAssertEqual(key.stringValue, "mock-dir")
      XCTAssertFalse(OptionsDecoder.Error.decodingError(DecodingError.keyNotFound(key, ctx)).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try MockCommander().dispatch(with: ["commander", "test-args", "--verbose"])
      XCTFail()
    } catch OptionsDecoder.Error.decodingError(DecodingError.keyNotFound(let key, let ctx)) {
      XCTAssertEqual(key.stringValue, "mock-dir")
      XCTAssertFalse(OptionsDecoder.Error.decodingError(DecodingError.keyNotFound(key, ctx)).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      try MockCommander().dispatch(with: ["commander", "test", "-C=path", "--verbose", "-s", "-r"])
      XCTFail()
    } catch Commander.Error.unrecognizedOptions(let options, path: let path, underlyingError: let error) {
      XCTAssertEqual(options.set, ["s", "r"])
      XCTAssertTrue(path?.command == MockCommander.TestsCommand.self)
      XCTAssertEqual(path?.paths.set, ["commander"])
      XCTAssertFalse(Error.unrecognizedOptions(options, path: path, underlyingError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
  }
}
