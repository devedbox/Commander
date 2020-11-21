//
//  CommandRepresentable.swift
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

import Utility

// MARK: - CommandLevel.

/// The level of command that can be described.
public enum CommandLevel {
  /// The top level commander.
  case commander
  /// The command level.
  case command
}

// MARK: - CommandDescribable.

public protocol CommandDescribable: ShellCompletable {
  /// The type alias for `OptionsDescribable.Type`.
  typealias OptionsDescriber = OptionsDescribable.Type
  /// The type alias for [CommandDescribable.Type]`.
  typealias ChildrenDescribers = [CommandDescribable.Type]
  
  /// Returns the options type of the instance of `CommandDescribable`.
  static var optionsDescriber: OptionsDescriber { get }
  /// Returns the children of the insrance of `CommandDescribable`.
  static var childrenDescribers: ChildrenDescribers { get }
  /// The command symbol also name of the command.
  static var symbol: String { get }
  /// The human-readable usage description of the commands.
  static var usage: String { get }
  /// The level of the 'CommandDescribable'.
  static var level: CommandLevel { get }
}

// MARK: - ShellCompletable.

extension BuiltIn {
  /// Returns the completions list for the specific option key.
  ///
  /// - Parameter command: The command to be completed
  /// - Parameter commandLine: The command line arguments.
  /// - Returns: Returns the completion list for the given key.
  public static func complete(
    _ command: CommandDescribable.Type,
    for commandLine: Utility.CommandLine) -> [String]
  {
    let optionsf = {
      command.optionsDescriber.stringDescriptions.map {
        OptionsDecoder.optionsFormat.format($0.key)
      }
    }
    let shortOptionsf = {
      command.optionsDescriber.stringKeys.map {
        OptionsDecoder.optionsFormat.format(String($0.value), isShort: true)
      }
    }
    let commandsf = { command.childrenDescribers.map { $0.symbol } }
    
    switch commandLine.arguments.last {
    case let arg? where arg.hasPrefix(OptionsDecoder.optionsFormat.symbol):
      let options = optionsf()
      
      return options.contains(arg) ? command.optionsDescriber.completions(for: commandLine) : options
    case let arg? where arg.hasPrefix(OptionsDecoder.optionsFormat.shortSymbol):
      let shortOptions = shortOptionsf()
      
      return shortOptions.contains(arg) ? command.optionsDescriber.completions(for: commandLine) : shortOptions + optionsf()
    default:
      return optionsf() + shortOptionsf() + commandsf()
    }
  }
}

extension CommandDescribable {
  /// Returns the completions list for the specific option key.
  ///
  /// - Parameter commandLine: The command line arguments.
  /// - Returns: Returns the completion list for the given key.
  public static func completions(for commandLine: Utility.CommandLine) -> [String] {
    return BuiltIn.complete(self, for: commandLine)
  }
}

// MARK: - CommandDispatchable.

/// A protocol represents the conforming types can dispatch with the specific command line arguments.
/// This protocol represents type-erased command types without associated types can be used as
/// argument rather than generic constraints.
public protocol CommandDispatchable: CommandDescribable {
  /// The children type of the sub commands of the command.
  typealias Children = [CommandDispatchable.Type]
  /// Returns the subcommands of the command.
  static var children: Children { get }
  /// Dispatch the commands with command line arguments.
  ///
  /// - Parameter commandLineArgs: The command line arguments with dropping command symbol.
  static func dispatch(with commandLineArgs: [String]) throws
  /// Dispatch the commands with decoded options.
  ///
  /// - Parameter options: The decoded options.
  static func dispatch(with options: Any) throws
}

// MARK: - CommandDescribable.

extension CommandDispatchable {
  /// The command symbol also name of the command.
  public static var symbol: String {
    return String(reflecting: self).split(delimiter: ".").last?.camelcase2dashcase().replacingOccurrences(of: "-command", with: "") ?? ""
  }
  /// Returns the children of the insrance of `CommandDescribable`.
  public static var childrenDescribers: [CommandDescribable.Type] {
    return self.children
  }
  /// Reutrns the subcommands of the command.
  public static var children: Children { return [] }
  /// The level of the 'CommandDispatchable'.
  public static var level: CommandLevel { return .command }
}

// MARK: - CommandRepresentable.

/// A protocol represents the conforming types can dispatch with the specific options of associated
/// type `Options`.
public protocol CommandRepresentable: CommandDispatchable {
  /// The associated type of `Options`.
  associatedtype Options: OptionsRepresentable
  /// The main entry of the command.
  ///
  /// - Parameter options: The options of `Options` of the command.
  static func main(_ options: Options) throws
}

// MARK: -

extension CommandRepresentable {
  /// Returns the options type of the command.
  public static var optionsDescriber: OptionsDescribable.Type {
    return Options.self
  }
  /// Returns the children of the insrance of `CommandDescribable`.
  public static var children: Children { return [] }
  /// Dispatch the command with command line arguments.
  public static func dispatch(with commandLineArgs: [String]) throws {
    try self.main(try Options.decoded(from: commandLineArgs))
  }
  /// Dispatch the commands with decoded options.
  ///
  /// - Parameter options: The decoded options.
  public static func dispatch(with options: Any) throws {
    if let concreteOptions = options as? Options {
      try self.main(concreteOptions)
    }
  }
}
