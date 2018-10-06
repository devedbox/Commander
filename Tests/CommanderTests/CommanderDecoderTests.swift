//
//  CommanderDecoderTests.swift
//  CommanderTests
//
//  Created by devedbox on 2018/10/2.
//

import XCTest
@testable import Commander

// MARK: - TestsSupports.

extension CommanderDecoder.ObjectFormat.Value {
  public subscript(key: String) -> Any? {
    return dictionaryValue?[key]?.unwrapped
  }
  
  public func keyedNestedArray(key: String) -> [Any] {
    return dictionaryValue?[key]?.arrayValue?.compactMap { $0.unwrapped } ?? []
  }
  
  public var unwrappedArray: [Any] {
    return arrayValue?.compactMap { $0.unwrapped } ?? []
  }
}

// MARK: - Mocks.

struct SimpleOption: OptionsRepresentable {
  public enum CodingKeys: String, CodingKey, StringRawRepresentable {
    case target
    case verbose
    case path
    case configPath = "config-path"
    case locs
  }
  
  struct Path: Decodable, Hashable {
    let value: String
    let location: UInt8
  }
  
  static var description: [(SimpleOption.CodingKeys, OptionKeyDescription)] = [
    (.target, .usage("The target of the options")),
  ]
  
  let target: String
  let verbose: Bool
  let path: Path
  let configPath: String
  let locs: [UInt8]
}

struct ArgumentsOptions: OptionsRepresentable {
  typealias ArgumentsResolver = AnyArgumentsResolver<String>
  enum CodingKeys: String, CodingKey, StringRawRepresentable {
    case bool
  }
  static var description: [(CodingKeys, OptionKeyDescription)] = []
  
  let bool: Bool
}

struct ComplexArgumentsOptions: OptionsRepresentable {
  typealias ArgumentsResolver = AnyArgumentsResolver<String>
  enum CodingKeys: String, CodingKey, StringRawRepresentable {
    case bool
    case string
    case int
  }
  static var description: [(CodingKeys, OptionKeyDescription)] = [
    (.bool, .short("b", usage: "")),
    (.string, .short("S", usage: "")),
    (.int, .short("i", usage: "")),
  ]
  
  let bool: Bool
  let string: String
  let int: Int
}

// MARK: - CommanderDecoderTests.

class CommanderDecoderTests: XCTestCase {
  static var allTests = [
    ("testDecodeInContainer", testDecodeInContainer),
    ("testDecodeSimpleOptions", testDecodeSimpleOptions),
  ]
  
  func testDecodeInContainer() {
    var value = try! CommanderDecoder().container(from: "-v args".components(separatedBy: " "))
    XCTAssertNotNil(value.dictionaryValue)
    XCTAssertNotNil(value.arrayValue)
    XCTAssertNil(value.boolValue)
    XCTAssertNil(value.stringValue)
    XCTAssertEqual(value["v"] as? String?, "args")
    
    value = try! CommanderDecoder().container(from: ["--option1", "value1", "-v", "-t", "-ab"])
    XCTAssertNotNil(value.dictionaryValue)
    XCTAssertEqual(value["option1"] as? String?, "value1")
    XCTAssertEqual(value["v"] as? Bool?, true)
    XCTAssertEqual(value["t"] as? Bool?, true)
    XCTAssertEqual(value["a"] as? Bool?, true)
    XCTAssertEqual(value["b"] as? Bool?, true)
    
    value = try! CommanderDecoder().container(from: ["-o", "value1", "-vtab"])
    XCTAssertNotNil(value.dictionaryValue)
    XCTAssertEqual(value["o"] as? String?, "value1")
    XCTAssertEqual(value["v"] as? Bool?, true)
    XCTAssertEqual(value["t"] as? Bool?, true)
    XCTAssertEqual(value["a"] as? Bool?, true)
    XCTAssertEqual(value["b"] as? Bool?, true)
    
    value = try! CommanderDecoder().container(from: ["--option", "key1,key2,key3"])
    XCTAssertNotNil(value.dictionaryValue)
    XCTAssertEqual(value.keyedNestedArray(key: "option") as? [String], ["key1", "key2", "key3"])
    value = try! CommanderDecoder().container(from: ["-o", "key1,key2,key3"])
    XCTAssertNotNil(value.dictionaryValue)
    XCTAssertEqual(value.keyedNestedArray(key: "o") as? [String], ["key1", "key2", "key3"])
  }
  
  func testDecodeSimpleOptions() {
    let commands = [
      "--target", "target",
      "--verbose",
      "--path", "value=This is a path,location=12",
      "--config-path", "../path",
      "--locs", "1,2,3,4,5,6,7,8,9,0"
    ]
    do {
      var option = try CommanderDecoder().decode(SimpleOption.self, from: commands)
      XCTAssertEqual(option.target, "target")
      XCTAssertEqual(option.verbose, true)
      XCTAssertEqual(option.path.value, "This is a path")
      XCTAssertEqual(option.path.location, 12)
      XCTAssertEqual(option.configPath, "../path")
      XCTAssertEqual(Set(option.locs), [1,2,3,4,5,6,7,8,9,0])
      option.arguments = []
      XCTAssertTrue(option.arguments.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try CommanderDecoder().decode(SimpleOption.self, from: commands + ["argument"])
    } catch Commander {
      <#statements#>
    }
  }
  
  func testDecodeArgumentsOptions() {
    let options = try! CommanderDecoder().decode(ArgumentsOptions.self, from: ["--bool", "boolValue", "args1", "args2"])
    XCTAssertEqual(options.arguments, ["boolValue", "args1", "args2"])
    
    do {
      _ = try CommanderDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "Bool", "-S", "String", "-i", "5"])
      XCTFail()
    } catch CommanderDecoder.Error.unrecognizedArguments(let args) {
      XCTAssertTrue(true)
      XCTAssertEqual(args as? [String], ["Bool"])
    } catch {
      XCTFail()
    }
    
    do {
      _ = try CommanderDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "Bool", "-S", "String", "InvalidString", "-i", "5"])
      XCTFail()
    } catch CommanderDecoder.Error.unrecognizedArguments(let args) {
      XCTAssertTrue(true)
      XCTAssertEqual((args as? [String]).map { Set($0) }, ["Bool", "InvalidString"])
    } catch {
      XCTFail()
    }
  }
  
  func testDecodeErrors() {
    do {
      _ = try CommanderDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "Bool", "-S", "String", "-i", "5"])
      XCTFail()
    } catch CommanderDecoder.Error.unrecognizedArguments(_) {
      XCTAssertTrue(true)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try CommanderDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "-S", "String", "-i", "Int"])
      XCTFail()
    } catch CommanderDecoder.Error.decodingError(DecodingError.typeMismatch(let type, _)) {
      XCTAssertTrue(true)
      XCTAssertTrue(type is Int.Type)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try CommanderDecoder().decode(ComplexArgumentsOptions.self, from: ["-S", "String", "-i", "Int"])
      XCTFail()
    } catch CommanderDecoder.Error.decodingError(DecodingError.keyNotFound(let key, _)) {
      XCTAssertTrue(true)
      XCTAssertEqual(key.stringValue, ComplexArgumentsOptions.CodingKeys.bool.stringValue)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try CommanderDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "-S", "-i", "5"])
      XCTFail()
    } catch CommanderDecoder.Error.decodingError(DecodingError.valueNotFound(let type, _)) {
      XCTAssertTrue(true)
      XCTAssertTrue(type is String.Type)
    } catch {
      XCTFail()
    }
  }
}
