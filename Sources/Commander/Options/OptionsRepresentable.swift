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

// MARK: ArgumentsResolver.

/// A generic concrete type of `ArgumentsResolvable` represents a resolver can resolve any type
/// of arguments conforming `Decodable`.
public struct ArgumentsResolver<T: Decodable>: ArgumentsResolvable {
  /// The type of the arguments resolver to resolve with.
  public typealias Argument = T
}

// MARK: - OptionsDescribable.

/// A protocol represents the conforming types can describe the options of commands by getting
/// the `keys`, `descriptions` and `argumentType` of that options.
public protocol OptionsDescribable: Decodable, ShellCompletable {
  /// The short keys of the options' coding keys.
  static var stringKeys: [String: Character] { get }
  /// Returns the options description list.
  static var stringDescriptions: [String: OptionDescription] { get }
  /// Returns the type of the argument.
  static var argumentType: Decodable.Type { get }
  /// Returns all the coding keys of the options.
  static var codingKeys: [String] { get }
}

extension OptionsDescribable {
  /// Returns a bool value indicates if the arguments can be resolved.
  static var isArgumentsResolvable: Bool {
    return !(argumentType.self == DefaultOptions.None.self || argumentType.self == DefaultOptions.Empty.self)
  }
  
  /// Returns if the given options is valid options for the options describer.
  public static func validate(_ options: String) -> Bool {
    let optionsFormat = OptionsDecoder.optionsFormat
    
    if options.endsIndex(matchs: optionsFormat.symbol) != nil {
      return codingKeys
        .contains(optionsFormat.valueWithoutSymbol(for: options)!)
    } else if options.endsIndex(matchs: optionsFormat.shortSymbol) != nil {
      return stringKeys
        .map { String($0.value) }
        .contains(optionsFormat.valueWithoutSymbol(for: options)!)
    }
    
    return (codingKeys + stringKeys.map { String($0.value) })
      .contains(options)
  }
}

// MARK: - OptionKeysRepresentable.

/// A protocol represents the conforming types can be the coding key type for `Decoder` types.
public protocol OptionKeysRepresentable: StringRawRepresentable, Hashable, CaseIterable {
  /// The string to use in a named collection (e.g. a string-keyed dictionary).
  var stringValue: String { get }
}

extension OptionKeysRepresentable {
  /// Returns the reflected meta info for the given subject, with the given transform closure to map element of the infos
  /// to the given new type.
  ///
  /// - Parameter subject: The subject to be reflected.
  /// - Parameter transform: The closure used to perform the transforming.
  /// - Returns: The transformed new meta infos.
  internal static func transform<S, T>(reflecting subject: S, _ transform: (Mirror.Child) throws -> T?) rethrows -> [T] {
    return try Mirror(reflecting: subject).children.compactMap(transform)
  }
  
  /// Returns all cases for the `CaseIterable` confirming type by reflecting the given subject and fetchs all the infos
  /// of type `OptionKeyDescribable`.
  ///
  /// - Parameter subject: The subject to be reflected.
  /// - Returns: The all cases of type `Self`.
  internal static func allCases<T>(reflecting subject: T) throws -> [Self] {
    return transform(reflecting: subject) { child -> Self? in
      if
        let label = child.label,
        let _ = child.value as? OptionDescribable
      {
        return Self(
          rawValue: (label.hasPrefix("_") ? String(label.dropFirst()) : label)
            .camelcase2dashcase()
        )
      }
      return nil
    }
  }
  
  /// Returns all coding keys for the `OptionKeysRepresentable` confirming types by reflecting the given subject and fetchs all the infos.
  ///
  /// - Parameter subject: The subject to be reflected.
  /// - Returns: The all cases of type `(Self, OptionDescribable)`.
  internal static func allCodingKeys<T>(reflecting subject: T) throws -> [(Self, OptionDescribable)] {
    return transform(reflecting: subject) { child -> (Self, OptionDescribable)? in
      if
        let label = child.label,
        let codingKey = Self(
          rawValue: (label.hasPrefix("_") ? String(label.dropFirst()) : label)
            .camelcase2dashcase()
        ),
        let value = child.value as? OptionDescribable
      {
        return (codingKey, value)
      }
      return nil
    }
  }
}

extension OptionKeysRepresentable where Self: CodingKey {
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

public protocol OptionsPropertyWrapper {
  /// The coding key type of `CodingKey & StringRawRepresentable` for decoding.
  associatedtype OptionKeys: OptionKeysRepresentable = WrappedOptionKeys<Self>
  /// The default initializer to initialize the `OptionsPropertyWrapper`, used by mirror to
  /// reflect the metainfo of the type.
  init()
}

/// A protocol represents the conforming types can be the options of a command of `CommandRepresentable`.
/// The conforming types must be decodable.
public protocol OptionsRepresentable: OptionsDescribable, Hashable {
  /// The coding key type of `CodingKey & StringRawRepresentable` for decoding.
  associatedtype OptionKeys: OptionKeysRepresentable
  /// The argument type of the arguments resolver.
  associatedtype Argument: Decodable = DefaultOptions.None
  /// The arguments resolver of the options.
  associatedtype ArgumentsResolver: ArgumentsResolvable = Commander.ArgumentsResolver<Argument>
  /// The global options of the commander.
  associatedtype SharedOptions: OptionsRepresentable = DefaultOptions.None
  /// The short keys of the options' coding keys.
  static var keys: [OptionKeys: Character] { get }
  /// The extends option keys for the `Options`.
  static var descriptions: [OptionKeys: OptionDescription] { get }
  /// Returns the global options of the running commander if any.
  var sharedOptions: SharedOptions? { get }
  /// The arguments of the options if arguments can be resolved.
  var arguments: [Self.ArgumentsResolver.Argument] { get set }
  /// Decode the options from the given command line arguments.
  ///
  /// - Parameter commandLineArgs: The command line arguments without command symbol.
  /// - Returns: The decoded options of `Self`.
  static func decoded(from commandLineArgs: [String]) throws -> Self
}

/// The protocol represents the conforming type means none and cannot be decoded.
public protocol NoneOptionsRepresentable: OptionsRepresentable { }
/// The protocol represents the conforming type means none and cannot be decoded.
public protocol EmptyOptionsRepresentable: OptionsRepresentable { }

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
  public var sharedOptions: SharedOptions? {
    return CommandPath
      .running
      .sharedOptions as? SharedOptions
  }
  /// The short keys of the options' coding keys.
  public static var stringKeys: [String: Character] {
    return SharedOptions
      .keys
      .reduce(into: [:]) { $0[$1.key.stringValue] = $1.value }
      .merging(
        keys
          .reduce(into: [:]) { $0[$1.key.stringValue] = $1.value }) {  c, _ in c }
      .merging(
        Help
          .Options
          .keys
          .reduce(into: [:]) { $0[$1.key.stringValue] = $1.value }) { c, _ in c }
  }
  /// Returns the options description list.
  public static var stringDescriptions: [String: OptionDescription] {
    return SharedOptions
      .descriptions
      .reduce(into: [:]) { $0[$1.key.stringValue] = $1.value }
      .merging(
        descriptions
          .reduce(into: [:]) { $0[$1.key.stringValue] = $1.value }) { c, _ in c }
      .merging(
        Help
          .Options
          .descriptions
          .reduce(into: [:]) { $0[$1.key.stringValue] = $1.value }) { c, _ in c }
  }
  /// Returns the type of the argument.
  public static var argumentType: Decodable.Type {
    return ArgumentsResolver
      .Argument
      .self
  }
  /// Returns all the coding keys of the options.
  public static var codingKeys: [String] {
    return OptionKeys
      .allCases
      .map { $0.stringValue }
  }
  /// Decode the options from the given command line arguments.
  ///
  /// - Parameter commandLineArgs: The command line arguments without command symbol.
  /// - Returns: The decoded options of `Self`.
  public static func decoded(from commandLineArgs: [String]) throws -> Self {
    return try OptionsDecoder()
      .decode(
        Self.self,
        from: commandLineArgs
      )
  }
  /// The arguments of the options if arguments can be resolved.
  public var arguments: [Self.ArgumentsResolver.Argument] {
    get { return _ArgumentsStorage[AnyOptions(options: self)] as? [ArgumentsResolver.Argument] ?? [] }
    set { _ArgumentsStorage[AnyOptions(options: self)] = newValue }
  }
}

extension OptionsRepresentable where Self.OptionKeys: CodingKey {
  /// Returns all the coding keys of the options.
  public static var codingKeys: [String] {
    return OptionKeys
      .allCases
      .map { $0.description }
  }
}

// MARK: - WrappedOptionKeys.Supports.

extension OptionsRepresentable where Self: OptionsPropertyWrapper, Self.OptionKeys == WrappedOptionKeys<Self> {
  /// The short keys of the options' coding keys.
  public static var keys: [Self.OptionKeys: Character] {
    return try! Self.OptionKeys
      .allCodingKeys(reflecting: Self.init())
      .compactMap { `case` -> (Self.OptionKeys, Character)? in
        if let short = `case`.1.k?.first {
          return (`case`.0, short)
        }
        return nil
      }
      .reduce(into: [:]) {
        $0[$1.0] = $1.1
      }
  }
  /// The extends option keys for the `Options`.
  public static var descriptions: [Self.OptionKeys: OptionDescription] {
    return try! Self.OptionKeys
      .allCodingKeys(reflecting: Self.init())
      .compactMap { `case` -> (Self.OptionKeys, OptionDescription)? in
        return (`case`.0, OptionDescription(defaultValue: `case`.1.defaultValue, usage: `case`.1.usage))
      }
      .reduce(into: [:]) {
        $0[$1.0] = $1.1
      }
  }
}
