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

// MARK: - Commander.

public final class Commander {
  /// A closure of `(Error) -> Void` to handle the stderror.
  public static var errorHandler: ((Swift.Error) -> Swift.Void)?
  /// The usage description of the commander.
  public static var usage: String = ""
  /// The registered available commands of the commander.
  public static var commands: [AnyCommandRepresentable.Type] = []
  /// Returns all commands of commander with registered commands along with built-in commands.
  internal static var allCommands: [AnyCommandRepresentable.Type] {
    return [HelpCommand.self] + commands
  }
  
  /// The name of the current running commander.
  internal private(set) static var runningPath: String!
  /// Creates a commander instance.
  public init() { }
  
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
  
  internal func dispatch(with commandLineArgs: [String]) throws {
    type(of: self).runningPath = commandLineArgs.first
    defer { type(of: self).runningPath = nil }
    
    var commands = commandLineArgs.dropFirst()
    let symbol = commands.popFirst()
    
    let command = type(of: self).allCommands.first {
      $0.symbol == symbol
    }
    
    if command == nil {
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
      try command?.run(with: [String](commands))
    } catch OptionsDecoder.Error.unrecognizedOptions(let optionsRawVals) {
      if
        HelpCommand.isHelpOptions(of: optionsRawVals),
        let command = symbol,
        !HelpCommand.isHelpOptions(of: [command])
      {
        var options = HelpCommand.Options(help: nil, intents: nil)
        options.arguments = [command]
        try HelpCommand.main(options)
      } else {
        throw OptionsDecoder.Error.unrecognizedOptions(optionsRawVals)
      }
    } catch {
      throw error
    }
  }
}
