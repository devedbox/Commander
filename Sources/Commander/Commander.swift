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

// MARK: - CommanderRepresentable.

public protocol CommanderRepresentable {
  /// The associated type of `Options`.
  associatedtype Options: OptionsRepresentable = Nothing
  /// A closure of `(Error) -> Void` to handle the stderror.
  static var errorHandler: ((Swift.Error) -> Swift.Void)? { get set }
  /// The registered available commands of the commander.
  static var commands: [AnyCommandRepresentable.Type] { get set }
  /// The human-readable usage description of the commands.
  static var usage: String { get set }
  /// The name of the current running commander.
  static var runningPath: String? { get set }
  /// The global options of current running commander if any.
  static var runningGlobalOptions: Options? { get set }
  
  /// Decoding the given command line argumants as the current command's options type and disatch the
  /// command with the decided options.
  func dispatch(with commandLineArgs: [String]) throws
}

extension CommanderRepresentable where Options == Nothing {
  /// The global options of current running commander if any.
  public static var runningGlobalOptions: Options? {
    get { return nil }
    set { }
  }
}

// MARK: - Dispatch.

extension CommanderRepresentable {
  /// Returns all commands of commander with registered commands along with built-in commands.
  internal static var allCommands: [AnyCommandRepresentable.Type] {
    return [HelpCommand.self] + commands
  }
  /// Decoding the current command line arguments of `CommandLine.arguments` as the current command's
  /// options type and dispatch the command with the decoded options.
  public func dispatch() -> Never {
    do {
      try dispatch(with: CommandLine.arguments)
    } catch {
      if type(of: self).errorHandler?(error) == nil {
        var stderr = FileHandle.standardError
        print(String(describing: error), to: &stderr)
      }
      dispatchFailure()
    }
    dispatchSuccess()
  }
  /// Decoding the given command line argumants as the current command's options type and disatch the
  /// command with the decided options.
  public func dispatch(with commandLineArgs: [String]) throws {
    defer { type(of: self).runningPath = nil }
    defer { type(of: self).runningGlobalOptions = nil }
    
    type(of: self).runningPath = commandLineArgs.first
    
    var commands = commandLineArgs.dropFirst()
    let symbol = commands.popFirst()
    
    let commandPath = type(of: self).allCommands.first {
      $0.symbol == symbol
    }.map {
      CommandPath(
        running: $0,
        at: type(of: self).runningPath!.split(separator: "/").last!.string
      )
    }
    
    if commandPath == nil {
      if
        case .format(let optionsSymbol, short: let shortSymbol) = OptionsDecoder.optionsFormat,
        let isOptionsSymbol = symbol?.hasPrefix(optionsSymbol),
        let isShortSymbol = symbol?.hasPrefix(shortSymbol),
        isOptionsSymbol || isShortSymbol
      {
        if
          commands.isEmpty,
          let options = symbol,
          options == "\(optionsSymbol)\(HelpCommand.Options.CodingKeys.help.rawValue)"
       || options == "\(shortSymbol)\(HelpCommand.Options.keys[.help]!)"
        {
          try HelpCommand.main(.init(help: nil, intents: nil))
        } else {
          try HelpCommand.run(with: [symbol!] + commands)
        }
      } else {
        if let commandSymbol = symbol {
          throw CommanderError.invalidCommand(command: commandSymbol)
        } else {
          throw CommanderError.emptyCommand
        }
      }
    }
    
    do {
      try commandPath?.run(with: Array(commands))
    } catch let dispatcher as CommandPath.Dispatcher {
      guard Options.self != Nothing.self else {
        throw CommanderError.unrecognizedOptions(dispatcher.options, path: dispatcher.path)
      }
      
      let unrecognizedOptions = dispatcher.options.filter { Options.CodingKeys.init(rawValue: $0) == nil }
      guard unrecognizedOptions.isEmpty else {
        throw CommanderError.unrecognizedOptions(unrecognizedOptions, path: dispatcher.path)
      }
      
      type(of: self).runningGlobalOptions = try Options(from: dispatcher.decoder)
      try dispatcher.path.command.run(with: dispatcher.decoded)
      
    } catch CommanderError.unrecognizedOptions(let options, path: let path) {
      if
        HelpCommand.validate(options: options) == true,
        HelpCommand.validate(options: [path.command.symbol]) == false
      {
        HelpCommand.path = path; defer { HelpCommand.path = nil }
        try HelpCommand.main(.default(arguments: [path.command.symbol]))
      } else {
        throw CommanderError.unrecognizedOptions(options, path: path)
      }
    } catch {
      throw error
    }
  }
}

// MARK: - Commander.

public final class Commander: CommanderRepresentable {
  /// A closure of `(Error) -> Void` to handle the stderror.
  public static var errorHandler: ((Error) -> Void)?
  /// The registered available commands of the commander.
  public static var commands: [AnyCommandRepresentable.Type] = []
  /// The name of the current running commander.
  public static var runningPath: String?
  /// The human-readable usage description of the commands.
  public static var usage: String = ""
  /// Creates the instance of `Commander`.
  public init() { }
}
