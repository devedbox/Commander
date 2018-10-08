//
//  CommanderDecoder.swift
//  Commander
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

import Foundation

// MARK: -

internal extension String {
  /// Perform the exact match with the given pattern and return the index where match ends.
  ///
  /// - Parameter pattern: The pattern to be matched.
  /// - Returns: The ends index.
  internal func endsIndex(matchs pattern: String) -> Index? {
    guard !isEmpty, endIndex >= pattern.endIndex else {
      return nil
    }
    
    var index = pattern.startIndex
    
    while index < pattern.endIndex, index < endIndex {
      if pattern[index] != self[index] {
        return nil
      }
      pattern.formIndex(after: &index)
    }
    
    return index
  }
  /// Returns a bool value indicates if the string is containing only one character.
  internal var isSingle: Bool {
    guard !isEmpty else {
      return false
    }
    return startIndex == index(before: endIndex)
  }
}

internal extension Array where Element: RangeReplaceableCollection {
  /// Appends the given element to the receiver's last collection element.
  internal mutating func lastAppend(_ element: Element.Element) {
    guard var last = popLast() else {
      return
    }
    
    last.append(element)
    append(last)
  }
}

internal extension BidirectionalCollection {
  /// Returns a bool value indicates if the collection is containing only one element.
  internal var isSingle: Bool {
    return startIndex == index(before: endIndex)
  }
}

// MARK: swift-corelibs-foundation

internal extension DecodingError {
  /// Returns a `.typeMismatch` error describing the expected type.
  ///
  /// - parameter path: The path of `CodingKey`s taken to decode a value of this type.
  /// - parameter expectation: The type expected to be encountered.
  /// - parameter reality: The value that was encountered instead of the expected type.
  /// - returns: A `DecodingError` with the appropriate path and debug description.
  fileprivate static func __typeMismatch(at path: [CodingKey], expectation: Any.Type, reality: Any?) -> DecodingError {
    let description = "Expected to decode '\(expectation)' but found \(__typeDescription(of: reality)) instead"
    return .typeMismatch(expectation, Context(codingPath: path, debugDescription: description))
  }
  
  /// Returns a description of the type of `value` appropriate for an error message.
  ///
  /// - parameter value: The value whose type to describe.
  /// - returns: A string describing `value`.
  /// - precondition: `value` is one of the types below.
  fileprivate static func __typeDescription(of value: Any?) -> String {
    if /* value is NSNull || */ value == nil {
      return "a null value"
    }/* else if value is NSNumber /* FIXME: If swift-corelibs-foundation isn't updated to use NSNumber, this check will be necessary: || value is Int || value is Double */ {
      return "a number"
    } */else if value is String {
      return "a string/data"
    } else if value is [Any] {
      return "an array"
    } else if value is [String : Any] {
      return "a dictionary"
    } else {
      return "\(type(of: value))"
    }
  }
  /// Returns the descriptions of coding paths.
  ///
  /// - Parameter codingPath: The coding path consists of keys to be described.
  fileprivate static func __codingPathDescription(of codingPath: [CodingKey]) -> String? {
    guard !codingPath.isEmpty else {
      return nil
    }
    
    return "Decoding paths: '\(codingPath.map { $0.description }.joined(separator: " -> "))'."
  }
}

// MARK: - Error.

extension CommanderDecoder {
  public enum Error: CustomStringConvertible, Swift.Error {
    case decodingError(DecodingError)
    case invalidKeyValuePairs(pairs: [String])
    case unrecognizedArguments([Any])
    case unrecognizedOptions([String])
    case unresolvableArguments
    case unexpectedEndsOfOptions(markedArgs: [String])
    
    public var description: String {
      switch self {
      case .decodingError(let error):
        switch error {
        case .dataCorrupted(let ctx):
          return "Data corrupted decoding error: \(ctx.debugDescription). \(DecodingError.__codingPathDescription(of: ctx.codingPath) ?? "")"
        case .keyNotFound(_, let ctx):
          return "Key not found decoding error: \(ctx.debugDescription). \(DecodingError.__codingPathDescription(of: ctx.codingPath) ?? "")"
        case .typeMismatch(_, let ctx):
          return "Type mismatch decoding error: \(ctx.debugDescription). \(DecodingError.__codingPathDescription(of: ctx.codingPath) ?? "")"
        case .valueNotFound(_, let ctx):
          return "Value not found decoding error: \(ctx.debugDescription). \(DecodingError.__codingPathDescription(of: ctx.codingPath) ?? "")"
        }
      case .invalidKeyValuePairs(let pairs):
        return "Invalid key-value pairs given: \(pairs.joined(separator: " "))."
      case .unrecognizedArguments(let args):
        return "Unrecognized arguments '\(args.map { String(describing: $0) }.joined(separator: " "))'."
      case .unrecognizedOptions(let options):
        return "Unrecognized options '\(options.joined(separator: " "))'."
      case .unresolvableArguments:
        return "The arguments can not be resolved."
      case .unexpectedEndsOfOptions(markedArgs: let args):
        return "Unexpected ends of options at: '\(args.joined(separator: " "))'"
      }
    }
  }
}

// MARK: - OptionsFormat.

extension CommanderDecoder {
  /// The options parsing splitter format.
  public enum OptionsFormat {
    case format(String, short: String)
  }
}

// MARK: - ObjectFormat.

fileprivate extension Dictionary where Value == CommanderDecoder.ObjectFormat.Value {
  fileprivate var unwrapped: Any? {
    return mapValues { $0.unwrapped }
  }
}

fileprivate extension Dictionary where Key == String, Value == [CommanderDecoder.ObjectFormat.Value] {
  fileprivate var lastKeyedArguments: (key: Key, value: Value)? {
    return self.first { $0.key.hasSuffix("-\(count-1)") }
  }
  
  fileprivate var lastArguments: Value? {
    return lastKeyedArguments?.1
  }
  
  fileprivate mutating func lastAppendEmptyContainer(for key: String) {
    self["\(key)-\(count)"] = []
  }
}

fileprivate extension Array where Element == CommanderDecoder.ObjectFormat.Value {
  fileprivate var unwrapped: Any? {
    return compactMap { $0.unwrapped }
  }
}

fileprivate extension Encodable {
  fileprivate var wrapped: CommanderDecoder.ObjectFormat.Value? {
    if
      let jsonData = try? JSONEncoder().encode(self),
      let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: [])
    {
      return .value(jsonObject)
    }
    
    return nil
  }
}

extension CommanderDecoder {
  /// The object format of the value of options.
  internal enum ObjectFormat {
    /// Wrapped value type represents the available values in `CommanderDecoder`.
    internal struct Value {
      internal enum Error: String, Swift.Error {
        case jsonObjectFormatIsNotSupported = "Object format error: The JSON object format is not supported"
      }
      
      /// Underlying dictionary value of `[String: Value]`.
      internal var dictionaryValue: [String: Value]?
      /// Underlying array value of `[Value]`.
      internal var arrayValue: [Value]?
      /// Underlying string value of `String`.
      internal let stringValue: String?
      /// Underlying bool value of `Bool`.
      internal var boolValue: Bool?
      
      /// Returns the unwrapped underlying value.
      internal var unwrapped: Any? {
        return dictionaryValue?.unwrapped ?? singleArrayString?.stringValue ?? arrayValue ?? stringValue ?? boolValue
      }
      
      internal var singleArrayString: Value? {
        if
          let array = arrayValue,
          array.isSingle,
          let string = stringValue,
          let singleString = array.last?.stringValue,
          singleString == string
        { // Consider single-element array is a wrap of contained string.
          return .init(arrayValue: arrayValue, stringValue: string)
        } else {
          return nil
        }
      }
      
      internal init(
        dictionaryValue: [String: Value]? = nil,
        arrayValue: [Value]? = nil,
        stringValue: String? = nil,
        boolValue: Bool? = nil)
      {
        self.dictionaryValue = dictionaryValue
        self.arrayValue = arrayValue
        self.stringValue = stringValue
        self.boolValue = boolValue
      }
      
      internal static func value(_ value: Any?) -> Value? {
        if let value = value {
          if let dict = value as? [String: Any] {
            return .dictionary(dict.mapValues { Value.value($0) ?? .init() })
          } else if let array = value as? [Any] {
            return .array(array.map { Value.value($0) ?? .init() })
          } else if let string = value as? String {
            return .init(stringValue: string, boolValue: true)
          } else if let string = value as? _StringStorable {
            return .init(stringValue: string._stored, boolValue: true)
          } else if let bool = value as? Bool {
            return .bool(bool)
          } else if let encodable = value as? Encodable {
            return encodable.wrapped
          } else if value is NSNull {
            return .init()
          }
        }
        return nil
      }
      
      internal static func dictionary(_ dict: [String: Value]) -> Value {
        return Value(dictionaryValue: dict)
      }
      internal static func array(_ array: [Value]) -> Value {
        return Value(arrayValue: array)
      }
      internal static func string(_ string: String) -> Value {
        return Value(stringValue: string)
      }
      internal static func bool(_ bool: Bool) -> Value {
        return Value(boolValue: bool)
      }
    }
    
    @available(*, unavailable)
    case json // TODO: The json format is not available for now...
    /// Represents the flatten container without nested contaniners.
    case flatContainer(splitter: Character, keyValuePairsSplitter: Character)
    
    /// Returns the wrapped value with the given string.
    internal func value(for string: String) throws -> Value {
      var arrayContainer: [Value]? = nil
      var dictContainer: [String: Value]? = nil
      
      switch self {
      case .flatContainer(splitter: let splitter, keyValuePairsSplitter: let keyValuePairsSplitter):
        if string.contains(splitter) || string.contains(keyValuePairsSplitter) {
          let elements = string.split(separator: splitter)
          if string.contains(keyValuePairsSplitter) {
            dictContainer = try elements.reduce([:], { result, next -> [String: Value] in
              let keyValuePairs = next.split(separator: keyValuePairsSplitter)
              guard keyValuePairs.count == 2 else {
                throw Error.invalidKeyValuePairs(pairs: keyValuePairs.map { String($0) })
              }
              let value: Value = .string(String(keyValuePairs[1]))
              return result.merging([String(keyValuePairs[0]): value]) { _ , new in new }
            })
          } else {
            arrayContainer = elements.map { Value(stringValue: String($0)) }
          }
        } else { // Consider an array with single element.
          arrayContainer = [Value(stringValue: string)]
        }
        break
      case .json:
        throw Value.Error.jsonObjectFormatIsNotSupported
      }
      return Value(dictionaryValue: dictContainer, arrayValue: arrayContainer, stringValue: string)
    }
  }
}

// MARK: - CommanderDecoder.

public final class CommanderDecoder {
  
  internal static var optionsFormat = OptionsFormat.format("--", short: "-")
  internal static var objectFormat = ObjectFormat.flatContainer(splitter: ",", keyValuePairsSplitter: "=")
  
  internal private(set) var codingKeys: [String: Character] = [:]
  internal private(set) var optionsDescription: [String: OptionDescription] = [:]
  internal private(set) var codingArguments: [String: [ObjectFormat.Value]]!
  
  public init() { }
  
  internal func container(from commandLineArgs: [String]) throws -> ObjectFormat.Value {
    var container: [String: ObjectFormat.Value] = [:]
    var arguments: [String: [ObjectFormat.Value]] = ["command-0":[]]
    var option: String?
    
    func set(value: ObjectFormat.Value, for key: String) {
      var optionKey = key
      if
        key.isSingle,
        let symbolKey = codingKeys.first(where: { $0.value == key.first })?.key
      {
        optionKey = symbolKey
      }
      
      if var optionValue = container[optionKey] { // Consider an array.
        if var array = optionValue.arrayValue {
          array.append(value)
          optionValue.arrayValue = array
          container[optionKey] = optionValue
        } else {
          container[optionKey] = .array([optionValue, value])
        }
      } else {
        container[optionKey] = value
      }
    }
    
    func advance(with key: String?) {
      option.map { set(value: .bool(true), for: $0) }
      option = key
    }
    
    switch type(of: self).optionsFormat {
    case .format(let symbol, short: let shortSymbol):
      var index = commandLineArgs.startIndex
      var isAtEndOfOptions: Bool = false
      
      while index < commandLineArgs.endIndex, let item = Optional.some(commandLineArgs[index]) {
        if
          let symbolIndex = item.endsIndex(matchs: symbol),
          let key = Optional.some(String(item[symbolIndex...]))
        {
          if key.isEmpty { // Consider pattern '--' as the ends of options. This is optional in Commander.
            if isAtEndOfOptions {
              var args = commandLineArgs; args[index] = "↓\(args[index])"
              throw Error.unexpectedEndsOfOptions(markedArgs: args)
            } else {
              isAtEndOfOptions = true
              commandLineArgs.formIndex(after: &index)
              continue
            }
          }
          advance(with: key)
          arguments.lastAppendEmptyContainer(for: key)
        } else if
          !isAtEndOfOptions,
          let symbolIndex = item.endsIndex(matchs: shortSymbol),
          let key = Optional.some(String(item[symbolIndex...]))
        {
          advance(with: nil)
          if key.isSingle {
            advance(with: key)
          } else {
            key.forEach { set(value: .bool(true), for: String($0)) }
            option = nil
          }
          arguments.lastAppendEmptyContainer(for: key)
        } else {
          var value = try type(of: self).objectFormat.value(for: item)
          value.boolValue = true
          if option == nil {
            var last = arguments.lastKeyedArguments
            last?.value.append(value)
            last.map { arguments[$0.key] = $0.value }
          } else {
            set(value: value, for: option!)
            option = nil
          }
        }
        
        commandLineArgs.formIndex(after: &index)
      }
    }
    
    option.map { set(value: .init(boolValue: true), for: $0) }
    
    return ObjectFormat.Value(
      dictionaryValue: container,
      arrayValue: [.dictionary(arguments.mapValues {
        ObjectFormat.Value.array($0)
      })]
    )
  }
  
  public func decode<T: OptionsRepresentable>(
    _ type: T.Type,
    from commandLineArgs: [String]) throws -> T
  {
    optionsDescription = T.descriptions.reduce(into: [:]) { $0[$1.key.stringValue] = $1.value }
    defer { optionsDescription = [:] }
    
    codingKeys = T.keys.reduce(into: [:]) { $0[$1.key.stringValue] = $1.value }
    defer { codingKeys = [:] }
    
    var container = try self.container(from: commandLineArgs)
    
    codingArguments = container.arrayValue?.first?.dictionaryValue?.mapValues { $0.arrayValue! }
    defer { codingArguments = nil }
    
    let unrecognizedOptions = container.dictionaryValue?.keys.filter { key in
      type.CodingKeys.init(rawValue: key) == nil
    }
    
    guard unrecognizedOptions?.isEmpty ?? true else {
      throw CommanderDecoder.Error.unrecognizedOptions(unrecognizedOptions!)
    }
    
    let decoder = _Decoder(referencing: self, wrapping: container)
    var decoded = try decoder.decode(as: type)
    
    let validArguments = codingArguments.filter { !$0.value.isEmpty }
    
    if
      let isLastArgumentsEmpty = codingArguments.lastArguments?.isEmpty,
      isLastArgumentsEmpty,
      !validArguments.isEmpty
    {
      throw CommanderDecoder.Error.unrecognizedArguments(Array(validArguments.values.flatMap { $0 }).compactMap { $0.unwrapped })
    } else {
      if !validArguments.isEmpty {
        container.arrayValue = Array(validArguments.values).last
        if let args = container.arrayValue, !args.isEmpty {
          decoder.container = .init(container, referencing: self)
          decoder.storage = .init()
          decoder.storage.push(container)
          decoded.arguments = try decoder.decode(as: [T.ArgumentsResolver.Argument].self)
        }
      }
    }
    
    return decoded
  }
  
  private func spitArgument(for key: CodingKey, with value: ObjectFormat.Value) {
    var arguments = codingArguments.first { arg in
      arg.key.hasPrefix(key.stringValue) ||
      (codingKeys[key.stringValue]).map { arg.key.hasPrefix(String($0)) } ?? false
    }
    arguments?.value.insert(value, at: 0)
    arguments.map { codingArguments[$0.key] = $0.value }
  }
}

// MARK: - ConcreteDecoder.

extension CommanderDecoder {
  internal class _Decoder: Decoder {
    internal private(set) var codingPath: [CodingKey]
    fileprivate var storage = _Storage()
    fileprivate var container: _KeyedContainer
    internal var userInfo: [CodingUserInfoKey: Any] = [:]
    
    internal init(
      referencing commanderDecoder: CommanderDecoder,
      wrapping value: ObjectFormat.Value,
      at codingPath: [CodingKey] = [])
    {
      self.container = _KeyedContainer(value, referencing: commanderDecoder)
      self.codingPath = codingPath
      self.storage.push(value)
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
      guard let top = storage.top?.dictionaryValue else {
        throw CommanderDecoder.Error.decodingError(
          .__typeMismatch(at: codingPath, expectation: [String: Any].self, reality: nil)
        )
      }
      
      return KeyedDecodingContainer<Key>(
        _KeyedDecodingContainer(
          referencing: self,
          wrapping: _Decoder._KeyedContainer(.init(dictionaryValue: top), referencing: container.decoder)
        )
      )
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
      guard let top = storage.top?.arrayValue else {
        throw CommanderDecoder.Error.decodingError(
          .__typeMismatch(at: codingPath, expectation: [Any].self, reality: nil)
        )
      }
      
      return _UnkeyedDecodingContainer(referencing: self, wrapping: top)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
      return self
    }
    
    func decode<T: Decodable>(as: T.Type) throws -> T {
      return try T.init(from: self)
    }
  }
}

// MARK: - _KeyedContainer.

extension CommanderDecoder._Decoder {
  fileprivate struct _KeyedContainer {
    fileprivate let storage: CommanderDecoder.ObjectFormat.Value
    fileprivate let decoder: CommanderDecoder
    
    fileprivate init(
      _ value: CommanderDecoder.ObjectFormat.Value,
      referencing decoder: CommanderDecoder)
    {
      self.storage = value
      self.decoder = decoder
    }
    
    fileprivate subscript(key: String) -> CommanderDecoder.ObjectFormat.Value? {
      return storage.dictionaryValue?[key] ?? .value(decoder.optionsDescription[key]?.defaultValue)
    }
  }
}

// MARK: - _Storage.

extension CommanderDecoder._Decoder {
  fileprivate struct _Storage {
    fileprivate var storage: [CommanderDecoder.ObjectFormat.Value] = []
    fileprivate var top: CommanderDecoder.ObjectFormat.Value? {
      return storage.last
    }
    fileprivate var lastUnwrapped: Any? {
      return top?.unwrapped
    }
    
    fileprivate mutating func push(_ value: CommanderDecoder.ObjectFormat.Value) {
      storage.append(value)
    }
    
    @discardableResult
    fileprivate mutating func pop() -> CommanderDecoder.ObjectFormat.Value? {
      return storage.popLast()
    }
  }
}

// MARK: - _Key.

extension CommanderDecoder._Decoder {
  internal struct _Key: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
      self.stringValue = stringValue
      self.intValue = nil
    }
    
    init?(intValue: Int) {
      self.intValue = intValue
      self.stringValue = "\(intValue)"
    }
    
    init(index: Int) {
      self.stringValue = "Index \(index)"
      self.intValue = index
    }
    
    internal var description: String {
      return stringValue + (intValue.map { " Index - \($0)" } ?? "")
    }
  }
}

// MARK: - _KeyedDecodingContainer.

extension CommanderDecoder._Decoder {
  internal struct _KeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    internal private(set) var decoder: CommanderDecoder._Decoder
    internal private(set) var codingPath: [CodingKey]
    fileprivate private(set) var container: CommanderDecoder._Decoder._KeyedContainer
    
    internal var allKeys: [Key] {
      return container.storage.dictionaryValue?.keys.compactMap { Key(stringValue: $0) } ?? []
    }
    
    fileprivate init(
      referencing decoder: CommanderDecoder._Decoder,
      wrapping container: CommanderDecoder._Decoder._KeyedContainer)
    {
      self.decoder = decoder
      self.container = container
      self.codingPath = decoder.codingPath
    }
    
    internal func contains(_ key: Key) -> Bool {
      return decoder.container[key.stringValue] != nil
    }
    
    internal func decodeNil(forKey key: Key) throws -> Bool {
      return container[key.stringValue]?.unwrapped == nil
    }
    
    internal func decode<T>(
      _ type: T.Type,
      forKey key: Key) throws -> T where T : Decodable
    {
      guard let entry = container[key.stringValue] else {
        throw CommanderDecoder.Error.decodingError(
          .keyNotFound(key, .init(codingPath: decoder.codingPath, debugDescription: "No value associated with key '\(key)'"))
        )
      }
      
      decoder.codingPath.append(key)
      defer { decoder.codingPath.removeLast() }
      
      decoder.storage.push(entry)
      defer { decoder.storage.pop() }
      
      return try T.init(from: decoder)
    }
    
    internal func nestedContainer<NestedKey>(
      keyedBy type: NestedKey.Type,
      forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey
    {
      decoder.codingPath.append(key)
      defer { decoder.codingPath.removeLast() }
      
      guard let value = self.container[key.stringValue] else {
        let desc = "Cannot get \(KeyedDecodingContainer<NestedKey>.self) -- no value found for key '\(key)'"
        throw CommanderDecoder.Error.decodingError(
          .keyNotFound(key, .init(codingPath: codingPath, debugDescription: desc))
        )
      }
      
      guard let dictionary = value.dictionaryValue else {
        throw CommanderDecoder.Error.decodingError(
          .__typeMismatch(at: codingPath, expectation: [String: Any].self, reality: value.unwrapped)
        )
      }
      
      let container = _KeyedDecodingContainer<NestedKey>(
        referencing: decoder,
        wrapping: CommanderDecoder._Decoder._KeyedContainer(
          .init(dictionaryValue: dictionary),
          referencing: decoder.container.decoder
        )
      )
      return KeyedDecodingContainer(container)
    }
    
    internal func nestedUnkeyedContainer(
      forKey key: Key) throws -> UnkeyedDecodingContainer
    {
      decoder.codingPath.append(key)
      defer { decoder.codingPath.removeLast() }
      
      guard let value = container[key.stringValue] else {
        let desc = "Cannot get UnkeyedDecodingContainer -- no value found for key '\(key)'"
        throw CommanderDecoder.Error.decodingError(
          .keyNotFound(key, .init(codingPath: codingPath, debugDescription: desc))
        )
      }
      
      guard let array = value.arrayValue else {
        throw CommanderDecoder.Error.decodingError(
          .__typeMismatch(at: codingPath, expectation: [Any].self, reality: type(of: value.unwrapped))
        )
      }
      
      return CommanderDecoder._Decoder._UnkeyedDecodingContainer(referencing: decoder, wrapping: array)
    }
    
    internal func superDecoder() throws -> Decoder {
      return try _superDecoder(forKey: Key(stringValue: "super")!)
    }
    
    internal func superDecoder(forKey key: Key) throws -> Decoder {
      return try _superDecoder(forKey: key)
    }
    
    private func _superDecoder(forKey key: Key) throws -> Decoder {
      decoder.codingPath.append(key)
      defer { decoder.codingPath.removeLast() }
      
      let value = container[key.stringValue]?.dictionaryValue ?? [:]
      return CommanderDecoder._Decoder(
        referencing: decoder.container.decoder,
        wrapping: .init(dictionaryValue: value)
      )
    }
  }
}

// MARK: - _UnkeyedDecodingContainer.

extension CommanderDecoder._Decoder {
  internal struct _UnkeyedDecodingContainer: UnkeyedDecodingContainer {
    internal var decoder: CommanderDecoder._Decoder
    internal var container: [CommanderDecoder.ObjectFormat.Value]
    
    internal var codingPath: [CodingKey] = []
    internal var count: Int? { return container.count }
    internal var isAtEnd: Bool {
      return currentIndex >= count!
    }
    internal var currentIndex: Int = 0
    
    internal init(
      referencing decoder: CommanderDecoder._Decoder,
      wrapping container: [CommanderDecoder.ObjectFormat.Value])
    {
      self.decoder = decoder
      self.container = container
    }
    
    internal mutating func decodeNil() throws -> Bool {
      guard !self.isAtEnd else {
        let codingPath = decoder.codingPath + [CommanderDecoder._Decoder._Key(index: currentIndex)]
        throw CommanderDecoder.Error.decodingError(
          .valueNotFound(Any?.self, .init(codingPath: codingPath, debugDescription: "Unkeyed container is at end"))
        )
      }
      
      if container[currentIndex].unwrapped == nil {
        currentIndex += 1
        return true
      } else {
        return false
      }
    }
    
    internal mutating func decode<T : Decodable>(_ type: T.Type) throws -> T {
      guard !self.isAtEnd else {
        let codingPath = decoder.codingPath + [CommanderDecoder._Decoder._Key(index: currentIndex)]
        throw CommanderDecoder.Error.decodingError(
          .valueNotFound(type, .init(codingPath: codingPath, debugDescription: "Unkeyed container is at end"))
        )
      }
      
      decoder.codingPath.append(CommanderDecoder._Decoder._Key(index: currentIndex))
      defer { decoder.codingPath.removeLast() }
      
      decoder.storage.push(container[currentIndex])
      defer { decoder.storage.pop() }
      
      currentIndex += 1
      return try T.init(from: decoder)
    }
    
    internal mutating func nestedContainer<NestedKey>(
      keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey
    {
      decoder.codingPath.append(CommanderDecoder._Decoder._Key(index: currentIndex))
      defer { decoder.codingPath.removeLast() }
      
      guard !self.isAtEnd else {
        throw CommanderDecoder.Error.decodingError(
          .valueNotFound(KeyedDecodingContainer<NestedKey>.self, .init(codingPath: codingPath, debugDescription: "Cannot get nested keyed container -- unkeyed container is at end"))
        )
      }
      
      let value = self.container[currentIndex]
      
      guard let dictionary = value.dictionaryValue else {
        throw CommanderDecoder.Error.decodingError(
          .__typeMismatch(at: codingPath, expectation: [String: Any].self, reality: value.unwrapped)
        )
      }
      
      currentIndex += 1
      let container = CommanderDecoder._Decoder._KeyedDecodingContainer<NestedKey>(
        referencing: decoder,
        wrapping: CommanderDecoder._Decoder._KeyedContainer(
          .init(dictionaryValue: dictionary),
          referencing: decoder.container.decoder
        )
      )
      return KeyedDecodingContainer(container)
    }
    
    internal mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
      decoder.codingPath.append(CommanderDecoder._Decoder._Key(index: currentIndex))
      defer { decoder.codingPath.removeLast() }
      
      guard !self.isAtEnd else {
        let desc = "Cannot get nested keyed container -- unkeyed container is at end"
        throw CommanderDecoder.Error.decodingError(
          .valueNotFound(UnkeyedDecodingContainer.self, .init(codingPath: codingPath, debugDescription: desc))
        )
      }
      
      let value = self.container[currentIndex]
      
      guard let array = value.arrayValue else {
        throw CommanderDecoder.Error.decodingError(
          .__typeMismatch(at: codingPath, expectation: [Any].self, reality: type(of: value.unwrapped))
        )
      }
      
      currentIndex += 1
      return _UnkeyedDecodingContainer(referencing: decoder, wrapping: array)
    }
    
    internal mutating func superDecoder() throws -> Decoder {
      decoder.codingPath.append(CommanderDecoder._Decoder._Key(index: currentIndex))
      defer { decoder.codingPath.removeLast() }
      
      guard !self.isAtEnd else {
        let desc = "Cannot get superDecoder() -- unkeyed container is at end"
        throw CommanderDecoder.Error.decodingError(
          .valueNotFound(Decoder.self, .init(codingPath: codingPath, debugDescription: desc))
        )
      }
      
      let value = container[currentIndex].dictionaryValue ?? [:]
      currentIndex += 1
      return CommanderDecoder._Decoder(
        referencing: decoder.container.decoder,
        wrapping: .init(dictionaryValue: value),
        at: decoder.codingPath
      )
    }
  }
}

// MARK: - SingleValueDecodingContainer.

extension CommanderDecoder._Decoder: SingleValueDecodingContainer {
  
  private func unwrap<T: Decodable & _StringInitable>(as type: T.Type) throws -> T {
    var unwrapped = storage.lastUnwrapped
    if T.self == String.self, unwrapped is Bool? {
      unwrapped = storage.top?.stringValue
    }
    
    if T.self == Bool.self {
      if !(unwrapped is Bool?) {
        var value: CommanderDecoder.ObjectFormat.Value?
        if let dict = storage.top?.dictionaryValue, !dict.isEmpty {
          value = .dictionary(dict)
        } else if let singleArrarString = storage.top?.singleArrayString {
          value = singleArrarString
        } else if let array = storage.top?.arrayValue, !array.isEmpty {
          value = .array(array)
        } else if let string = storage.top?.stringValue, !string.isEmpty {
          value = .init(stringValue: storage.top?.stringValue)
        }
        if value != nil {
          container.decoder.spitArgument(for: codingPath.last!, with: value!)
        }
      }
      
      guard let value = storage.top?.boolValue else {
        if unwrapped != nil {
          throw CommanderDecoder.Error.decodingError(
            .__typeMismatch(at: codingPath, expectation: type, reality: unwrapped)
          )
        } else {
          throw CommanderDecoder.Error.decodingError(
            .valueNotFound(
              type, .init(codingPath: codingPath, debugDescription: _valueNotFoundDesc(type, reality: unwrapped))
            )
          )
        }
      }
      
      return value as! T
    } else {
      guard let value = (unwrapped as? String).flatMap({ T.init($0) }) else {
        if unwrapped != nil {
          throw CommanderDecoder.Error.decodingError(
            .__typeMismatch(at: codingPath, expectation: type, reality: unwrapped)
          )
        } else {
          throw CommanderDecoder.Error.decodingError(
            .valueNotFound(
              type, .init(codingPath: codingPath, debugDescription: _valueNotFoundDesc(type, reality: unwrapped))
            )
          )
        }
      }
      return value
    }
  }
  
  internal func decodeNil() -> Bool {
    if let top = storage.top {
      return top.unwrapped == nil
    }
    
    return false
  }
  
  internal func decode(_ type: Bool.Type) throws -> Bool {
    return try unwrap(as: type)
  }
  
  internal func decode(_ type: Int.Type) throws -> Int {
    return try unwrap(as: type)
  }
  
  internal func decode(_ type: Int8.Type) throws -> Int8 {
    return try unwrap(as: type)
  }
  
  internal func decode(_ type: Int16.Type) throws -> Int16 {
    return try unwrap(as: type)
  }
  
  internal func decode(_ type: Int32.Type) throws -> Int32 {
    return try unwrap(as: type)
  }
  
  internal func decode(_ type: Int64.Type) throws -> Int64 {
    return try unwrap(as: type)
  }
  
  internal func decode(_ type: UInt.Type) throws -> UInt {
    return try unwrap(as: type)
  }
  
  internal func decode(_ type: UInt8.Type) throws -> UInt8 {
    return try unwrap(as: type)
  }
  
  internal func decode(_ type: UInt16.Type) throws -> UInt16 {
    return try unwrap(as: type)
  }
  
  internal func decode(_ type: UInt32.Type) throws -> UInt32 {
    return try unwrap(as: type)
  }
  
  internal func decode(_ type: UInt64.Type) throws -> UInt64 {
    return try unwrap(as: type)
  }
  
  internal func decode(_ type: Float.Type) throws -> Float {
    return try unwrap(as: type)
  }
  
  internal func decode(_ type: Double.Type) throws -> Double {
    return try unwrap(as: type)
  }
  
  internal func decode(_ type: String.Type) throws -> String {
    return try unwrap(as: type)
  }
  
  internal func decode<T : Decodable>(_ type: T.Type) throws -> T {
    let unwrapped = storage.lastUnwrapped
    guard let _ = unwrapped else {
      throw CommanderDecoder.Error.decodingError(
        .valueNotFound(
          type, .init(codingPath: codingPath, debugDescription: _valueNotFoundDesc(type, reality: unwrapped))
        )
      )
    }
    return try T.init(from: self)
  }
  
  private func _valueNotFoundDesc<T>(_ type: T, reality: Any?) -> String {
    return "Expected \(type) value but found \(DecodingError.__typeDescription(of: reality)) instead"
  }
}

private protocol _StringInitable {
  init?(_ string: String)
}

private protocol _StringStorable {
  var _stored: String { get }
}

extension _StringStorable {
  fileprivate var _stored: String {
    return "\(self)"
  }
}

extension Bool  : _StringInitable { }
extension Int   : _StringInitable, _StringStorable { }
extension Int8  : _StringInitable, _StringStorable { }
extension Int16 : _StringInitable, _StringStorable { }
extension Int32 : _StringInitable, _StringStorable { }
extension Int64 : _StringInitable, _StringStorable { }
extension UInt  : _StringInitable, _StringStorable { }
extension UInt8 : _StringInitable, _StringStorable { }
extension UInt16: _StringInitable, _StringStorable { }
extension UInt32: _StringInitable, _StringStorable { }
extension UInt64: _StringInitable, _StringStorable { }
extension Float : _StringInitable, _StringStorable { }
extension Double: _StringInitable, _StringStorable { }
extension String: _StringInitable, _StringStorable { }
extension NSNumber: _StringStorable { }

extension Optional: _StringStorable where Wrapped: _StringInitable & _StringStorable {
  fileprivate var _stored: String {
    switch self {
    case .none:
      return ""
    case .some(let val):
      return val._stored
    }
  }
}
