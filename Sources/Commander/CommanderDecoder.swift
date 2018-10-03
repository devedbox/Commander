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
      let pa = pattern[index]
      let sl = self[index]
      
      if pa != sl {
        return nil
      }
      
      pattern.formIndex(after: &index)
    }
    
    return index
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
  internal static var containerSymbol: Character = ","
  internal static var keyValuePairsSymbol: Character = "="
  
  private var optionsDescriptions: [(CodingKey, OptionKeyDescription)]!
  
  public init() { }
  
  internal func container(from commandLineArgs: [String]) throws -> [String: Any] {
    var container: [String: Any] = [:]
    var option: String?
    var iterator = commandLineArgs.makeIterator()
    
    while let item = iterator.next() {
      if
        let symbolIndex = item.prefixMatchs(CommanderDecoder.optionsSymbol),
        let key = Optional.some(String(item[symbolIndex...]))
      {
        if option != nil {
          container[option!] = true
        }
        option = key
      } else if
        let symbolIndex = item.prefixMatchs(CommanderDecoder.shortOptionsSymbol),
        let key = Optional.some(String(item[symbolIndex...]))
      {
        if key.count == 1 {
          if option != nil {
            container[option!] = true
          }
          option = key
        } else {
          for char in key {
            container[String(char)] = true
          }
          option = nil
        }
      } else {
        if option == nil {
          // FIXME: Consider missing '--option' symbol or arguments.
        } else {
          if item.contains(CommanderDecoder.containerSymbol) {
            let elements = item.split(separator: CommanderDecoder.containerSymbol)
            if item.contains(CommanderDecoder.keyValuePairsSymbol) {
              container[option!] = try elements.reduce([:], { result, next -> [String: Any] in
                let keyValuePairs = next.split(separator: CommanderDecoder.keyValuePairsSymbol)
                guard keyValuePairs.count == 2 else {
                  throw Error.invalidKeyValuePairs
                }
                return result.merging([String(keyValuePairs[0]): String(keyValuePairs[1])]) { _ , new in new }
              })
            } else {
              container[option!] = elements.map { String($0) }
            }
          } else {
            container[option!] = item
          }
          option = nil
        }
      }
    }
    
    if option != nil {
      container[option!] = true
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
    return try _Decoder(referencing: self, wrapping: container).decode(as: type)
  }
}

// MARK: -

extension CommanderDecoder {
  
  // MARK: _Decoder.
  
  internal class _Decoder: Decoder {
    
    fileprivate struct _KeyedContainer {
      fileprivate let storage: [String: Any]
      fileprivate let decoder: CommanderDecoder
      
      fileprivate init(
        _ keyValuePairs: [String: Any],
        referencing decoder: CommanderDecoder)
      {
        self.storage = keyValuePairs
        self.decoder = decoder
      }
      
      fileprivate subscript(key: String) -> Any? {
        let value = storage[key] ?? (decoder.optionsDescriptions?.first {
          $0.0.stringValue == key
        }?.1).flatMap {
          $0.shortSymbol.flatMap {
            storage[$0]
          }
        }
        return value
      }
    }
    
    internal var codingPath: [CodingKey]
    internal var storage: [Any] = []
    fileprivate var container: _KeyedContainer
    internal var userInfo: [CodingUserInfoKey: Any] = [:]
    
    init(
      referencing commanderDecoder: CommanderDecoder,
      wrapping container: [String: Any],
      at codingPath: [CodingKey] = [])
    {
      self.container = _KeyedContainer(container, referencing: commanderDecoder)
      self.codingPath = codingPath
      self.storage.append(container)
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
      guard let top = self.storage.last as? [String: Any] else {
        throw DecodingError.typeMismatch([String: Any].self, .init(codingPath: codingPath, debugDescription: ""))
      }
      
      return KeyedDecodingContainer<Key>(
        _KeyedDecodingContainer(referencing: self, wrapping: _Decoder._KeyedContainer(top, referencing: container.decoder))
      )
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
      guard let top = self.storage.last as? [Any] else {
        throw DecodingError.typeMismatch([Any].self, .init(codingPath: codingPath, debugDescription: ""))
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
  
  // MARK: _Key.
  
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
  
  // MARK: _KeyedDecodingContainer.
  
  internal struct _KeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    internal var decoder: _Decoder
    private(set) var codingPath: [CodingKey]
    fileprivate var container: _Decoder._KeyedContainer
    
    var allKeys: [Key] {
      return container.storage.keys.compactMap { Key(stringValue: $0) }
    }
    
    fileprivate init(referencing decoder: _Decoder, wrapping container: _Decoder._KeyedContainer) {
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
      guard let entry = self.container[key.stringValue] else {
        throw DecodingError.keyNotFound(
          key,
          .init(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(key).")
        )
      }
      
      
      decoder.codingPath.append(key)
      defer { decoder.codingPath.removeLast() }
      
      decoder.storage.append(entry)
      defer { decoder.storage.removeLast() }
      
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
          .init(codingPath: self.codingPath, debugDescription: "Cannot get \(KeyedDecodingContainer<NestedKey>.self) -- no value found for key \(key)")
        )
      }
      
      guard let dictionary = value as? [String : Any] else {
        throw DecodingError.typeMismatch([String: Any].self, .init(codingPath: codingPath, debugDescription: ""))
      }
      
      let container = _KeyedDecodingContainer<NestedKey>(
        referencing: decoder,
        wrapping: _Decoder._KeyedContainer(dictionary, referencing: decoder.container.decoder)
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
      
      guard let array = value as? [Any] else {
        throw DecodingError.typeMismatch([Any].self, .init(codingPath: codingPath, debugDescription: ""))
      }
      
      return _UnkeyedDecodingContainer(referencing: decoder, wrapping: array)
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
      
      let value: [String: Any] = container[key.stringValue] as? [String: Any] ?? [:]
      return _Decoder(referencing: decoder.container.decoder, wrapping: value)
    }
  }
  
  internal struct _UnkeyedDecodingContainer: UnkeyedDecodingContainer {
    internal var decoder: _Decoder
    internal var container: [Any]
    
    internal var codingPath: [CodingKey] = []
    internal var count: Int? { return container.count }
    internal var isAtEnd: Bool {
      return currentIndex >= count!
    }
    internal var currentIndex: Int = 0
    
    internal init(
      referencing decoder: _Decoder,
      wrapping container: [Any])
    {
      self.decoder = decoder
      self.container = container
    }
    
    internal mutating func decodeNil() throws -> Bool {
      guard !self.isAtEnd else {
        throw DecodingError.valueNotFound(
          Any?.self,
          .init(codingPath: decoder.codingPath + [_Key(index: currentIndex)], debugDescription: "Unkeyed container is at end.")
        )
      }
      
      return false
    }
    
    internal mutating func decode<T : Decodable>(_ type: T.Type) throws -> T {
      guard !self.isAtEnd else {
        throw DecodingError.valueNotFound(type, .init(codingPath: decoder.codingPath + [_Key(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
      }
      
      decoder.codingPath.append(_Key(index: currentIndex))
      defer { decoder.codingPath.removeLast() }
      
      decoder.storage.append(container[currentIndex])
      defer { decoder.storage.removeLast() }
      
      currentIndex += 1
      return try T.init(from: decoder)
    }
    
    internal mutating func nestedContainer<NestedKey>(
      keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey
    {
      decoder.codingPath.append(_Key(index: currentIndex))
      defer { decoder.codingPath.removeLast() }
      
      guard !self.isAtEnd else {
        throw DecodingError.valueNotFound(
          KeyedDecodingContainer<NestedKey>.self,
          DecodingError.Context(
            codingPath: self.codingPath,
            debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."
          )
        )
      }
      
      let value = self.container[self.currentIndex]
      
      guard let dictionary = value as? [String : Any] else {
        throw DecodingError.typeMismatch([String: Any].self, .init(codingPath: codingPath, debugDescription: ""))
      }
      
      self.currentIndex += 1
      let container = _KeyedDecodingContainer<NestedKey>(
        referencing: decoder,
        wrapping: _Decoder._KeyedContainer(dictionary, referencing: decoder.container.decoder)
      )
      return KeyedDecodingContainer(container)
    }
    
    internal mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
      decoder.codingPath.append(_Key(index: currentIndex))
      defer { decoder.codingPath.removeLast() }
      
      guard !self.isAtEnd else {
        throw DecodingError.valueNotFound(
          UnkeyedDecodingContainer.self,
          DecodingError.Context(
            codingPath: self.codingPath,
            debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."
          )
        )
      }
      
      let value = self.container[self.currentIndex]
      
      guard let array = value as? [Any] else {
        throw DecodingError.typeMismatch([Any].self, .init(codingPath: codingPath, debugDescription: ""))
      }
      
      self.currentIndex += 1
      return _UnkeyedDecodingContainer(referencing: self.decoder, wrapping: array)
    }
    
    internal mutating func superDecoder() throws -> Decoder {
      decoder.codingPath.append(_Key(index: currentIndex))
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
      
      let value = container[currentIndex] as? [String: Any] ?? [:]
      self.currentIndex += 1
      return _Decoder(referencing: decoder.container.decoder, wrapping: value, at: decoder.codingPath)
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
    guard let value = storage.last as? Bool else {
      throw DecodingError.valueNotFound(
        type,
        .init(codingPath: codingPath, debugDescription: "Expected \(type) value but found null instead.")
      )
    }
    return value
  }
  
  internal func decode(_ type: Int.Type) throws -> Int {
    guard let value = (storage.last as? String).flatMap({ Int($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(codingPath: codingPath, debugDescription: "Expected \(type) value but found null instead.")
      )
    }
    return value
  }
  
  internal func decode(_ type: Int8.Type) throws -> Int8 {
    guard let value = (storage.last as? String).flatMap({ Int8($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(codingPath: codingPath, debugDescription: "Expected \(type) value but found null instead.")
      )
    }
    return value
  }
  
  internal func decode(_ type: Int16.Type) throws -> Int16 {
    guard let value = (storage.last as? String).flatMap({ Int16($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(codingPath: codingPath, debugDescription: "Expected \(type) value but found null instead.")
      )
    }
    return value
  }
  
  internal func decode(_ type: Int32.Type) throws -> Int32 {
    guard let value = (storage.last as? String).flatMap({ Int32($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(codingPath: codingPath, debugDescription: "Expected \(type) value but found null instead.")
      )
    }
    return value
  }
  
  internal func decode(_ type: Int64.Type) throws -> Int64 {
    guard let value = (storage.last as? String).flatMap({ Int64($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(codingPath: codingPath, debugDescription: "Expected \(type) value but found null instead.")
      )
    }
    return value
  }
  
  internal func decode(_ type: UInt.Type) throws -> UInt {
    guard let value = (storage.last as? String).flatMap({ UInt($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(codingPath: codingPath, debugDescription: "Expected \(type) value but found null instead.")
      )
    }
    return value
  }
  
  internal func decode(_ type: UInt8.Type) throws -> UInt8 {
    guard let value = (storage.last as? String).flatMap({ UInt8($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(codingPath: codingPath, debugDescription: "Expected \(type) value but found null instead.")
      )
    }
    return value
  }
  
  internal func decode(_ type: UInt16.Type) throws -> UInt16 {
    guard let value = (storage.last as? String).flatMap({ UInt16($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(codingPath: codingPath, debugDescription: "Expected \(type) value but found null instead.")
      )
    }
    return value
  }
  
  internal func decode(_ type: UInt32.Type) throws -> UInt32 {
    guard let value = (storage.last as? String).flatMap({ UInt32($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(codingPath: codingPath, debugDescription: "Expected \(type) value but found null instead.")
      )
    }
    return value
  }
  
  internal func decode(_ type: UInt64.Type) throws -> UInt64 {
    guard let value = (storage.last as? String).flatMap({ UInt64($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(codingPath: codingPath, debugDescription: "Expected \(type) value but found null instead.")
      )
    }
    return value
  }
  
  internal func decode(_ type: Float.Type) throws -> Float {
    guard let value = (storage.last as? String).flatMap({ Float($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(codingPath: codingPath, debugDescription: "Expected \(type) value but found null instead.")
      )
    }
    return value
  }
  
  internal func decode(_ type: Double.Type) throws -> Double {
    guard let value = (storage.last as? String).flatMap({ Double($0) }) else {
      throw DecodingError.valueNotFound(
        type,
        .init(codingPath: codingPath, debugDescription: "Expected \(type) value but found null instead.")
      )
    }
    return value
  }
  
  internal func decode(_ type: String.Type) throws -> String {
    guard let value = storage.last as? String else {
      throw DecodingError.valueNotFound(
        type,
        .init(codingPath: codingPath, debugDescription: "Expected \(type) value but found null instead.")
      )
    }
    return value
  }
  
  internal func decode<T : Decodable>(_ type: T.Type) throws -> T {
    guard let _ = storage.last else {
      throw DecodingError.valueNotFound(
        type,
        .init(codingPath: codingPath, debugDescription: "Expected \(type) value but found null instead.")
      )
    }
    return try T.init(from: self)
  }
}
