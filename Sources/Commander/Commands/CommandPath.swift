//
//  CommandPath.swift
//  Commander
//
//  Created by devedbox on 2018/10/11.
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

// MARK: - CommandPath.

/// A type represents the running paths of the specific command of `AnyCommandRepresetnable.Type`.
public struct CommandPath {
  /// The error info of the command path to redispatch with the.
  internal struct Dispatcher: Error {
    /// Running command path.
    internal let path: CommandPath
    /// The unrecognized options keys.
    internal let options: [String]
    /// The decoded options.
    internal let decoded: Decodable
    /// The decoder to decode the options.
    internal let decoder: Decoder
  }
  
  /// The running commander.
  internal static var runningCommander: CommandDescribable.Type!
  /// The running command path.
  internal static var runningCommandPath: CommandPath!
  /// The running commander path of the commander.
  internal static var runningCommanderPath: String!
  /// The running commander's usage.
  internal static var runningCommanderUsage: String!
  /// The running global options of the commander.
  internal static var runningGlobalOptions: OptionsDescribable?
  /// The running commander's available commands.
  internal static var runningCommands: [AnyCommandRepresentable.Type] = []
  
  /// The running paths of the ass
  public private(set) var paths: [String]
  /// The exact running command of the command path.
  public private(set) var command: AnyCommandRepresentable.Type
  /// Creates an instance of `CommandPath` with the given command and running path.
  ///
  /// - Parameter command: The command to run at the path.
  /// - Parameter path: The path of the command to run at.
  public init(
    running command: AnyCommandRepresentable.Type,
    at path: String)
  {
    self.paths = path.split(separator: " ").map { String($0) }
    self.command = command
  }
  
  /// Run the command with specific command line arguments and returns the exact running command path
  /// of `CommandPath`.
  ///
  /// The command path of `CommandPath` will run the command recursively if the given command line
  /// arguments matchs the paths of subcommands of the command.
  ///
  /// - Parameter commandLineArgs: The command line arguments.
  /// - Parameter ignoresExecution: Should ignore the execution of the command path.
  /// - Returns: Returns the exact running path.
  @discardableResult
  internal func run(with commandLineArgs: [String], ignoresExecution: Bool = false) throws -> CommandPath {
    if
      let first = commandLineArgs.first,
      OptionsDecoder.optionsFormat.index(of: first) == nil,
      let subcommand = command.subcommands.filter({ $0.symbol == first }).first
    { // Consider a subcommand.
      return try CommandPath(
        running: subcommand,
        at: "\(paths.joined(separator: " ")) \(command.symbol)"
        ).run(
          with: Array(commandLineArgs.dropFirst()),
          ignoresExecution: ignoresExecution
      )
    }
    
    guard ignoresExecution == false else {
      return self
    }
    
    // Set the running command path before run the command path.
    // Defer setting nil of the running command path.
    type(of: self).runningCommandPath = self; defer { type(of: self).runningCommandPath = nil }
    
    do {
      try command.run(with: commandLineArgs)
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: nil, decoder: _, decodeError: let error) {
      throw CommanderError.unrecognizedOptions(options, path: self, underlyingError: error)
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded?, decoder: let decoder?, decodeError: _) {
      throw Dispatcher(path: self, options: options, decoded: decoded, decoder: decoder)
    } catch is ReturnError {
      return self
    } catch {
      throw error
    }
    
    return self
  }
}
