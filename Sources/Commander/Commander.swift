//
//  Commander.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
//

import Foundation

// MARK: - HelpCommand.

/// The built-in help command for the commander.
internal struct HelpCommand: CommandRepresentable {
  /// The options of the `HelpCommand`.
  public struct Options: OptionsRepresentable {
    /// The coding keys of `Options`.
    public enum CodingKeys: String, CodingKey, StringRawRepresentable {
      case help
    }
    /// Returns the description of the options.
    public static var description: [(Options.CodingKeys, OptionKeyDescription)] = [
      (.help, .short("h", usage: HelpCommand.usage))
    ]
    
    public let help: Bool?
  }
  
  public static var symbol: String = "help"
  public static var usage: String = "Prints the help message of the command"
  
  public static func main(_ options: Options) throws {
    let prefix = "Available commands for \(Commander.runningPath.split(separator: "/").last!):"
    let template = String(
      repeating: " ",
      count: Commander.allCommands.reduce(0) { max($0, $1.symbol.count) }
    )
    let commands = Commander.allCommands.map { command -> String in
      var fixedSymbol = template
      fixedSymbol.replaceSubrange(
        command.symbol.startIndex..<command.symbol.endIndex,
        with: command.symbol
      )
      return fixedSymbol + "  " + command.usage
    }.joined(separator: "\n  ")
    
    print(prefix, commands, separator: "\n  ", terminator: "\n")
  }
}

// MARK: - Commander.

public final class Commander {
  public static var commands: [AnyCommandRepresentable.Type] = []
  internal static var allCommands: [AnyCommandRepresentable.Type] {
    return [HelpCommand.self] + commands
  }
  
  /// The name of the current running commander.
  internal private(set) static var runningPath: String!
  public init() { }
  
  public func dispatch() -> Never {
    type(of: self).runningPath = CommandLine.arguments.first
    defer { type(of: self).runningPath = nil }
    
    var commands = CommandLine.arguments.dropFirst()
    let symbol = commands.popFirst()
    
    let command = type(of: self).allCommands.first {
      $0.symbol == symbol
    }
    
    do {
      if command == nil {
        if
          case .format(let optionsSymbol, short: let shortSymbol) = CommanderDecoder.optionsFormat,
          let isOptionsSymbol = symbol?.hasPrefix(optionsSymbol),
          let isShortSymbol = symbol?.hasPrefix(shortSymbol),
          isOptionsSymbol || isShortSymbol
        {
          try HelpCommand.run(with: [symbol!] + commands)
        } else {
          if let commandSymbol = symbol {
            throw Error.invalidCommand(command: commandSymbol)
          } else {
            throw Error.emptyCommand
          }
        }
      }
      
      try command?.run(with: [String](commands))
      dispatchSuccess()
    } catch {
      let stderr = FileHandle.standardError
      defer { stderr.closeFile() }
      
      "\(String(describing: error))\n".data(using: .utf8).map { stderr.write($0) }
      dispatchFailure()
    }
  }
}
