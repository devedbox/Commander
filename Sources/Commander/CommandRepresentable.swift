//
//  CommandRepresentable.swift
//  Commander
//
//  Created by devedbox on 2018/10/2.
//

import Foundation

// MARK: - AnyCommandRepresentable.

/// A protocol represents the conforming types can run with the specific command line arguments.
/// This protocol represents type-erased command types without associated types can be used as
/// argument rather than generic constraints.
public protocol AnyCommandRepresentable {
  /// The command symbol also name of the command.
  static var symbol: String { get }
  /// The human-readable usage description of the commands.
  static var usage: String { get }
  /// The type of the options of the command.
  static var optionsType: OptionsRepresentable.Type { get }
  
  /// Run the commands with command line arguments.
  ///
  /// - Parameter commandLineArgs: The command line arguments with dropping command symbol.
  static func run(with commandLineArgs: [String]) throws
}

// MARK: - CommandRepresentable.

/// A protocol represents the conforming types can run with the specific options of associated
/// type `Options`.
public protocol CommandRepresentable: AnyCommandRepresentable {
  /// The associated type of `Options`.
  associatedtype Options: OptionsRepresentable
  /// The main entry of the command.
  ///
  /// - Parameter options: The options of `Options` of the command.
  static func main(_ options: Options) throws
}

// MARK: -

extension CommandRepresentable {
  /// The options type of the `CommandRepresentable`.
  public static var optionsType: OptionsRepresentable.Type {
    return Options.self
  }
  /// Run the command with command line arguments.
  public static func run(with commandLineArgs: [String]) throws {
    let options = try Options.decoded(from: commandLineArgs)
    try self.main(options)
  }
}
