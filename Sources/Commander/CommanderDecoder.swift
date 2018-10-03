//
//  CommanderDecoder.swift
//  Commander
//
//  Created by devedbox on 2018/10/2.
//

import Foundation

extension String {
  fileprivate func prefixMatchs(_ pattern: String) -> Index? {
    var index = pattern.startIndex
    
    while index < pattern.endIndex, index < endIndex {
      if pattern[index] != self[index] {
        return nil
      }
      
      pattern.formIndex(after: &index)
    }
    
    return index
  }
}

// MARK: - OptionsFormat.

extension CommanderDecoder {
  public enum OptionsFormat {
    case format(String, short: String)
  }
}

// MARK: - ObjectFormat.

extension CommanderDecoder {
  internal enum ObjectFormat {
    
    internal struct Value {
      internal enum Error: String, Swift.Error {
        case jsonObjectFormatIsNotSupported = "Object format error: The JSON object format is not supported"
      }
      
      internal let dictionaryValue: [String: Value]?
      internal let arrayValue: [Value]?
      internal let stringValue: String?
      internal let boolValue: Bool?
      
      internal var value: Any? {
        return dictionaryValue ?? arrayValue ?? stringValue ?? boolValue
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
    }
    
    @available(*, unavailable)
    case json
    case flatContainer(splitter: Character, keyValuePairsSplitter: Character)
    
    internal func container(for string: String) throws -> Value {
      var arrayContainer: [Value]? = nil
      var dictContainer: [String: Value]? = nil
      
      switch self {
      case .flatContainer(splitter: let splitter, keyValuePairsSplitter: let keyValuePairsSplitter):
        if string.contains(splitter) {
          let elements = string.split(separator: splitter)
          if string.contains(keyValuePairsSplitter) {
            dictContainer = try? elements.reduce([:], { result, next -> [String: Value] in
              let keyValuePairs = next.split(separator: keyValuePairsSplitter)
              guard keyValuePairs.count == 2 else {
                throw Error.invalidKeyValuePairs
              }
              let value = Value(stringValue: String(keyValuePairs[1]))
              return result.merging([String(keyValuePairs[0]): value]) { _ , new in new }
            })
          } else {
            arrayContainer = elements.map { Value(stringValue: String($0)) }
          }
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
  public enum Error: Swift.Error {
    case emptyOptionsSymbolIsInvalid
    case invalidKeyValuePairs
  }
  
  internal static var optionsSymbol: String = "--"
  internal static var shortOptionsSymbol: String = "-"
  internal static var optionsFormat = OptionsFormat.format("--", short: "-")
  internal static var objectFormat = ObjectFormat.flatContainer(splitter: ",", keyValuePairsSplitter: "=")
  
  internal var optionsDescriptions: [(CodingKey, OptionKeyDescription)]!
  
  public init() { }
  
  internal func container(from commandLineArgs: [String]) throws -> [String: ObjectFormat.Value] {
    var container: [String: ObjectFormat.Value] = [:]
    var option: String?
    var iterator = commandLineArgs.makeIterator()
    
    while let item = iterator.next() {
      if
        let symbolIndex = item.prefixMatchs(CommanderDecoder.optionsSymbol),
        let key = Optional.some(String(item[symbolIndex...]))
      {
        if option != nil {
          container[option!] = .init(boolValue: true)
        }
        option = key
      } else if
        let symbolIndex = item.prefixMatchs(CommanderDecoder.shortOptionsSymbol),
        let key = Optional.some(String(item[symbolIndex...]))
      {
        if key.count == 1 {
          if option != nil {
            container[option!] = .init(boolValue: true)
          }
          option = key
        } else {
          for char in key {
            container[String(char)] = .init(boolValue: true)
          }
          option = nil
        }
      } else {
        if option == nil {
          // FIXME: Consider missing '--option' symbol or arguments.
        } else {
          container[option!] = try type(of: self).objectFormat.container(for: item)
          option = nil
        }
      }
    }
    
    if option != nil {
      container[option!] = .init(boolValue: true)
    }
    
    return container
  }
  
  public func decode<T: OptionsRepresentable>(
    _ type: T.Type,
    from commandLineArgs: [String]) throws -> T
  {
    guard
      !CommanderDecoder.optionsSymbol.isEmpty,
      !CommanderDecoder.shortOptionsSymbol.isEmpty
    else {
      throw Error.emptyOptionsSymbolIsInvalid
    }
    
    optionsDescriptions = T.optionKeys
    defer { optionsDescriptions = nil }
    
    let container = try self.container(from: commandLineArgs)
    return try _Decoder(
      referencing: self,
      wrapping: ObjectFormat.Value(
        dictionaryValue: container
      )
    ).decode(as: type)
  }
}

// MARK: - ConcreteDecoder.

extension CommanderDecoder {
  internal class _Decoder: Decoder {
    internal private(set) var codingPath: [CodingKey]
    fileprivate var storage = _Storage()
    fileprivate var container: _KeyedContainer
    internal var userInfo: [CodingUserInfoKey: Any] = [:]
    
    init(
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
        throw DecodingError.typeMismatch([String: ObjectFormat.Value].self, .init(codingPath: codingPath, debugDescription: ""))
      }
      
      return KeyedDecodingContainer<Key>(
        _KeyedDecodingContainer(
          referencing: self,
          wrapping: _Decoder._KeyedContainer(
            .init(dictionaryValue: top),
            referencing: container.decoder
          )
        )
      )
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
      guard let top = storage.top?.arrayValue else {
        throw DecodingError.typeMismatch([ObjectFormat.Value].self, .init(codingPath: codingPath, debugDescription: ""))
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
      let value = storage.dictionaryValue?[key] ?? (decoder.optionsDescriptions?.first {
        $0.0.stringValue == key
      }?.1).flatMap {
        $0.shortSymbol.flatMap {
          storage.dictionaryValue?[$0]
        }
      }
      return value
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
    fileprivate var lastWrapped: Any? {
      return top?.value
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
  fileprivate struct _Key: CodingKey {
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
      return false
    }
    
    internal func decode<T>(
      _ type: T.Type,
      forKey key: Key) throws -> T where T : Decodable
    {
      guard let entry = container[key.stringValue] else {
        throw DecodingError.keyNotFound(
          key,
          .init(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(key).")
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
        throw DecodingError.keyNotFound(
          key,
          .init(
            codingPath: codingPath,
            debugDescription: "Cannot get \(KeyedDecodingContainer<NestedKey>.self) -- no value found for key \(key)"
          )
        )
      }
      
      guard let dictionary = value.dictionaryValue else {
        throw DecodingError.typeMismatch(
          [String: CommanderDecoder.ObjectFormat.Value].self,
          .init(codingPath: codingPath, debugDescription: "")
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
        throw DecodingError.keyNotFound(
          key,
          .init(
            codingPath: codingPath,
            debugDescription: "Cannot get UnkeyedDecodingContainer -- no value found for key \(key)"
          )
        )
      }
      
      guard let array = value.arrayValue else {
        throw DecodingError.typeMismatch(
          [CommanderDecoder.ObjectFormat.Value].self,
          .init(codingPath: codingPath, debugDescription: "")
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
        throw DecodingError.valueNotFound(
          Any?.self,
          .init(
            codingPath: decoder.codingPath + [CommanderDecoder._Decoder._Key(index: currentIndex)],
            debugDescription: "Unkeyed container is at end."
          )
        )
      }
      
      return false
    }
    
    internal mutating func decode<T : Decodable>(_ type: T.Type) throws -> T {
      guard !self.isAtEnd else {
        throw DecodingError.valueNotFound(
          type,
          .init(
            codingPath: decoder.codingPath + [CommanderDecoder._Decoder._Key(index: currentIndex)],
            debugDescription: "Unkeyed container is at end."
          )
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
        throw DecodingError.valueNotFound(
          KeyedDecodingContainer<NestedKey>.self,
          .init(
            codingPath: codingPath,
            debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."
          )
        )
      }
      
      let value = self.container[currentIndex]
      
      guard let dictionary = value.dictionaryValue else {
        throw DecodingError.typeMismatch(
          [String: CommanderDecoder.ObjectFormat.Value].self,
          .init(codingPath: codingPath, debugDescription: "")
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
        throw DecodingError.valueNotFound(
          UnkeyedDecodingContainer.self,
          DecodingError.Context(
            codingPath: codingPath,
            debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."
          )
        )
      }
      
      let value = self.container[currentIndex]
      
      guard let array = value.arrayValue else {
        throw DecodingError.typeMismatch(
          [CommanderDecoder.ObjectFormat.Value].self,
          .init(codingPath: codingPath, debugDescription: "")
        )
      }
      
      currentIndex += 1
      return _UnkeyedDecodingContainer(referencing: decoder, wrapping: array)
    }
    
    internal mutating func superDecoder() throws -> Decoder {
      decoder.codingPath.append(CommanderDecoder._Decoder._Key(index: currentIndex))
      defer { decoder.codingPath.removeLast() }
      
      guard !self.isAtEnd else {
        throw DecodingError.valueNotFound(
          Decoder.self,
          DecodingError.Context(
            codingPath: codingPath,
            debugDescription: "Cannot get superDecoder() -- unkeyed container is at end."
          )
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
  // MARK: SingleValueDecodingContainer Methods
  
  internal func decodeNil() -> Bool {
    return false
  }
  
  internal func decode(_ type: Bool.Type) throws -> Bool {
    guard let value = storage.lastWrapped as? Bool else {
      throw DecodingError.valueNotFound(
        type,
        .init(
          codingPath: codingPath,
          debugDescription: "Expected \(type) value but found null instead."
        )
      )
    }
    return value
  }
  
  internal func decode(_ type: Int.Type) throws -> Int {
    guard let value = (storage.lastWrapped as? String).flatMap({ Int($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(
          codingPath: codingPath,
          debugDescription: "Expected \(type) value but found null instead."
        )
      )
    }
    return value
  }
  
  internal func decode(_ type: Int8.Type) throws -> Int8 {
    guard let value = (storage.lastWrapped as? String).flatMap({ Int8($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(
          codingPath: codingPath,
          debugDescription: "Expected \(type) value but found null instead."
        )
      )
    }
    return value
  }
  
  internal func decode(_ type: Int16.Type) throws -> Int16 {
    guard let value = (storage.lastWrapped as? String).flatMap({ Int16($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(
          codingPath: codingPath,
          debugDescription: "Expected \(type) value but found null instead."
        )
      )
    }
    return value
  }
  
  internal func decode(_ type: Int32.Type) throws -> Int32 {
    guard let value = (storage.lastWrapped as? String).flatMap({ Int32($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(
          codingPath: codingPath,
          debugDescription: "Expected \(type) value but found null instead."
        )
      )
    }
    return value
  }
  
  internal func decode(_ type: Int64.Type) throws -> Int64 {
    guard let value = (storage.lastWrapped as? String).flatMap({ Int64($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(
          codingPath: codingPath,
          debugDescription: "Expected \(type) value but found null instead."
        )
      )
    }
    return value
  }
  
  internal func decode(_ type: UInt.Type) throws -> UInt {
    guard let value = (storage.lastWrapped as? String).flatMap({ UInt($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(
          codingPath: codingPath,
          debugDescription: "Expected \(type) value but found null instead."
        )
      )
    }
    return value
  }
  
  internal func decode(_ type: UInt8.Type) throws -> UInt8 {
    guard let value = (storage.lastWrapped as? String).flatMap({ UInt8($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(
          codingPath: codingPath,
          debugDescription: "Expected \(type) value but found null instead."
        )
      )
    }
    return value
  }
  
  internal func decode(_ type: UInt16.Type) throws -> UInt16 {
    guard let value = (storage.lastWrapped as? String).flatMap({ UInt16($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(
          codingPath: codingPath,
          debugDescription: "Expected \(type) value but found null instead."
        )
      )
    }
    return value
  }
  
  internal func decode(_ type: UInt32.Type) throws -> UInt32 {
    guard let value = (storage.lastWrapped as? String).flatMap({ UInt32($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(
          codingPath: codingPath,
          debugDescription: "Expected \(type) value but found null instead."
        )
      )
    }
    return value
  }
  
  internal func decode(_ type: UInt64.Type) throws -> UInt64 {
    guard let value = (storage.lastWrapped as? String).flatMap({ UInt64($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(
          codingPath: codingPath,
          debugDescription: "Expected \(type) value but found null instead."
        )
      )
    }
    return value
  }
  
  internal func decode(_ type: Float.Type) throws -> Float {
    guard let value = (storage.lastWrapped as? String).flatMap({ Float($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(
          codingPath: codingPath,
          debugDescription: "Expected \(type) value but found null instead."
        )
      )
    }
    return value
  }
  
  internal func decode(_ type: Double.Type) throws -> Double {
    guard let value = (storage.lastWrapped as? String).flatMap({ Double($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(
          codingPath: codingPath,
          debugDescription: "Expected \(type) value but found null instead."
        )
      )
    }
    return value
  }
  
  internal func decode(_ type: String.Type) throws -> String {
    guard let value = storage.lastWrapped as? String else {
      throw DecodingError.valueNotFound(
        type,
        .init(
          codingPath: codingPath,
          debugDescription: "Expected \(type) value but found null instead."
        )
      )
    }
    return value
  }
  
  internal func decode<T : Decodable>(_ type: T.Type) throws -> T {
    guard let _ = storage.lastWrapped else {
      throw DecodingError.valueNotFound(
        type,
        .init(
          codingPath: codingPath,
          debugDescription: "Expected \(type) value but found null instead."
        )
      )
    }
    return try T.init(from: self)
  }
}
