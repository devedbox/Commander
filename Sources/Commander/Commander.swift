//
//  Commander.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
//

// MARK: - HelpCommand.

internal struct HelpCommand: CommandRepresentable {
  public struct Options: OptionsRepresentable {
    public enum CodingKeys: String, CodingKey, StringRawRepresentable {
      case help
    }
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
  
  public func dispatch() throws {
    type(of: self).runningPath = CommandLine.arguments.first
    defer { type(of: self).runningPath = nil }
    
    var commands = CommandLine.arguments.dropFirst()
    let symbol = commands.popFirst()
    
    let command = type(of: self).allCommands.first {
      $0.symbol == symbol
    }
    
    if command == nil {
      if
        case .format(let optionsSymbol, short: let shortSymbol) = CommanderDecoder.optionsFormat,
        let isOptionsSymbol = symbol?.hasPrefix(optionsSymbol),
        let isShortSymbol = symbol?.hasPrefix(shortSymbol),
        isOptionsSymbol || isShortSymbol
      {
        try HelpCommand.run(with: [symbol!] + commands)
        dispatchSuccess()
      } else {
        throw Error.invalidCommandGiven
      }
    }
    
    try command!.run(with: [String](commands))
    dispatchSuccess()
  }
}
