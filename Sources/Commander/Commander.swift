//
//  Commander.swift
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

import Foundation
import Utility

/// The logger to log the output message to standard output.
public private(set) var logger: TextOutputStream!

// MARK: - CommanderRepresentable.

public protocol CommanderRepresentable: CommandDescribable, TextOutputStream {
  /// The associated type of `Options`.
  associatedtype Options: OptionsRepresentable = Nothing
  /// A closure of `(Error) -> Void` to handle the stderror.
  static var errorHandler: ((Swift.Error) -> Swift.Void)? { get }
  /// A closure of `(String) -> Void` to handle the stdout.
  static var outputHandler: ((String) -> Void)? { get }
  /// The registered available commands of the commander.
  static var commands: [CommandDispatchable.Type] { get }
  
  /// Decoding the given command line argumants as the current command's options type and disatch the
  /// command with the decided options.
  func dispatch(with commandLineArgs: [String]) throws
}

// MARK: - Dispatch.

extension CommanderRepresentable {
  /// Returns the options type of the command.
  public static var optionsDescriber: OptionsDescribable.Type { return Options.self }
  /// Returns the children of the insrance of `CommandDescribable`.
  public static var children: [CommandDescribable.Type] { return allCommands }
  /// The command symbol also name of the command.
  public static var symbol: String { return "" }
  /// The command level.
  public static var level: CommandLevel { return .commander }
  /// Appends the given string to the stream.
  public mutating func write(_ string: String) {
    (type(of: self).outputHandler?(string) == nil).true {
      var stdout = FileHandle.standardOutput; print(string, terminator: "", to: &stdout)
    }
  }
  /// Returns all commands of commander with registered commands along with built-in commands.
  internal static var allCommands: [CommandDispatchable.Type] {
    return [BuiltIn.help] + commands
  }
  /// Decoding the current command line arguments of `CommandLine.arguments` as the current command's
  /// options type and dispatch the command with the decoded options.
#if DEBUG
  @discardableResult
  public func dispatch() -> Result {
    do {
      try dispatch(with: CommandLine.arguments)
    } catch {
      (type(of: self).errorHandler?(error) == nil).true {
        var stderr = FileHandle.standardError; print(String(describing: error), to: &stderr)
      }
      return dispatchFailure()
    }
    return dispatchSuccess()
  }
#else
  public func dispatch() -> Result {
    do {
      try dispatch(with: CommandLine.arguments)
    } catch {
      (type(of: self).errorHandler?(error) == nil).true {
        var stderr = FileHandle.standardError; print(String(describing: error), to: &stderr)
      }
      return dispatchFailure()
    }
    return dispatchSuccess()
  }
#endif
  /// Decoding the given command line argumants as the current command's options type and disatch the
  /// command with the decided options.
  public func dispatch(with commandLineArgs: [String]) throws {
    defer {
      CommandPath.runningCommander = nil // Clear the running commander.
      CommandPath.runningCommanderPath = nil // Clear the running path of commander.
      CommandPath.runningGlobalOptions = nil // Clear the running global options.
      CommandPath.runningCommanderUsage = nil // Clear the runnung commander usage.
      CommandPath.runningCommands = [] // Clear the running commands.
      logger = nil // Reset the logger.
      _ArgumentsStorage = [:] // Reset the storage of arguments.
    }
    
    let runningPath = commandLineArgs.first!
    
    logger = self
    CommandPath.runningCommander = type(of: self)
    CommandPath.runningCommanderPath = runningPath
    CommandPath.runningCommanderUsage = type(of: self).usage
    CommandPath.runningCommands = type(of: self).allCommands
    
    var commands = commandLineArgs.dropFirst()
    let symbol = commands.popFirst()
    let allCommands = type(of: self).allCommands + BuiltIn.commands
    
    let commandPath = allCommands.first { $0.symbol == symbol }.map {
      CommandPath(
        running: $0,
        at: runningPath.split(separator: "/").last!.string
      )
    }
    
    do {
      if try commandPath?.run(with: Array(commands)) == nil {
        guard let symbol = symbol else {
          throw Error.emptyCommand
        }
        
        if OptionsDecoder.optionsFormat.validate(symbol) {
          if Help.Options.validate(symbol) {
            try Help.main(
              OptionsDecoder().decode(Help.Options.self, from: [symbol] + Array(commands))
            )
          } else {
            throw Error.invalidOptions(options: symbol)
          }
        } else {
          throw Error.invalidCommand(command: symbol)
        }
      }
    } catch let dispatcher as CommandPath.Dispatcher {
      guard Options.self != Nothing.self else {
        try Help.resolve(dispatcher.options, path: dispatcher.path, commandLineArgs: commandLineArgs)
        return
      }
      
      let unrecognizedOptions = dispatcher.options.filter { Options.CodingKeys(rawValue: $0) == nil }
      guard unrecognizedOptions.isEmpty else {
        throw Error.unrecognizedOptions(
          unrecognizedOptions,
          path: dispatcher.path,
          underlyingError: nil
        )
      }
      
      CommandPath.runningGlobalOptions = try Options(from: dispatcher.decoder)
      try dispatcher.path.command.dispatch(with: dispatcher.decoded)
      
    } catch Error.unrecognizedOptions(let options, path: let path, underlyingError: let error) {
      try Set(Options.codingKeys).isSuperset(of: Set(options)).true {
        try error.map { throw $0 }
      }
      
      try Help.resolve(options, path: path, commandLineArgs: commandLineArgs)
    } catch {
      throw error
    }
  }
}
