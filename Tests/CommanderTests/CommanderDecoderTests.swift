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

extension Array where Element: Hashable {
  var set: Set<Element> {
    return Set(self)
  }
}

// MARK: - Mocks.

struct PrimaryOptions: OptionsRepresentable {
  
  public enum CodingKeys: String, CodingKey, StringRawRepresentable {
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
  
  static var description: [(CodingKeys, OptionKeyDescription)] = []
  
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
}

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

struct KeyedOptions: OptionsRepresentable {
  typealias ArgumentsResolver = AnyArgumentsResolver<String>
  enum CodingKeys: String, CodingKey, StringRawRepresentable {
    case dict
  }
  static var description: [(CodingKeys, OptionKeyDescription)] = [
    (.dict, .usage("")),
  ]
  
  let dict: [String: String]
}

// MARK: - CommanderDecoderTests.

class CommanderDecoderTests: XCTestCase {
  static var allTests = [
    ("testDecodeInContainer", testDecodeInContainer),
    ("testDecodeSimpleOptions", testDecodeSimpleOptions),
  ]
  
  func testUtils() {
    XCTAssertNil("".endsIndex(matchs: "--"))
    XCTAssertNil("-".endsIndex(matchs: "--"))
    XCTAssertNil("-+".endsIndex(matchs: "--"))
    XCTAssertNotNil("---".endsIndex(matchs: "--"))
    XCTAssertTrue("--".endsIndex(matchs: "--") == "--".endIndex)
    
    var array = [[Int]]()
    array.lastAppend(0)
    XCTAssertNil(array.last)
    array = [[]]
    array.lastAppend(0)
    XCTAssertEqual([0], array.last)
  }
  
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
  
  func testDecodePrimaryOptions() {
    let options = try! CommanderDecoder().decode(PrimaryOptions.self, from: [
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
    let commands = [
      "--target", "target",
      "--verbose",
      "--path", "value=This is a path,location=12",
      "--config-path", "../path",
      "--locs", "1,2,3,4,5,6,7",
      "--locs", "8",
      "--locs", "9",
      "--locs", "0",
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
    } catch CommanderDecoder.Error.unresolvableArguments {
      XCTAssertFalse(CommanderDecoder.Error.unresolvableArguments.description.isEmpty)
      XCTAssertTrue(true)
    } catch {
      XCTFail()
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
      XCTAssertFalse(CommanderDecoder.Error.unrecognizedArguments(args).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try CommanderDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "Bool", "-S", "String", "InvalidString", "-i", "5"])
      XCTFail()
    } catch CommanderDecoder.Error.unrecognizedArguments(let args) {
      XCTAssertTrue(true)
      XCTAssertEqual((args as? [String]).map { Set($0) }, ["Bool", "InvalidString"])
      XCTAssertFalse(CommanderDecoder.Error.unrecognizedArguments(args).description.isEmpty)
    } catch {
      XCTFail()
    }
  }
  
  func testDecodeErrors() {
    XCTAssertNoThrow(try CommanderDecoder().decode(KeyedOptions.self, from: ["--dict", "key1=val1,key2=val2"]))
    do {
      _ = try CommanderDecoder().decode(KeyedOptions.self, from: ["--dict", "key1=val1=3,key2=val2"])
      XCTFail()
    } catch CommanderDecoder.Error.invalidKeyValuePairs(pairs: let pairs) {
      XCTAssertEqual(Set(pairs), ["key1", "val1", "3"])
      XCTAssertFalse(CommanderDecoder.Error.invalidKeyValuePairs(pairs: pairs).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try CommanderDecoder().decode(KeyedOptions.self, from: ["--dict", "key1=val1,key2=val2", "--dict", "key1=val1,key2=val2"])
      XCTFail()
    } catch CommanderDecoder.Error.decodingError(DecodingError.typeMismatch(let type, let ctx)) {
      XCTAssertTrue(type is [String: Any].Type)
      XCTAssertFalse(CommanderDecoder.Error.decodingError(DecodingError.typeMismatch(type, ctx)).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try CommanderDecoder().decode(KeyedOptions.self, from: ["--dict", "key1=val1,key2=val2", "-d"])
      XCTFail()
    } catch CommanderDecoder.Error.unrecognizedOptions(let options) {
      XCTAssertEqual(Set(options), ["d"])
      XCTAssertFalse(CommanderDecoder.Error.unrecognizedOptions(options).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try CommanderDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "Bool", "-S", "String", "-i", "5"])
      XCTFail()
    } catch CommanderDecoder.Error.unrecognizedArguments( let args) {
      XCTAssertTrue(true)
      XCTAssertFalse(CommanderDecoder.Error.unrecognizedArguments(args).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try CommanderDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "-S", "String", "--string", "String", "-i", "5"])
      XCTFail()
    } catch CommanderDecoder.Error.decodingError(DecodingError.typeMismatch(let type, let ctx)) {
      XCTAssertTrue(type is String.Type)
      XCTAssertFalse(CommanderDecoder.Error.decodingError(DecodingError.typeMismatch(type, ctx)).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try CommanderDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "--string", "String", "--string", "String", "-i", "5"])
      XCTFail()
    } catch CommanderDecoder.Error.decodingError(DecodingError.typeMismatch(let type, let ctx)) {
      XCTAssertTrue(type is String.Type)
      XCTAssertFalse(CommanderDecoder.Error.decodingError(DecodingError.typeMismatch(type, ctx)).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try CommanderDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "-S", "String", "-S", "String", "-i", "5"])
      XCTFail()
    } catch CommanderDecoder.Error.decodingError(DecodingError.typeMismatch(let type, let ctx)) {
      XCTAssertTrue(type is String.Type)
      XCTAssertFalse(CommanderDecoder.Error.decodingError(DecodingError.typeMismatch(type, ctx)).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try CommanderDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "-S", "String", "-i", "Int"])
      XCTFail()
    } catch CommanderDecoder.Error.decodingError(DecodingError.typeMismatch(let type, let ctx)) {
      XCTAssertTrue(true)
      XCTAssertTrue(type is Int.Type)
      XCTAssertFalse(CommanderDecoder.Error.decodingError(DecodingError.typeMismatch(type, ctx)).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try CommanderDecoder().decode(ComplexArgumentsOptions.self, from: ["-S", "String", "-i", "Int"])
      XCTFail()
    } catch CommanderDecoder.Error.decodingError(DecodingError.keyNotFound(let key, let ctx)) {
      XCTAssertTrue(true)
      XCTAssertEqual(key.stringValue, ComplexArgumentsOptions.CodingKeys.bool.stringValue)
      XCTAssertFalse(CommanderDecoder.Error.decodingError(DecodingError.keyNotFound(key, ctx)).description.isEmpty)
    } catch {
      XCTFail()
    }
    
    do {
      _ = try CommanderDecoder().decode(ComplexArgumentsOptions.self, from: ["-b", "-S", "-i", "5"])
      XCTFail()
    } catch CommanderDecoder.Error.decodingError(DecodingError.valueNotFound(let type, let ctx)) {
      XCTAssertTrue(true)
      XCTAssertTrue(type is String.Type)
      XCTAssertFalse(CommanderDecoder.Error.decodingError(DecodingError.valueNotFound(type, ctx)).description.isEmpty)
    } catch {
      XCTFail()
    }
  }
}
