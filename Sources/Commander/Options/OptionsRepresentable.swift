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

// MARK: - Nothingness.

/// The protocol represents the conforming type means nothing and cannot be decoded.
public protocol Nothingness: OptionsRepresentable { }

/// The concrete type conforms `Nothingness` represents the options and arguments is
/// not resolvable. Used by the `OptionsRepresentable` as default argument type and
/// by the `CommanderRepresentable` as default options type.
public struct Nothing: Nothingness {
  /// The coding key type of `CodingKey & StringRawRepresentable` for decoding.
  public enum CodingKeys: String, CodingKeysRepresentable {
    case nothing
  }
  /// The short keys of the options' coding keys.
  public static let keys: [CodingKeys : Character] = [:]
  /// The extends option keys for the `Options`.
  public static let descriptions: [CodingKeys : OptionDescription] = [:]
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
public protocol OptionsDescribable: Decodable, ShellCompletable {
  /// The short keys of the options' coding keys.
  static var keys: [String: Character] { get }
  /// Returns the options description list.
  static var descriptions: [String: OptionDescription] { get }
  /// Returns the type of the argument.
  static var argumentType: Decodable.Type { get }
  /// Returns all the coding keys of the options.
  static var allCodingKeys: [String] { get }
}

extension OptionsDescribable {
  /// Returns a bool value indicates if the arguments can be resolved.
  static var isArgumentsResolvable: Bool {
    return !(argumentType.self == Nothing.self)
  }
  /// Returns if the given options is valid options for the options describer.
  public static func validate(_ options: String) -> Bool {
    let optionsFormat = OptionsDecoder.optionsFormat
    
    if options.endsIndex(matchs: optionsFormat.symbol) != nil {
      return allCodingKeys.contains(optionsFormat.valueWithoutSymbol(for: options)!)
    } else if options.endsIndex(matchs: optionsFormat.shortSymbol) != nil {
      return keys.map { String($0.value) }.contains(optionsFormat.valueWithoutSymbol(for: options)!)
    }
    
    return (allCodingKeys + keys.map { String($0.value) }).contains(options)
  }
}

// MARK: - CodingKeysRepresentable.

/// A protocol represents the conforming types can be the coding key type for `Decoder` types.
public protocol CodingKeysRepresentable: CodingKey, StringRawRepresentable, Hashable, CaseIterable { }

extension CodingKeysRepresentable {
  /// A textual representation of this instance.
  ///
  /// Calling this property directly is discouraged. Instead, convert an
  /// instance of any type to a string by using the `String(describing:)`
  /// initializer. This initializer works with any type, and uses the custom
  /// `description` property for types that conform to `CustomStringConvertible`.
  public var description: String {
    return stringValue // + (intValue.map { " Index - \($0)" } ?? "")
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
  /// The global options of the commander.
  associatedtype GlobalOptions: OptionsRepresentable = Nothing
  /// The short keys of the options' coding keys.
  static var keys: [CodingKeys: Character] { get }
  /// The extends option keys for the `Options`.
  static var descriptions: [CodingKeys: OptionDescription] { get }
  /// Returns the global options of the running commander if any.
  var globalOptions: GlobalOptions? { get }
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
  /// Returns the global options of commander.
  public var globalOptions: GlobalOptions? {
    return CommandPath.runningGlobalOptions as? GlobalOptions
  }
  /// The short keys of the options' coding keys.
  public static var keys: [String: Character] {
    let skeys = keys.reduce(into: [:]) { $0[$1.key.stringValue] = $1.value } as [String: Character]
    let gkeys = GlobalOptions.keys.reduce(into: [:]) { $0[$1.key.stringValue] = $1.value } as [String: Character]
    let hkeys = Help.Options.keys.reduce(into: [:]) { $0[$1.key.stringValue] = $1.value } as [String: Character]
    
    return gkeys.merging(skeys) {
      current, _ in current
    }.merging(hkeys) {
      current, _ in current
    }
  }
  /// Returns the options description list.
  public static var descriptions: [String: OptionDescription] {
    let sdescs = self.descriptions.reduce(into: [:]) { $0[$1.key.stringValue] = $1.value }
    let gdescs = GlobalOptions.descriptions.reduce(into: [:]) { $0[$1.key.stringValue] = $1.value }
    let hdescs = Help.Options.descriptions.reduce(into: [:]) { $0[$1.key.stringValue] = $1.value }
    
    return gdescs.merging(sdescs) {
      current, _ in current
    }.merging(hdescs) {
      current, _ in current
    }
  }
  /// Returns the type of the argument.
  public static var argumentType: Decodable.Type {
    return ArgumentsResolver.Argument.self
  }
  /// Returns all the coding keys of the options.
  public static var allCodingKeys: [String] {
    return CodingKeys.allCases.map { $0.description }
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
