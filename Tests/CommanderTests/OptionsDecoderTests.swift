//
//  OptionsDecoderTests.swift
//  CommanderTests
//
//  Created by devedbox on 2018/10/2.
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

// MARK: - TestsSupports.

extension OptionsDecoder.ObjectFormat.Value {
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

extension Array where Element: Hashable {
  var set: Set<Element> {
    return Set(self)
  }
}

// MARK: - Mocks.

struct PrimaryOptions: OptionsRepresentable {
  
  public enum CodingKeys: String, OptionKeysRepresentable, CodingKey {
    case bool
    case int
    case int8
    case int16
    case int32
    case int64
    case uint
    case uint8
    case uint16
    case uint32
    case uint64
    case float
    case double
    case string
    case intArray = "int-array"
    case int8Array = "int8-array"
    case int16Array = "int16-array"
    case int32Array = "int32-array"
    case int64Array = "int64-array"
    case uintArray = "uint-array"
    case uint8Array = "uint8-array"
    case uint16Array = "uint16-array"
    case uint32Array = "uint32-array"
    case uint64Array = "uint64-array"
    case floatArray = "float-array"
    case doubleArray = "double-array"
    case stringArray = "string-array"
    case intDict = "int-dict"
    case int8Dict = "int8-dict"
    case int16Dict = "int16-dict"
    case int32Dict = "int32-dict"
    case int64Dict = "int64-dict"
    case uintDict = "uint-dict"
    case uint8Dict = "uint8-dict"
    case uint16Dict = "uint16-dict"
    case uint32Dict = "uint32-dict"
    case uint64Dict = "uint64-dict"
    case floatDict = "float-dict"
    case doubleDict = "double-dict"
    case stringDict = "string-dict"
  }
  typealias OptionKeys = CodingKeys
  
  static var keys: [PrimaryOptions.OptionKeys : Character] = [:]
  static var descriptions: [PrimaryOptions.OptionKeys: OptionDescription] = [:]
  
  let bool: Bool
  let int: Int
  let int8: Int8
  let int16: Int16
  let int32: Int32
  let int64: Int64
  let uint: UInt
  let uint8: UInt8
  let uint16: UInt16
  let uint32: UInt32
  let uint64: UInt64
  let float: Float
  let double: Double
  let string: String
  let intArray: [Int]
  let int8Array: [Int8]
  let int16Array: [Int16]
  let int32Array: [Int32]
  let int64Array: [Int64]
  let uintArray: [UInt]
  let uint8Array: [UInt8]
  let uint16Array: [UInt16]
  let uint32Array: [UInt32]
  let uint64Array: [UInt64]
  let floatArray: [Float]
  let doubleArray: [Double]
  let stringArray: [String]
  let intDict: [String: Int]
  let int8Dict: [String: Int8]
  let int16Dict: [String: Int16]
  let int32Dict: [String: Int32]
  let int64Dict: [String: Int64]
  let uintDict: [String: UInt]
  let uint8Dict: [String: UInt8]
  let uint16Dict: [String: UInt16]
  let uint32Dict: [String: UInt32]
  let uint64Dict: [String: UInt64]
  let floatDict: [String: Float]
  let doubleDict: [String: Double]
  let stringDict: [String: String]
  
  init() {
    bool = false
    int = 0
    int8 = 0
    int16 = 0
    int32 = 0
    int64 = 0
    uint = 0
    uint8 = 0
    uint16 = 0
    uint32 = 0
    uint64 = 0
    float = 0
    double = 0
    string = ""
    intArray = []
    int8Array = []
    int16Array = []
    int32Array = []
    int64Array = []
    uintArray = []
    uint8Array = []
    uint16Array = []
    uint32Array = []
    uint64Array = []
    floatArray = []
    doubleArray = []
    stringArray = []
    intDict = [:]
    int8Dict = [:]
    int16Dict = [:]
    int32Dict = [:]
    int64Dict = [:]
    uintDict = [:]
    uint8Dict = [:]
    uint16Dict = [:]
    uint32Dict = [:]
    uint64Dict = [:]
    floatDict = [:]
    doubleDict = [:]
    stringDict = [:]
  }
}

struct SimpleOption: OptionsRepresentable {
  public enum CodingKeys: String, OptionKeysRepresentable, CodingKey {
    case target
    case verbose
    case path
    case configPath = "config-path"
    case locs
  }
  typealias OptionKeys = CodingKeys
  
  struct Path: Codable, Hashable {
    let value: String
    let location: UInt8
  }
  
  static var keys: [SimpleOption.OptionKeys : Character] = [:]
  
  static var descriptions: [SimpleOption.OptionKeys: OptionDescription] = [
    .target: .usage("The target of the options"),
    .path: .default(value: Path(value: "default", location: 0), usage: ""),
    .locs: .default(value: [1, 2, 3], usage: "")
  ]
  
  let path: Path
  let target: [String]
  let verbose: Bool
  let configPath: String
  let locs: [UInt8]
  
  init() {
    path = Path(value: "", location: 0)
    target = []
    verbose = false
    configPath = ""
    locs = []
  }
}

struct ArgumentsOptions: OptionsRepresentable {
  typealias Argument = String
  enum CodingKeys: String, OptionKeysRepresentable, CodingKey {
    case bool
  }
  typealias OptionKeys = CodingKeys
  
  static var keys: [ArgumentsOptions.OptionKeys : Character] = [:]
  static var descriptions: [ArgumentsOptions.OptionKeys: OptionDescription] = [:]
  
  let bool: Bool
  
  init() {
    bool = false
  }
}

struct DictArgumentsOptions: OptionsRepresentable {
  typealias Argument = [String: String]
  enum CodingKeys: String, OptionKeysRepresentable, CodingKey {
    case bool
  }
  typealias OptionKeys = CodingKeys
  
  static var keys: [OptionKeys : Character] = [:]
  static var descriptions: [OptionKeys: OptionDescription] = [:]
  
  let bool: Bool
  
  init() {
    bool = false
  }
}

struct ArrayArgumentsOptions: OptionsRepresentable {
  typealias Argument = [UInt32]
  enum CodingKeys: String, OptionKeysRepresentable, CodingKey {
    case bool
  }
  typealias OptionKeys = CodingKeys
  
  static var keys: [OptionKeys : Character] = [:]
  static var descriptions: [OptionKeys: OptionDescription] = [:]
  
  let bool: Bool
  
  init() {
    bool = false
  }
}

struct ComplexArgumentsOptions: OptionsRepresentable {
  typealias Argument = String
  enum CodingKeys: String, OptionKeysRepresentable, CodingKey {
    case bool
    case verbose
    case string
    case int
  }
  typealias OptionKeys = CodingKeys
  
  static var keys: [ComplexArgumentsOptions.OptionKeys : Character] = [
    .bool: "b",
    .verbose: "v",
    .string: "S",
    .int: "i"
  ]
  static var descriptions: [ComplexArgumentsOptions.OptionKeys: OptionDescription] = [
    .bool: .default(value: false, usage: ""),
    .verbose: .default(value: false, usage: "")
  ]
  
  let bool: Bool
  let verbose: Bool
  let string: String
  let int: Int
  
  init() {
    bool = false
    verbose = false
    string = ""
    int = 0
  }
}

struct KeyedOptions: OptionsRepresentable {
  typealias Argument = String
  enum CodingKeys: String, OptionKeysRepresentable, CodingKey {
    case dict
  }
  typealias OptionKeys = CodingKeys
  
  static var keys: [KeyedOptions.OptionKeys : Character] = [:]
  static var descriptions: [KeyedOptions.OptionKeys: OptionDescription] = [
    .dict: .usage(""),
  ]
  
  let dict: [String: String]
  
  init() {
    dict = [:]
  }
}

struct DefaultValueOptions: OptionsRepresentable {
  enum CodingKeys: String, OptionKeysRepresentable, CodingKey {
    case string
    case bool
    case dict
  }
  typealias OptionKeys = CodingKeys
  
  static var keys: [OptionKeys : Character] = [
    :
  ]
  static var descriptions: [OptionKeys: OptionDescription] = [
    .string: .default(value: "default", usage: ""),
    .dict: .default(value: ["key": "value"], usage: "")
  ]
  
  let string: String?
  let bool: Bool?
  let dict: [String: String]
  
  init() {
    string = ""
    bool = false
    dict = [:]
  }
}

struct MismatchTypeDefaultValueOptions: OptionsRepresentable {
  enum CodingKeys: String, OptionKeysRepresentable, CodingKey {
    case string
    case bool
    case dict
  }
  typealias OptionKeys = CodingKeys
  
  static var keys: [OptionKeys : Character] = [
    :
  ]
  static var descriptions: [OptionKeys: OptionDescription] = [
    .string: .default(value: ["k": 1], usage: ""),
    .dict: .default(value: "default", usage: "")
  ]
  
  let string: String
  let bool: Bool?
  let dict: [String: String]
  
  init() {
    string = ""
    bool = false
    dict = [:]
  }
}

struct ArrayOptions: OptionsRepresentable {
  enum CodingKeys: String, OptionKeysRepresentable, CodingKey {
    case arrayValue = "array-value"
    case stringValue = "string-value"
  }
  typealias OptionKeys = CodingKeys
  
  static var keys: [ArrayOptions.OptionKeys : Character] = [
    :
  ]
  static var descriptions: [ArrayOptions.OptionKeys : OptionDescription] = [
    :
  ]
  
  let arrayValue: [String]
  let stringValue: String
  
  init() {
    arrayValue = []
    stringValue = ""
  }
}

struct DictOptions: OptionsRepresentable {
  enum CodingKeys: String, OptionKeysRepresentable, CodingKey {
    case dictValue = "dict-value"
    case stringValue = "string-value"
  }
  typealias OptionKeys = CodingKeys
  
  static var keys: [OptionKeys : Character] = [
    :
  ]
  static var descriptions: [OptionKeys : OptionDescription] = [
    :
  ]
  
  let dictValue: [String: String]
  let stringValue: String
  
  init() {
    dictValue = [:]
    stringValue = ""
  }
}

// MARK: - OptionsDecoderTests.

class OptionsDecoderTests: XCTestCase {
  static var allTests = [
    ("testUtils", testUtils),
    ("testDecodeContainers", testDecodeContainers),
    ("testDecodeInContainer", testDecodeInContainer),
    ("testDecodeSimpleOptions", testDecodeSimpleOptions),
    ("testDecodePrimaryOptions", testDecodePrimaryOptions),
    ("testDecodeSimpleOptions", testDecodeSimpleOptions),
    ("testDecodeArgumentsOptions", testDecodeArgumentsOptions),
    ("testDecodeErrors", testDecodeErrors),
    ("testDefaultValueOptionsDecode", testDefaultValueOptionsDecode),
    ("testContainerValueDecoding", testContainerValueDecoding)
  ]
  
  func testUtils() {
    XCTAssertNil("".endsIndex(matchs: "--"))
    XCTAssertNil("-".endsIndex(matchs: "--"))
    XCTAssertNil("-+".endsIndex(matchs: "--"))
    XCTAssertNotNil("---".endsIndex(matchs: "--"))
    XCTAssertTrue("--".endsIndex(matchs: "--") == "--".endIndex)
    XCTAssertTrue("-".isSingle)
    XCTAssertFalse("".isSingle)
    XCTAssertFalse("--".isSingle)
    
    var array = [[Int]]()
    array.lastAppend(0)
    XCTAssertNil(array.last)
    array = [[]]
    array.lastAppend(0)
    XCTAssertEqual([0], array.last)
    
    XCTAssertEqual(OptionsDecoder._Decoder._Key(index: 1).description, "Index 1 Index - 1")
    XCTAssertEqual(OptionsDecoder._Decoder._Key(intValue: 1)!.description, "1 Index - 1")
    
    XCTAssertTrue(ComplexArgumentsOptions.validate("bool"))
    XCTAssertTrue(ComplexArgumentsOptions.validate("verbose"))
    XCTAssertTrue(ComplexArgumentsOptions.validate("string"))
    XCTAssertTrue(ComplexArgumentsOptions.validate("int"))
    XCTAssertFalse(ComplexArgumentsOptions.validate("-bool"))
    XCTAssertFalse(ComplexArgumentsOptions.validate("-verbose"))
    XCTAssertFalse(ComplexArgumentsOptions.validate("-string"))
    XCTAssertFalse(ComplexArgumentsOptions.validate("-int"))
    XCTAssertTrue(ComplexArgumentsOptions.validate("b"))
    XCTAssertTrue(ComplexArgumentsOptions.validate("v"))
    XCTAssertTrue(ComplexArgumentsOptions.validate("S"))
    XCTAssertTrue(ComplexArgumentsOptions.validate("i"))
    XCTAssertFalse(ComplexArgumentsOptions.validate("--b"))
    XCTAssertFalse(ComplexArgumentsOptions.validate("--v"))
    XCTAssertFalse(ComplexArgumentsOptions.validate("--S"))
    XCTAssertFalse(ComplexArgumentsOptions.validate("--i"))
  }
  
  func testDecodeContainers() {
    let dict: OptionsDecoder.ObjectFormat.Value! = .value([
      "mock1": [
        "key1": "value1",
        "key2": "value2",
        "key3": [
          "value1",
          "value2",
          "value3",
          "value4"
        ]
      ],
      "mock2": [
        "key1": "value1",
        "key2": "value2",
        "key3": [
          "value1",
          "value2",
          "value3",
          "value4"
        ]
      ]
    ])
    let mock = OptionsDecoder.ObjectFormat.Value(
      dictionaryValue: dict.dictionaryValue,
      arrayValue: [dict, dict],
      stringValue: "mock",
      boolValue: false
    )
    
    let decoder = OptionsDecoder._Decoder(referencing: OptionsDecoder(), wrapping: mock)
    
    typealias Key = OptionsDecoder._Decoder._Key
    
    XCTAssertNoThrow(try decoder.container(keyedBy: Key.self))
    XCTAssertNoThrow(try decoder.unkeyedContainer())
    XCTAssertNoThrow(try decoder.singleValueContainer())
    
    let keyedContainer = try! decoder.container(keyedBy: Key.self)
    XCTAssertNoThrow(try keyedContainer.nestedContainer(keyedBy: Key.self, forKey: Key(stringValue: "mock1")!))
    XCTAssertNoThrow(try keyedContainer.nestedContainer(keyedBy: Key.self, forKey: Key(stringValue: "mock2")!))
    
    var nestedKeyedContainer1 = try! keyedContainer.nestedContainer(keyedBy: Key.self, forKey: Key(stringValue: "mock1")!)
    XCTAssertNoThrow(try nestedKeyedContainer1.nestedUnkeyedContainer(forKey: Key(stringValue: "key3")!))
    var nestedKeyedContainer2 = try! keyedContainer.nestedContainer(keyedBy: Key.self, forKey: Key(stringValue: "mock2")!)
    XCTAssertNoThrow(try nestedKeyedContainer2.nestedUnkeyedContainer(forKey: Key(stringValue: "key3")!))
    
    var unkeyedContainer = try! decoder.unkeyedContainer()
    XCTAssertNoThrow(try unkeyedContainer.nestedContainer(keyedBy: Key.self))
    
    let nestedKeyedContainer = try! unkeyedContainer.nestedContainer(keyedBy: Key.self)
    
    nestedKeyedContainer1 = try! nestedKeyedContainer.nestedContainer(keyedBy: Key.self, forKey: Key(stringValue: "mock1")!)
    XCTAssertNoThrow(try nestedKeyedContainer1.nestedUnkeyedContainer(forKey: Key(stringValue: "key3")!))
    nestedKeyedContainer2 = try! nestedKeyedContainer.nestedContainer(keyedBy: Key.self, forKey: Key(stringValue: "mock2")!)
    XCTAssertNoThrow(try nestedKeyedContainer2.nestedUnkeyedContainer(forKey: Key(stringValue: "key3")!))
  }
  
  func testDecodeInContainer() {
    var value = try! OptionsDecoder().container(from: "-v args".components(separatedBy: " "))
    XCTAssertNotNil(value.dictionaryValue)
    XCTAssertNotNil(value.arrayValue)
    XCTAssertNil(value.boolValue)
    XCTAssertNil(value.stringValue)
    XCTAssertEqual(value["v"] as? String?, "args")
    
    value = try! OptionsDecoder().container(from: "-v=args".components(separatedBy: " "))
    XCTAssertNotNil(value.dictionaryValue)
    XCTAssertNotNil(value.arrayValue)
    XCTAssertNil(value.boolValue)
    XCTAssertNil(value.stringValue)
    XCTAssertEqual(value["v"] as? String?, "args")
    
    value = try! OptionsDecoder().container(from: ["--option1", "value1", "-v", "-t", "-ab"])
    XCTAssertNotNil(value.dictionaryValue)
    XCTAssertEqual(value["option1"] as? String?, "value1")
    XCTAssertEqual(value["v"] as? Bool?, true)
    XCTAssertEqual(value["t"] as? Bool?, true)
    XCTAssertEqual(value["a"] as? Bool?, true)
    XCTAssertEqual(value["b"] as? Bool?, true)
    
    value = try! OptionsDecoder().container(from: ["--option1=value1", "-v", "-t", "-ab"])
    XCTAssertNotNil(value.dictionaryValue)
    XCTAssertEqual(value["option1"] as? String?, "value1")
    XCTAssertEqual(value["v"] as? Bool?, true)
    XCTAssertEqual(value["t"] as? Bool?, true)
    XCTAssertEqual(value["a"] as? Bool?, true)
    XCTAssertEqual(value["b"] as? Bool?, true)
    
    value = try! OptionsDecoder().container(from: ["-o", "value1", "-vtab"])
    XCTAssertNotNil(value.dictionaryValue)
    XCTAssertEqual(value["o"] as? String?, "value1")
    XCTAssertEqual(value["v"] as? Bool?, true)
    XCTAssertEqual(value["t"] as? Bool?, true)
    XCTAssertEqual(value["a"] as? Bool?, true)
    XCTAssertEqual(value["b"] as? Bool?, true)
    
    value = try! OptionsDecoder().container(from: ["-o=value1", "-vtab"])
    XCTAssertNotNil(value.dictionaryValue)
    XCTAssertEqual(value["o"] as? String?, "value1")
    XCTAssertEqual(value["v"] as? Bool?, true)
    XCTAssertEqual(value["t"] as? Bool?, true)
    XCTAssertEqual(value["a"] as? Bool?, true)
    XCTAssertEqual(value["b"] as? Bool?, true)
    
    value = try! OptionsDecoder().container(from: ["--option", "key1,key2,key3"])
    XCTAssertNotNil(value.dictionaryValue)
    XCTAssertEqual(value.keyedNestedArray(key: "option") as? [String], ["key1", "key2", "key3"])
    value = try! OptionsDecoder().container(from: ["--option=key1,key2,key3"])
    XCTAssertNotNil(value.dictionaryValue)
    XCTAssertEqual(value.keyedNestedArray(key: "option") as? [String], ["key1", "key2", "key3"])
    
    value = try! OptionsDecoder().container(from: ["-o", "key1,key2,key3"])
    XCTAssertNotNil(value.dictionaryValue)
    XCTAssertEqual(value.keyedNestedArray(key: "o") as? [String], ["key1", "key2", "key3"])
    value = try! OptionsDecoder().container(from: ["-o=key1,key2,key3"])
    XCTAssertNotNil(value.dictionaryValue)
    XCTAssertEqual(value.keyedNestedArray(key: "o") as? [String], ["key1", "key2", "key3"])
  }
  
  func testDecodePrimaryOptions() {
    let options = try! OptionsDecoder().decode(PrimaryOptions.self, from: [
      "--bool",
      "--int", "1",
      "--int8", "2",
      "--int16", "3",
      "--int32", "4",
      "--int64", "5",
      "--uint", "6",
      "--uint8", "7",
      "--uint16", "8",
      "--uint32", "9",
      "--uint64", "10",
      "--float", "11",
      "--double", "12",
      "--string", "string",
      "--int-array", "1",
      "--int-array", "2",
      "--int-array", "3",
      "--int8-array", "1,2,3",
      "--int16-array", "1,2,3",
      "--int32-array", "1,2,3",
      "--int64-array", "1,2,3",
      "--uint-array", "1,2,3",
      "--uint8-array", "1,2,3",
      "--uint16-array", "1,2,3",
      "--uint32-array", "1,2,3",
      "--uint64-array", "1,2,3",
      "--float-array", "1",
      "--float-array", "2",
      "--float-array", "3",
      "--double-array", "1,2,3",
      "--string-array", "1,2,3",
      "--int-dict", "1=1,2=2,3=3",
      "--int8-dict", "1=1,2=2,3=3",
      "--int16-dict", "1=1,2=2,3=3",
      "--int32-dict", "1=1,2=2,3=3",
      "--int64-dict", "1=1,2=2,3=3",
      "--uint-dict", "1=1,2=2,3=3",
      "--uint8-dict", "1=1,2=2,3=3",
      "--uint16-dict", "1=1,2=2,3=3",
      "--uint32-dict", "1=1,2=2,3=3",
      "--uint64-dict", "1=1,2=2,3=3",
      "--float-dict", "1=1,2=2,3=3",
      "--double-dict", "1=1,2=2,3=3",
      "--string-dict", "1=1,2=2,3=3",
    ])
    
    XCTAssertEqual(options.bool, true)
    XCTAssertEqual(options.int, 1)
    XCTAssertEqual(options.int8, 2)
    XCTAssertEqual(options.int16, 3)
    XCTAssertEqual(options.int32, 4)
    XCTAssertEqual(options.int64, 5)
    XCTAssertEqual(options.uint, 6)
    XCTAssertEqual(options.uint8, 7)
    XCTAssertEqual(options.uint16, 8)
    XCTAssertEqual(options.uint32, 9)
    XCTAssertEqual(options.uint64, 10)
    XCTAssertEqual(options.float, 11)
    XCTAssertEqual(options.double, 12)
    XCTAssertEqual(options.string, "string")
    XCTAssertEqual(options.intArray.set, [1, 2, 3])
    XCTAssertEqual(options.int8Array.set, [1, 2, 3])
    XCTAssertEqual(options.int16Array.set, [1, 2, 3])
    XCTAssertEqual(options.int32Array.set, [1, 2, 3])
    XCTAssertEqual(options.int64Array.set, [1, 2, 3])
    XCTAssertEqual(options.uintArray.set, [1, 2, 3])
    XCTAssertEqual(options.uint8Array.set, [1, 2, 3])
    XCTAssertEqual(options.uint16Array.set, [1, 2, 3])
    XCTAssertEqual(options.uint32Array.set, [1, 2, 3])
    XCTAssertEqual(options.uint64Array.set, [1, 2, 3])
    XCTAssertEqual(options.floatArray.set, [1, 2, 3])
    XCTAssertEqual(options.doubleArray.set, [1, 2, 3])
    XCTAssertEqual(options.stringArray.set, ["1", "2", "3"])
    XCTAssertEqual(options.intDict, ["1": 1, "2": 2, "3": 3])
    XCTAssertEqual(options.int8Dict, ["1": 1, "2": 2, "3": 3])
    XCTAssertEqual(options.int16Dict, ["1": 1, "2": 2, "3": 3])
    XCTAssertEqual(options.int32Dict, ["1": 1, "2": 2, "3": 3])
    XCTAssertEqual(options.int64Dict, ["1": 1, "2": 2, "3": 3])
    XCTAssertEqual(options.uintDict, ["1": 1, "2": 2, "3": 3])
    XCTAssertEqual(options.uint8Dict, ["1": 1, "2": 2, "3": 3])
    XCTAssertEqual(options.uint16Dict, ["1": 1, "2": 2, "3": 3])
    XCTAssertEqual(options.uint32Dict, ["1": 1, "2": 2, "3": 3])
    XCTAssertEqual(options.uint64Dict, ["1": 1, "2": 2, "3": 3])
    XCTAssertEqual(options.floatDict, ["1": 1, "2": 2, "3": 3])
    XCTAssertEqual(options.doubleDict, ["1": 1, "2": 2, "3": 3])
    XCTAssertEqual(options.stringDict, ["1": "1", "2": "2", "3": "3"])
  }
  
  func testDecodeSimpleOptions() {
    var commands = [
      "--target", "target",
      "--verbose",
      "--config-path", "../path"
    ]
    do {
      var option = try OptionsDecoder().decode(SimpleOption.self, from: commands)
      XCTAssertEqual(option.target, ["target"])
      XCTAssertEqual(option.verbose, true)
      XCTAssertEqual(option.path.value, "default")
      XCTAssertEqual(option.path.location, 0)
      XCTAssertEqual(option.configPath, "../path")
      XCTAssertEqual(Set(option.locs), [1,2,3])
      option.arguments = []
      XCTAssertTrue(option.arguments.isEmpty)
    } catch {
      XCTFail()
    }
    
    commands += [
      "--locs", "1,2,3,4,5,6,7",
      "--locs", "8",
      "--locs", "9",
      "--locs", "0",
    ]
    do {
      var option = try OptionsDecoder().decode(SimpleOption.self, from: commands)
      XCTAssertEqual(option.target, ["target"])
      XCTAssertEqual(option.verbose, true)
      XCTAssertEqual(option.path.value, "default")
      XCTAssertEqual(option.path.location, 0)
      XCTAssertEqual(option.configPath, "../path")
      XCTAssertEqual(Set(option.locs), [1,2,3,4,5,6,7,8,9,0])
      option.arguments = []
      XCTAssertTrue(option.arguments.isEmpty)
    } catch {
      XCTFail()
    }
    
    commands += [
      "--path", "value=This is a path,location=12",
    ]
    do {
      var option = try OptionsDecoder().decode(SimpleOption.self, from: commands)
      XCTAssertEqual(option.target, ["target"])
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
      _ = try OptionsDecoder().decode(SimpleOption.self, from: commands + ["argument"])
    } catch OptionsDecoder.Error.unresolvableArguments {
      XCTAssertFalse(OptionsDecoder.Error.unresolvableArguments.description.isEmpty)
      XCTAssertTrue(true)
    } catch {
      XCTFail()
    }
  }
  
  func testDecodeArgumentsOptions() {
    do {
      var options = try! OptionsDecoder().decode(ArgumentsOptions.self, from: ["--bool", "boolValue", "args1", "args2"])
      XCTAssertEqual(options.arguments, ["boolValue", "args1", "args2"])
      
      options = try! OptionsDecoder().decode(ArgumentsOptions.self, from: ["--bool", "--", "boolValue", "args1", "args2"])
      XCTAssertEqual(options.arguments, ["boolValue", "args1", "args2"])
      
      options = try! OptionsDecoder().decode(ArgumentsOptions.self, from: ["--bool", "--", "-b", "boolValue", "-a", "args1", "args2"])
      XCTAssertEqual(options.arguments, ["-b", "boolValue", "-a", "args1", "args2"])
      
      options = try! OptionsDecoder().decode(ArgumentsOptions.self, from: ["--bool", "boolValue", "--", "args1", "args2"])
      XCTAssertEqual(options.arguments, ["boolValue", "args1", "args2"])
      
      options = try! OptionsDecoder().decode(ArgumentsOptions.self, from: ["--bool", "boolValue", "args1", "--", "args2"])
      XCTAssertEqual(options.arguments, ["boolValue", "args1", "args2"])
    }
    
    do {
      _ = try OptionsDecoder().decode(ArgumentsOptions.self, from: ["--bool=boolValue", "args1", "args2"])
      XCTFail()
    } catch OptionsDecoder.Error.decodingError(DecodingError.typeMismatch(let type, let ctx)) {
      XCTAssertTrue(true)
      XCTAssertTrue(type is Bool.Type)
      XCTAssertFalse(OptionsDecoder.Error.decodingError(DecodingError.typeMismatch(type, ctx)).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try OptionsDecoder().decode(ArgumentsOptions.self, from: ["--bool", "boolValue", "--", "args1", "--", "args2"])
      XCTFail()
    } catch OptionsDecoder.Error.unexpectedEndsOfOptions(markedArgs: let args) {
      XCTAssertTrue(true)
      XCTAssertFalse(args.isEmpty)
      XCTAssertEqual(args.set, ["--bool", "boolValue", "--", "args1", "↓--", "args2"])
      XCTAssertFalse(OptionsDecoder.Error.unexpectedEndsOfOptions(markedArgs: args).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      var options = try! OptionsDecoder().decode(DictArgumentsOptions.self, from: ["--bool", "key1=val1", "key2=val2", "key3=val3"])
      XCTAssertEqual(options.arguments.set, [["key1": "val1"], ["key2": "val2"], ["key3": "val3"]])
      
      options = try! OptionsDecoder().decode(DictArgumentsOptions.self, from: ["--bool", "--", "key1=val1", "key2=val2", "key3=val3"])
      XCTAssertEqual(options.arguments.set, [["key1": "val1"], ["key2": "val2"], ["key3": "val3"]])
    }
    do {
      var options = try! OptionsDecoder().decode(ArrayArgumentsOptions.self, from: ["--bool", "1", "2", "3"])
      XCTAssertEqual(options.arguments.set, [[UInt32(1)], [UInt32(2)], [UInt32(3)]])
      
      options = try! OptionsDecoder().decode(ArrayArgumentsOptions.self, from: ["--bool", "--", "1", "2", "3"])
      XCTAssertEqual(options.arguments.set, [[UInt32(1)], [UInt32(2)], [UInt32(3)]])
    }
    do {
      _ = try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "Bool", "-S", "String", "-i", "5"])
      // XCTFail()
    } catch OptionsDecoder.Error.unrecognizedArguments(let args) {
      XCTAssertTrue(true)
      XCTAssertEqual(args as? [String], ["Bool"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedArguments(args).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "Bool", "-S", "String", "String", "-i", "5"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedArguments(let args) {
      XCTAssertTrue(true)
      XCTAssertEqual((args as? [String])?.set, ["Bool", "String"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedArguments(args).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "Bool", "-S=String", "-i=5"])
      // XCTFail()
    } catch OptionsDecoder.Error.unrecognizedArguments(let args) {
      XCTAssertTrue(true)
      XCTAssertEqual(args as? [String], ["Bool"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedArguments(args).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "Bool", "-S=String", "String", "-i=5", "Int"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedArguments(let args) {
      XCTAssertTrue(true)
      XCTAssertEqual((args as? [String])?.set, ["Bool", "String", "Int"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedArguments(args).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "Bool", "-vS=String", "-i=5"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let decoder, decodeError: let error) {
      XCTAssertTrue(true)
      XCTAssertEqual(options.set, ["v", "S"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: decoder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    XCTAssertNoThrow(try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "-S", "String", "-i", "5"]))
    XCTAssertNoThrow(try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "-S=String", "-i=5"]))
    XCTAssertNoThrow(try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "-S", "String", "-i", "5", "-v"]))
    XCTAssertNoThrow(try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-S", "String", "-i", "5", "-v", "-b"]))
    XCTAssertNoThrow(try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-S", "String", "-i", "5", "-vb"]))
    XCTAssertNoThrow(try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-S", "String", "-i", "5", "-bv"]))
    
    do {
      _ = try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "Bool", "-S", "String", "InvalidString", "-i", "5"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedArguments(let args) {
      XCTAssertTrue(true)
      XCTAssertEqual((args as? [String]).map { Set($0) }, ["Bool", "InvalidString"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedArguments(args).description.isEmpty)
    } catch {
      XCTFail()
    }
  }
  
  func testDecodeErrors() {
    XCTAssertNoThrow(try OptionsDecoder().decode(KeyedOptions.self, from: ["--dict", "key1=val1,key2=val2"]))
    XCTAssertNoThrow(try OptionsDecoder().decode(KeyedOptions.self, from: ["--dict", "key1=val1", "key2=val2"]))
    XCTAssertNoThrow(try OptionsDecoder().decode(KeyedOptions.self, from: ["--dict", "key1=val1\\\\=33,key2=val2"]))
    do {
      _ = try OptionsDecoder().decode(KeyedOptions.self, from: ["--dict", "key1=val1=3,key2=val2"])
      XCTFail()
    } catch OptionsDecoder.Error.invalidKeyValuePairs(pairs: let pairs) {
      XCTAssertEqual(Set(pairs), ["key1", "val1", "3"])
      XCTAssertFalse(OptionsDecoder.Error.invalidKeyValuePairs(pairs: pairs).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try OptionsDecoder().decode(KeyedOptions.self, from: ["--dict", "key1=val1,key2val2"])
      XCTFail()
    } catch OptionsDecoder.Error.invalidKeyValuePairs(pairs: let pairs) {
      XCTAssertEqual(Set(pairs), ["key2val2"])
      XCTAssertFalse(OptionsDecoder.Error.invalidKeyValuePairs(pairs: pairs).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try OptionsDecoder().decode(KeyedOptions.self, from: ["--dict", "key1=val1,key2=val2", "--dict", "key1=val1,key2=val2"])
      XCTFail()
    } catch OptionsDecoder.Error.decodingError(DecodingError.typeMismatch(let type, let ctx)) {
      XCTAssertTrue(type is [String: Any].Type)
      XCTAssertFalse(OptionsDecoder.Error.decodingError(DecodingError.typeMismatch(type, ctx)).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try OptionsDecoder().decode(KeyedOptions.self, from: ["--dict", "key1=val1,key2=val2", "-d"])
      XCTFail()
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded, decoder: let decoder, decodeError: let error) {
      XCTAssertEqual(Set(options), ["d"])
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedOptions(options, decoded: decoded, decoder: decoder, decodeError: error).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    XCTAssertNoThrow(try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-S", "String", "-i", "5"]))
    
    do {
      _ = try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "Bool", "-S", "String", "-i", "5"])
      // XCTFail()
    } catch OptionsDecoder.Error.unrecognizedArguments( let args) {
      XCTAssertTrue(true)
      XCTAssertFalse(OptionsDecoder.Error.unrecognizedArguments(args).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "-S", "String", "--string", "String", "-i", "5"])
      XCTFail()
    } catch OptionsDecoder.Error.decodingError(DecodingError.typeMismatch(let type, let ctx)) {
      XCTAssertTrue(type is String.Type)
      XCTAssertFalse(OptionsDecoder.Error.decodingError(DecodingError.typeMismatch(type, ctx)).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "--string", "String", "--string", "String", "-i", "5"])
      XCTFail()
    } catch OptionsDecoder.Error.decodingError(DecodingError.typeMismatch(let type, let ctx)) {
      XCTAssertTrue(type is String.Type)
      XCTAssertFalse(OptionsDecoder.Error.decodingError(DecodingError.typeMismatch(type, ctx)).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "-S", "String", "-S", "String", "-i", "5"])
      XCTFail()
    } catch OptionsDecoder.Error.decodingError(DecodingError.typeMismatch(let type, let ctx)) {
      XCTAssertTrue(type is String.Type)
      XCTAssertFalse(OptionsDecoder.Error.decodingError(DecodingError.typeMismatch(type, ctx)).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "-S", "String", "-i", "Int"])
      XCTFail()
    } catch OptionsDecoder.Error.decodingError(DecodingError.typeMismatch(let type, let ctx)) {
      XCTAssertTrue(true)
      XCTAssertTrue(type is Int.Type)
      XCTAssertFalse(OptionsDecoder.Error.decodingError(DecodingError.typeMismatch(type, ctx)).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "-i", "Int"])
      XCTFail()
    } catch OptionsDecoder.Error.decodingError(DecodingError.keyNotFound(let key, let ctx)) {
      XCTAssertTrue(true)
      XCTAssertEqual(key.stringValue, ComplexArgumentsOptions.OptionKeys.string.stringValue)
      XCTAssertFalse(OptionsDecoder.Error.decodingError(DecodingError.keyNotFound(key, ctx)).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try OptionsDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "-S", "-i", "5"])
      XCTFail()
    } catch OptionsDecoder.Error.decodingError(DecodingError.valueNotFound(let type, let ctx)) {
      XCTAssertTrue(true)
      XCTAssertTrue(type is String.Type)
      XCTAssertFalse(OptionsDecoder.Error.decodingError(DecodingError.valueNotFound(type, ctx)).description.isEmpty)
    } catch {
      XCTFail()
    }
  }
  
  func testDefaultValueOptionsDecode() {
    var options = try! OptionsDecoder().decode(DefaultValueOptions.self, from: [])
    XCTAssertNil(options.bool)
    XCTAssertNotNil(options.dict)
    XCTAssertEqual(options.string, "default")

    options = try! OptionsDecoder().decode(DefaultValueOptions.self, from: ["--string", "string"])
    XCTAssertNil(options.bool)
    XCTAssertNotNil(options.dict)
    XCTAssertEqual(options.string, "string")
    
    options = try! OptionsDecoder().decode(DefaultValueOptions.self, from: ["--dict", "k=v"])
    XCTAssertNil(options.bool)
    XCTAssertNotNil(options.dict)
    XCTAssertEqual(options.dict, ["k": "v"])
    XCTAssertEqual(options.string, "default")

    options = try! OptionsDecoder().decode(DefaultValueOptions.self, from: ["--string", "string", "--dict", "k=v"])
    XCTAssertNil(options.bool)
    XCTAssertNotNil(options.dict)
    XCTAssertEqual(options.string, "string")
    XCTAssertEqual(options.dict, ["k": "v"])
    
    do {
      _ = try OptionsDecoder().decode(MismatchTypeDefaultValueOptions.self, from: ["--string", "string"])
      XCTFail()
    } catch OptionsDecoder.Error.decodingError(DecodingError.typeMismatch(let type, let ctx)) {
      XCTAssertTrue(true)
      XCTAssertTrue(type is [String: Any].Type)
      XCTAssertFalse(OptionsDecoder.Error.decodingError(DecodingError.typeMismatch(type, ctx)).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try OptionsDecoder().decode(MismatchTypeDefaultValueOptions.self, from: ["--dict", "k=v"])
      XCTFail()
    } catch OptionsDecoder.Error.decodingError(DecodingError.typeMismatch(let type, let ctx)) {
      XCTAssertTrue(true)
      XCTAssertTrue(type is String.Type)
      XCTAssertFalse(OptionsDecoder.Error.decodingError(DecodingError.typeMismatch(type, ctx)).description.isEmpty)
    } catch {
      XCTFail()
    }
  }
  
  func testContainerValueDecoding() {
    XCTAssertNoThrow(try OptionsDecoder().decode(ArrayOptions.self, from: ["--array-value", "1,2,3,4", "--string-value", "string"]))
    XCTAssertNoThrow(try OptionsDecoder().decode(ArrayOptions.self, from: ["--array-value", "single", "--string-value", "string1,string2"]))
    
    XCTAssertNoThrow(try OptionsDecoder().decode(DictOptions.self, from: ["--dict-value", "key1=val1,key2=val2,key3=val3", "--string-value", "string"]))
    XCTAssertNoThrow(try OptionsDecoder().decode(DictOptions.self, from: ["--dict-value", "singleKey=singleValue", "--string-value", "key1=val1,key2=val2,key3=val3"]))
  }
}
