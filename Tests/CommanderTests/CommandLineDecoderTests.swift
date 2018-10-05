//
//  CommandLineDecoderTests.swift
//  CommanderTests
//
//  Created by devedbox on 2018/10/2.
//

import XCTest
@testable import Commander

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
    ("testDecode", testDecode),
  ]
  
  func testDecodeInContainer() {
    print(try! CommanderDecoder().container(from: ["-vabk", "arg1", "-u", "arg2", "arg3"]))
    print(try! CommanderDecoder().container(from: ["-v"]))
    print(try! CommanderDecoder().container(from: ["-C", "../path"]))
  }
  
  func testDecodeArguments() {
    var value = try! CommanderDecoder().container(from: "-v args".components(separatedBy: " "))
    XCTAssertNotNil(value.dictionaryValue)
    XCTAssertEqual(value.dictionaryValue?["v"] as? CommanderDecoder.ObjectFormat.Value, "args")
  }
  
  func testDecode() {
    let commands = ["--target", "sampleTarget", "sasa", "--verbose", "--path", "value=This is a path,location=12", "--config-path", "../path", "--locs", "1,2,3,4,5,6,7,8,9,0", "--1","--2", "--3"]
    let option = try! CommanderDecoder().decode(SimpleOption.self, from: commands)
    print(option)
  }
}
