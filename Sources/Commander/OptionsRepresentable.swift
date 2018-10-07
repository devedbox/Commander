//
//  OptionRepresentable.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
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

// MARK: - StringRawRepresentable.

/// A type represents the conforming types can be represents by string values.
public protocol StringRawRepresentable {
  /// Creates the instance with string value.
  init?(rawValue: String)
}

// MARK: - ArgumentsResolvable.

/// A protocol represents the conforming types can accecpt and resolve a sequence of arguments.
public protocol ArgumentsResolvable {
  associatedtype Argument: Decodable
}

public struct AnyArgumentsResolver<T: Decodable>: ArgumentsResolvable {
  public typealias Argument = T
}

public struct Void: Decodable {
  public init(from decoder: Decoder) throws {
    throw CommanderDecoder.Error.unresolvableArguments
  }
}

// MARK: - OptionsDescribable.

public protocol OptionsDescribable: Decodable {
  /// The short keys of the options' coding keys.
  static var keys: [AnyHashable: Character] { get }
  /// Returns the options description list.
  static var descriptions: [AnyHashable: OptionDescription] { get }
  /// Returns the type of the argument.
  static var argumentType: Decodable.Type { get }
}

extension OptionsDescribable {
  /// Returns a bool value indicates if the arguments can be resolved.
  static var isArgumentsResolvable: Bool {
    return !(argumentType.self == Void.self)
  }
}

// MARK: - CodingKeysRepresentable.

public protocol CodingKeysRepresentable: CodingKey, StringRawRepresentable, Hashable { }

// MARK: - OptionsRepresentable.

/// A protocol represents the conforming types can be the options of a command of `CommandRepresentable`.
/// The conforming types must be decodable.
public protocol OptionsRepresentable: OptionsDescribable, Hashable {
  /// The coding key type of `CodingKey & StringRawRepresentable` for decoding.
  associatedtype CodingKeys: CodingKeysRepresentable
  /// The arguments resolver of the options.
  associatedtype ArgumentsResolver: ArgumentsResolvable = AnyArgumentsResolver<Void>
  /// The short keys of the options' coding keys.
  static var keys: [CodingKeys: Character] { get }
  /// The extends option keys for the `Options`.
  static var descriptions: [CodingKeys: OptionDescription] { get }
  /// The arguments of the options if arguments can be resolved.
  var arguments: [ArgumentsResolver.Argument] { get set }
  /// Decode the options from the given command line arguments.
  ///
  /// - Parameter commandLineArgs: The command line arguments without command symbol.
  /// - Returns: The decoded options of `Self`.
  static func decoded(from commandLineArgs: [String]) throws -> Self
}

internal struct AnyOptions<T: OptionsRepresentable>: Hashable {
  internal private(set) var options: T
}

internal var _ArgumentsStorage: [AnyHashable: Any] = [:]

// MARK: -

extension OptionsRepresentable {
  /// The short keys of the options' coding keys.
  public static var keys: [AnyHashable: Character] {
    return keys.reduce(into: [:]) { $0[$1.key.stringValue] = $1.value }
  }
  /// Returns the options description list.
  public static var descriptions: [AnyHashable: OptionDescription] {
    return descriptions.reduce(into: [:]) { $0[$1.key.stringValue] = $1.value }
  }
  /// Returns the type of the argument.
  public static var argumentType: Decodable.Type {
    return ArgumentsResolver.Argument.self
  }
  /// Decode the options from the given command line arguments.
  ///
  /// - Parameter commandLineArgs: The command line arguments without command symbol.
  /// - Returns: The decoded options of `Self`.
  public static func decoded(from commandLineArgs: [String]) throws -> Self {
    return try CommanderDecoder().decode(Self.self, from: commandLineArgs)
  }
  
  public var arguments: [ArgumentsResolver.Argument] {
    get {
      return _ArgumentsStorage[AnyOptions(options: self)] as? [ArgumentsResolver.Argument] ?? []
    }
    set {
      _ArgumentsStorage[AnyOptions(options: self)] = newValue
    }
  }
}

extension OptionsRepresentable where ArgumentsResolver == AnyArgumentsResolver<Void> {
  public var arguments: [ArgumentsResolver.Argument] {
    get { return [] }
    set { }
  }
}
