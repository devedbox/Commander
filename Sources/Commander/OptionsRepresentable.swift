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

// MARK: - AnyOptionsRepresentable.

public protocol AnyOptionsRepresentable: Decodable {
  /// Decode the options from the given command line arguments.
  ///
  /// - Parameter commandLineArgs: The command line arguments without command symbol.
  /// - Returns: The decoded options of `Self`.
  static func decoded(from commandLineArgs: [String]) throws -> Self
}

// MARK: - OptionsRepresentable.

/// A protocol represents the conforming types can be the options of a command of `CommandRepresentable`.
/// The conforming types must be decodable.
public protocol OptionsRepresentable: AnyOptionsRepresentable {
  /// The coding key type of `CodingKey & StringRawRepresentable` for decoding.
  associatedtype CodingKeys: CodingKey & StringRawRepresentable
  /// The description of `(CodingKeys, OptionKeyDescription)` of `OptionsReoresentable`.
  typealias Description = (CodingKeys, OptionKeyDescription)
  /// The extends option keys for the `Options`.
  static var description: [Description] { get }
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
}
