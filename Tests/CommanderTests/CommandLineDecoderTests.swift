//
//  CommandLineDecoderTests.swift
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
  
  struct Path: Decodable {
    let value: String
    let location: UInt8
  }
  
  static var description: [(SimpleOption.CodingKeys, OptionKeyDescription)] = []
  
  let target: String
  let verbose: Bool
  let path: Path
  let configPath: String
  let locs: [UInt8]
}

// MARK: - CommandLineDecoderTests.

class CommandLineDecoderTests: XCTestCase {
  static var allTests = [
    ("testDecodeInContainer", testDecodeInContainer),
    ("testDecode", testDecode),
  ]
  
  func testDecodeInContainer() {
    var value = try! CommanderDecoder().container(from: "-v args".components(separatedBy: " "))
    XCTAssertNotNil(value.dictionaryValue)
    XCTAssertNil(value.arrayValue)
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
    
    do {
      _ = try CommanderDecoder().container(from: ["--option", "value", "extra", "-v"])
    } catch CommanderDecoder.Error.unrecognizedArguments(let args) {
      XCTAssertEqual(args as? [String], ["extra"])
    } catch {
      XCTFail()
    }
    
    do {
      _ = try CommanderDecoder().container(from: ["--option", "value", "extra1", "-v", "verbose", "extra2", "-t"])
    } catch CommanderDecoder.Error.unrecognizedArguments(let args) {
      XCTAssertEqual(args as? [String], ["extra1", "extra2"])
    } catch {
      XCTFail()
    }
  }
  
  func testDecode() {
    let commands = ["--target", "sampleTarget", "sasa", "--verbose", "--path", "value=This is a path,location=12", "--config-path", "../path", "--locs", "1,2,3,4,5,6,7,8,9,0", "--1","--2", "--3"]
    let option = try! CommanderDecoder().decode(SimpleOption.self, from: commands)
    print(option)
  }
}
