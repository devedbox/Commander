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
  internal struct Dispatcher: Swift.Error {
    /// Running command path.
    internal let path: CommandPath
    /// The unrecognized options keys.
    internal let options: [String]
    /// The decoded options.
    internal let decoded: Decodable
    /// The decoder to decode the options.
    internal let decoder: Decoder
  }
  
  /// The running context type of the command path.
  internal struct RunningContext {
    /// The running commander.
    internal var commander: CommandDescribable.Type!
    /// The running command path.
    internal var commandPath: CommandPath!
    /// The command path with exceptions.
    internal var exceptionCommandPath: CommandPath!
    /// The running commander path of the commander.
    internal var commanderPath: String!
    /// The running commander's usage.
    internal var commanderUsage: String!
    /// The running global options of the commander.
    internal var sharedOptions: OptionsDescribable?
    /// The running commander's available commands.
    internal var commands: [CommandDispatchable.Type] = []
  }
  
  /// The running context of the command path.
  internal static var running: RunningContext = RunningContext()
  
  /// The running paths of the ass
  public private(set) var paths: [String]
  /// The exact running command of the command path.
  public private(set) var command: CommandDispatchable.Type
  /// Creates an instance of `CommandPath` with the given command and running path.
  ///
  /// - Parameter command: The command to run at the path.
  /// - Parameter path: The path of the command to run at.
  public init(
    running command: CommandDispatchable.Type,
    at path: String)
  {
    self.init(running: command, at: path.split(separator: " ").map { String($0) })
  }
  /// Creates an instance of `CommandPath` with the given command and running paths.
  ///
  /// - Parameter command: The command to run at the path.
  /// - Parameter paths: The separated paths of the command to run at.
  public init(
    running command: CommandDispatchable.Type,
    at paths: [String])
  {
    self.paths = paths
    self.command = command
  }
  /// Returns the all matches available command paths  and unrecognized symbols of the given command symbols.
  ///
  /// - Parameter symbols: The command symbols to be evaluated.
  /// - Returns: The tuple of command paths and unrecognized symbols.
  public static func maxMatches(_ symbols: [String]) throws -> [CommandPath] {
    var index = symbols.startIndex
    var unrecognizedIndices: [Array<String>.Index] = []
    var commandGroups: [[CommandDescribable.Type]] = []
    
    /// Matches the commands in the given symbols as long as possiable.
    func match(
      from index: inout Array<String>.Index,
      in command: CommandDescribable.Type? = nil) -> [CommandDescribable.Type]
    {
      guard index < symbols.endIndex else { return [] }
      
      var commands: [CommandDescribable.Type] = []
      let symbol = symbols[index]
      let matchingCommands = command?.children ?? self.running.commands
      
      if let matchingCommand = matchingCommands.first(where: { $0.symbol == symbol }) {
        symbols.formIndex(after: &index)
        commands += [matchingCommand]
        commands += match(from: &index, in: matchingCommand)
      }
      
      return commands
    }
    
    while index < symbols.endIndex {
      switch match(from: &index) {
      case let group where group.isEmpty:
        unrecognizedIndices.append(index)
        symbols.formIndex(after: &index)
      case let group where group.isEmpty == false:
        commandGroups.append(group)
      default: break
      }
    }
    
    switch unrecognizedIndices {
    case let t where t.isEmpty == false:
      throw Error.unrecognizedCommands(commands: unrecognizedIndices.map { symbols[$0] })
    default:
      return commandGroups.compactMap {
        CommandPath(
          running: $0.last! as! CommandDispatchable.Type,
          at: [self.running.commanderPath.split(delimiter: "/").last!] + $0.dropLast().map { $0.symbol }
        )
      }
    }
  }
  /// Returns the first mached command path for the given command symbol.
  ///
  /// - Parameter symbol: The command symbols to be evaluated.
  /// - Returns: The matched command path of the symbol.
  public static func of(_ symbol: String) throws -> CommandPath {
    func recursiveBuildPaths(
      _ input: inout [String],
      in commands: [CommandDispatchable.Type]) -> CommandDispatchable.Type?
    {
      guard commands.isEmpty == false else { return nil }
      if let command = commands.first(where: { $0.symbol == symbol }) { return command }
      
      var iterator = commands.makeIterator()
      while let command = iterator.next() {
        input.append(command.symbol)
        if let target = recursiveBuildPaths(&input, in: command.children) { return target }
        input.removeLast()
      }
      
      return nil
    }
    
    var paths: [String] = [self.running.commanderPath.split(delimiter: "/").last!]
    if let command = recursiveBuildPaths(&paths, in: self.running.commands) {
      return CommandPath(running: command, at: paths.joined(separator: " "))
    }
    
    throw Error.unrecognizedCommands(commands: [symbol])
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
  internal func run(with commandLineArgs: [String], skipping: Bool = false) throws -> CommandPath {
    if
      let first = commandLineArgs.first,
      OptionsDecoder.optionsFormat.index(of: first) == nil,
      let subcommand = command.children.filter({ $0.symbol == first }).first
    { // Consider a subcommand.
      return try CommandPath(
        running: subcommand,
        at: "\(paths.joined(separator: " ")) \(command.symbol)"
      ).run(
        with: Array(commandLineArgs.dropFirst()),
        skipping: skipping
      )
    }
    
    guard skipping == false else {
      return self
    }
    
    // Set the running command path before run the command path.
    // Defer setting nil of the running command path.
    type(of: self).running.commandPath = self; defer { type(of: self).running.commandPath = nil }
    type(of: self).running.exceptionCommandPath = self
    
    do {
      try command.dispatch(with: commandLineArgs)
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: nil, decoder: _, decodeError: let error) {
      throw Error.unrecognizedOptions(options, path: self, underlyingError: error)
    } catch OptionsDecoder.Error.unrecognizedOptions(let options, decoded: let decoded?, decoder: let decoder?, decodeError: _) {
      throw Dispatcher(path: self, options: options, decoded: decoded, decoder: decoder)
    } catch Signal.return {
      return self
    } catch {
      throw error
    }
    
    return self
  }
}
