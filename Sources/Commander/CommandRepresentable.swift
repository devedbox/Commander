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

// MARK: - AnyCommandRepresentable.

/// A protocol represents the conforming types can run with the specific command line arguments.
/// This protocol represents type-erased command types without associated types can be used as
/// argument rather than generic constraints.
public protocol AnyCommandRepresentable {
  /// Returns the options type of the command.
  static var optionsDescriber: OptionsDescribable.Type { get }
  /// The command symbol also name of the command.
  static var symbol: String { get }
  /// The human-readable usage description of the commands.
  static var usage: String { get }
  
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
  /// Returns the options type of the command.
  public static var optionsDescriber: OptionsDescribable.Type {
    return Options.self
  }
  /// Run the command with command line arguments.
  public static func run(with commandLineArgs: [String]) throws {
    let options = try Options.decoded(from: commandLineArgs)
    try self.main(options)
  }
}
