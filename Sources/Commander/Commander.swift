//
//  Commander.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
//

import Foundation

extension FileHandle: TextOutputStream {
  public func write(_ string: String) {
    string.data(using: .utf8).map { write($0) }
  }
}

// MARK: - HelpCommand.

/// The built-in help command for the commander.
internal struct HelpCommand: CommandRepresentable {
  /// The options of the `HelpCommand`.
  public struct Options: OptionsRepresentable {
    /// Type alias for resolve string arguments.
    public typealias ArgumentsResolver = AnyArgumentsResolver<String>
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
    var stdout = FileHandle.standardOutput
    defer { stdout.closeFile() }
    
    func intents(_ level: Int) -> String {
      return String(repeating: " ", count: 2 * level)
    }
    
    func returns(_ level: Int) -> String {
      return String(repeating: "\n", count: level)
    }
    
    if options.arguments.isEmpty {
      let prefix = "Available commands for \(Commander.runningPath.split(separator: "/").last!):"
      let template = String(
        repeating: " ",
        count: Commander.allCommands.reduce(0) { max($0, $1.symbol.count) }
      )
      let commands = Commander.allCommands.map { command -> String in
        var fixedSymbol = template
        fixedSymbol.replaceSubrange(command.symbol.startIndex..<command.symbol.endIndex, with: command.symbol)
        return fixedSymbol + "  " + command.usage
      }.joined(separator: "\n  ")
      
      print(prefix, commands, separator: "\n  ", terminator: "\n", to: &stdout)
    } else {
      var unrecognizedCommand = [String]()
      let commands = options.arguments.compactMap { arg -> AnyCommandRepresentable.Type? in
        if let command = Commander.commands.first(where: { $0.symbol == arg }) {
          return command
        } else {
          unrecognizedCommand.append(arg)
          return nil
        }
      }
      
      guard unrecognizedCommand.isEmpty else {
        throw CommanderError.helpUnrecognizedCommands(commands: unrecognizedCommand)
      }
      
      let path = Commander.runningPath.split(separator: "/").last!
      let commandSymbols = options.arguments
      
      var sample = String(repeating: " ", count: path.count + 1 + commandSymbols.reduce(0) { max($0, $1.count) })
      let commandsOutputs = commands.map { cmd -> String in
        let options = cmd.optionsDescriber.description.isEmpty ? "" : "\(intents(1))[OPTIONS]"
        let arguments = cmd.optionsDescriber.isArgumentsResolvable ? " [ARGUMENTS]" : ""
        var symbol = sample
        let contents = "\(path) \(cmd.symbol)"
        symbol.replaceSubrange(contents.startIndex..<contents.endIndex, with: contents)
        return """
        Usage of '\(cmd.symbol)':
        \(returns(0))
        \(intents(1))$ \(symbol)\(options)\(arguments)
        \(returns(0))
        \(intents(2))\(cmd.usage)
        \(returns(0))
        \(intents(1))Options:
        \(returns(0))
        """
      }
      
      sample = String(repeating: " ", count: commands.map {
        ("[\(String(describing: $0.optionsDescriber.argumentType))]", $0.optionsDescriber.description)
      }.reduce(0) {
        max(max($0, $1.0.count), $1.1.reduce(0) {
          max($0, (($1.1.shortSymbol.map { "-\($0), " } ?? "") + "--\($1.0.stringValue)").count)
        })
      })
      
      let outputs = commands.enumerated().map { index, command -> String in
        let prefix = commandsOutputs[index]
        let options = command.optionsDescriber.description.map { desc -> String in
          var fixedSymbol = sample
          let symbol = (desc.1.shortSymbol.map { "-\($0), " } ?? "") + "--\(desc.0.stringValue)"
          fixedSymbol.replaceSubrange(symbol.startIndex..<symbol.endIndex, with: symbol)
          return intents(2) + fixedSymbol + intents(1) + desc.1.usage
          }.joined(separator: "\n")
        
        var suffix = ""
        if command.optionsDescriber.isArgumentsResolvable {
          let argType = "[\(String(describing: command.optionsDescriber.argumentType))]"
          var symbol = sample
          symbol.replaceSubrange(argType.startIndex..<argType.endIndex, with: argType)
          suffix = """
          \(returns(0))
          \(intents(1))Arguments:
          \(returns(0))
          \(intents(2))\(symbol)\(intents(1))\(path) \(command.symbol) [options] arg1 arg2 ...
          
          """
        }
        
        return prefix + "\n" + options + "\n" + suffix
      }.joined(separator: "\n")
      
      print(outputs, terminator: "", to: &stdout)
    }
  }
}

// MARK: - Commander.

public final class Commander {
  /// A closure of `(Error) -> Void` to handle the stderror.
  public static var errorHandler: ((Swift.Error) -> Void)?
  public static var commands: [AnyCommandRepresentable.Type] = []
  internal static var allCommands: [AnyCommandRepresentable.Type] {
    return [HelpCommand.self] + commands
  }
  
  /// The name of the current running commander.
  internal /* private(set) */ static var runningPath: String!
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
            throw CommanderError.invalidCommand(command: commandSymbol)
          } else {
            throw CommanderError.emptyCommand
          }
        }
      }
      
      try command?.run(with: [String](commands))
    } catch {
      if type(of: self).errorHandler?(error) == nil {
        let stderr = FileHandle.standardError
        defer { stderr.closeFile() }
        
        "\(String(describing: error))\n".data(using: .utf8).map { stderr.write($0) }
      }
      
      dispatchFailure()
    }
    
    dispatchSuccess()
  }
}
