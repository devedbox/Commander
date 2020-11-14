//
//  BuiltIn.swift
//  Commander
//
//  Created by devedbox on 2018/11/6.
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

// MARK: - Public.

/// A closure of `(Error) -> Void` to handle the stderror.
public var errorHandler: ((Swift.Error) -> Void)? {
  get { return BuiltIn.Commander.errorHandler }
  set { BuiltIn.Commander.errorHandler = newValue }
}
/// A closure of `(String) -> Void` to handle the stdout.
public var outputHandler: ((String) -> Void)? {
  get { return BuiltIn.Commander.outputHandler }
  set { BuiltIn.Commander.outputHandler = newValue }
}
/// The registered available commands of the commander.
public var commands: [CommandDispatchable.Type] {
  get { return BuiltIn.Commander.commands }
  set { BuiltIn.Commander.commands = newValue }
}
/// The human-readable usage description of the commands.
public var usage: String {
  get { return BuiltIn.Commander.usage }
  set { BuiltIn.Commander.usage = newValue }
}
/// Decoding the current command line arguments of `CommandLine.arguments` as the current command's
/// options type and dispatch the command with the decoded options.
public func dispatch() { BuiltIn.Commander().dispatch() }
// MARK: - BuiltIn.

/// The namespace for built-in concepts and commands.
public enum BuiltIn {
  
  // MARK: Commander.
  
  public final class Commander: CommanderRepresentable {
    /// A closure of `(Error) -> Void` to handle the stderror.
    public static var errorHandler: ((Swift.Error) -> Void)?
    /// A closure of `(String) -> Void` to handle the stdout.
    public static var outputHandler: ((String) -> Void)?
    /// The registered available commands of the commander.
    public static var commands: [CommandDispatchable.Type] = []
    /// The human-readable usage description of the commands.
    public static var usage: String = ""
    /// Creates the instance of `Commander`.
    public init() { }
  }
  
  /// The built-in help command.
  public private(set) static var help: CommandDispatchable.Type = Help.self
  /// The built-in commands for the commander except help command.
  public private(set) static var commands: [CommandDispatchable.Type] = [
    Complete.self // The complete command to show the complete word list of given command line parameters.
  ]
}
