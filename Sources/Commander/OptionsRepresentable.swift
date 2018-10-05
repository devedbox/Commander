//
//  OptionRepresentable.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
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
  associatedtype Arguments: Decodable
}

public struct AnyArgumentsResolver<T: Decodable>: ArgumentsResolvable {
  public typealias Arguments = T
}

public struct Void: Decodable {
  public init(from decoder: Decoder) throws {
    throw CommanderDecoder.Error.unresolvableArguments
  }
}

// MARK: - AnyOptionsRepresentable.

public typealias OptionsDecodable = Decodable & Hashable

public protocol AnyOptionsRepresentable: OptionsDecodable {
  /// Decode the options from the given command line arguments.
  ///
  /// - Parameter commandLineArgs: The command line arguments without command symbol.
  /// - Returns: The decoded options of `Self`.
  static func decoded(from commandLineArgs: [String]) throws -> Self
}

internal struct AnyOptions<T: AnyOptionsRepresentable>: Hashable {
  internal private(set) var options: T
}

internal var _ArgumentsStorage: [AnyHashable: Any] = [:]

// MARK: - OptionsRepresentable.

/// A protocol represents the conforming types can be the options of a command of `CommandRepresentable`.
/// The conforming types must be decodable.
public protocol OptionsRepresentable: AnyOptionsRepresentable {
  /// The coding key type of `CodingKey & StringRawRepresentable` for decoding.
  associatedtype CodingKeys: CodingKey & StringRawRepresentable
  /// The arguments resolver of the options.
  associatedtype ArgumentsResolver: ArgumentsResolvable = AnyArgumentsResolver<Void>
  /// The description of `(CodingKeys, OptionKeyDescription)` of `OptionsReoresentable`.
  typealias Description = (CodingKeys, OptionKeyDescription)
  /// The extends option keys for the `Options`.
  static var description: [Description] { get }
  var arguments: [ArgumentsResolver.Arguments] { get set }
}

/// Get the short key of the coding key if any.
internal func shortKey(for key: CodingKey, in keys: [(CodingKey, OptionKeyDescription)]) -> String? {
  return keys.first {
    $0.0.stringValue == key.stringValue
  }?.1.shortSymbol.map {
    String($0)
  }
}

// MARK: -

extension OptionsRepresentable {
  /// Decode the options from the given command line arguments.
  ///
  /// - Parameter commandLineArgs: The command line arguments without command symbol.
  /// - Returns: The decoded options of `Self`.
  public static func decoded(from commandLineArgs: [String]) throws -> Self {
    return try CommanderDecoder().decode(Self.self, from: commandLineArgs)
  }
  
  public var arguments: [ArgumentsResolver.Arguments] {
    get {
      return _ArgumentsStorage[AnyOptions(options: self)] as? [ArgumentsResolver.Arguments] ?? []
    }
    set {
      _ArgumentsStorage[AnyOptions(options: self)] = newValue
    }
  }
}

extension OptionsRepresentable where ArgumentsResolver == AnyArgumentsResolver<Void> {
  public var arguments: [ArgumentsResolver.Arguments] {
    get { return [] }
    set { }
  }
}
