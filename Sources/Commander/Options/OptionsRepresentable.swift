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
  /// The type of the arguments resolver to resolve with.
  associatedtype Argument: Decodable
}

// MARK: AnyArgumentsResolver.

/// A generic concrete type of `ArgumentsResolvable` represents a resolver can resolve any type
/// of arguments conforming `Decodable`.
public struct AnyArgumentsResolver<T: Decodable>: ArgumentsResolvable {
  /// The type of the arguments resolver to resolve with.
  public typealias Argument = T
}
/// A concrete argument type represents the arguments is not resolvable. This is a default type
/// for `OptionsRepresentable`.
public struct Nothing: Decodable {
  /// Creates a new instance by decoding from the given decoder.
  ///
  /// This initializer throws an error if reading from the decoder fails, or
  /// if the data read is corrupted or otherwise invalid.
  ///
  /// - Parameter decoder: The decoder to read data from.
  public init(from decoder: Decoder) throws {
    throw OptionsDecoder.Error.unresolvableArguments
  }
}

// MARK: - OptionsDescribable.

/// A protocol represents the conforming types can describe the options of commands by getting
/// the `keys`, `descriptions` and `argumentType` of that options.
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
    return !(argumentType.self == Nothing.self)
  }
}

// MARK: - CodingKeysRepresentable.

/// A protocol represents the conforming types can be the coding key type for `Decoder` types.
public protocol CodingKeysRepresentable: CodingKey, StringRawRepresentable, Hashable { }

extension CodingKeysRepresentable {
  /// A textual representation of this instance.
  ///
  /// Calling this property directly is discouraged. Instead, convert an
  /// instance of any type to a string by using the `String(describing:)`
  /// initializer. This initializer works with any type, and uses the custom
  /// `description` property for types that conform to `CustomStringConvertible`.
  public var description: String {
    return stringValue + (intValue.map { " Index - \($0)" } ?? "")
  }
}

// MARK: - OptionsRepresentable.

/// A protocol represents the conforming types can be the options of a command of `CommandRepresentable`.
/// The conforming types must be decodable.
public protocol OptionsRepresentable: OptionsDescribable, Hashable {
  /// The coding key type of `CodingKey & StringRawRepresentable` for decoding.
  associatedtype CodingKeys: CodingKeysRepresentable
  /// The arguments resolver of the options.
  associatedtype ArgumentsResolver: ArgumentsResolvable = AnyArgumentsResolver<Nothing>
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

// MARK: - AnyOptions.

/// A generic type wrapping any instances of `OptionsRepresentable` to gain the scale of `Hashable` as
/// a key of `[AnyHashable: Any]`.
internal struct AnyOptions<T: OptionsRepresentable>: Hashable {
  /// The boxed underlying options of `OptionsRepresentable`.
  internal private(set) var options: T
}
/// The global storage of decoded arguments of any `OptionsRepresentable`. Key type is `AnyOptions<T>`.
internal var _ArgumentsStorage: [AnyHashable: Any] = [:]

// MARK: - Defaults.

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
    return try OptionsDecoder().decode(Self.self, from: commandLineArgs)
  }
  /// The arguments of the options if arguments can be resolved.
  public var arguments: [ArgumentsResolver.Argument] {
    get { return _ArgumentsStorage[AnyOptions(options: self)] as? [ArgumentsResolver.Argument] ?? [] }
    set { _ArgumentsStorage[AnyOptions(options: self)] = newValue }
  }
}

extension OptionsRepresentable where ArgumentsResolver == AnyArgumentsResolver<Nothing> {
  /// The arguments of the options if arguments can be resolved.
  public var arguments: [ArgumentsResolver.Argument] {
    get { return [] }
    set { }
  }
}