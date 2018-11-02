//
//  Help.swift
//  Commander
//
//  Created by devedbox on 2018/10/10.
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

// MARK: - FileHandle.

extension FileHandle: TextOutputStream {
  /// Write the string to file handle.
  public func write(_ string: String) {
    string.data(using: .utf8).map { write($0) }
  }
}

// MARK: - Help.

/// The built-in help command for the commander.
internal struct Help: CommandRepresentable {
  /// The options of the `HelpCommand`.
  internal struct Options: OptionsRepresentable {
    /// Type alias for resolve string arguments.
    internal typealias ArgumentsResolver = AnyArgumentsResolver<String>
    /// The coding keys of `Options`.
    internal enum CodingKeys: String, CodingKeysRepresentable {
      case help
      case intents
    }
    internal static let keys: [Options.CodingKeys: Character] = [
      .help: "h"
    ]
    /// Returns the description of the options.
    internal static var descriptions: [Options.CodingKeys: OptionDescription] = [
      .help: .usage(Help.usage)
    ]
    
    internal let help: Bool?
    internal let intents: Int?
    
    internal init(
      help: Bool = false,
      intents: Int = 0)
    {
      self.help = help
      self.intents = intents
    }
    
    /// Decode the options from the given command line arguments.
    ///
    /// - Parameter commandLineArgs: The command line arguments without command symbol.
    /// - Returns: The decoded options of `Self`.
    internal static func decoded(from commandLineArgs: [String]) throws -> Options {
      switch OptionsDecoder.optionsFormat {
      case .format(let symbol, short: let shortSymbol):
        let options = commandLineArgs.filter {
          $0.hasPrefix(symbol) || $0.hasPrefix(shortSymbol)
        }
        if !options.isEmpty {
          throw OptionsDecoder.Error.unrecognizedOptions(options.map {
            let index = $0.endsIndex(matchs: symbol) ?? $0.endsIndex(matchs: shortSymbol)
            return String($0[index!...])
          }, decoded: nil, decoder: nil)
        }
      }
      
      return try OptionsDecoder().decode(self, from: commandLineArgs)
    }
    
    internal static func `default`(arguments: [ArgumentsResolver.Argument]) -> Options {
      var options = Options()
      options.arguments = arguments
      return options
    }
  }
  /// The running command path.
  internal static var path: CommandPath!
  /// The running commander path of the commander.
  internal static var runningPath: String!
  /// The running commander's usage.
  internal static var runningCommanderUsage: String!
  /// The running commander's available commands.
  internal static var runningCommands: [AnyCommandRepresentable.Type] = []
  /// The command symbol.
  internal static var symbol: String = "help"
  /// The usage of the command.
  internal static var usage: String = "Prints the help message of the command. Usage: [[--help|-h][help COMMAND][COMMAND --help][COMMAND -h]]"
  /// Returns a bool value indicates if the given options raw value is 'help' option.
  internal static func validate(options: [String]) -> Bool {
    if
      options.count == 1,
      let option = options.last,
      option == Options.CodingKeys.help.rawValue
   || option == (Options.keys[.help]).map { String($0) }
    {
      return true
    }
    
    return false
  }
  /// Try to validate and run the help command if the given options if valid help options.
  internal static func resolve(_ options: [String], path: CommandPath) throws {
    if
      validate(options: options) == true,
      validate(options: [path.command.symbol]) == false
    {
      self.path = path; defer { self.path = nil }
      try main(.default(arguments: [path.command.symbol]))
    } else {
      throw CommanderError.unrecognizedOptions(options, path: path)
    }
  }
  /// The main function of the command.
  internal static func main(_ options: Options) throws {
    var stdout = FileHandle.standardOutput
    let path = self.path?.paths.joined(separator: " ") ?? runningPath.split(separator: "/").last!.string
    
    if options.arguments.isEmpty {
      print(
        CommandDescriber(path: path).describe(commander: runningCommanderUsage, commands: runningCommands),
        terminator: "\n",
        to: &stdout
      )
      
      /* FIXME: Disable the subcommands' description for no prefered formats for now.
       print(prefix, commands, "\nDescriptions:", separator: "\n  ", terminator: "\n\n", to: &stdout)
       
       var options = Options(help: nil, intents: 1)
       options.arguments = Commander.commands.map { $0.symbol }
       try self.main(options) */
    } else {
      var unrecognizedCommand = [String]()
      let commands = options.arguments.compactMap { arg -> AnyCommandRepresentable.Type? in
        if let command = runningCommands.first(where: { $0.symbol == arg }) {
          return command
        } else {
          unrecognizedCommand.append(arg)
        }
        return nil
      }
      
      guard unrecognizedCommand.isEmpty else {
        throw CommanderError.helpUnrecognizedCommands(commands: unrecognizedCommand)
      }
      
      print(
        commands.map { CommandDescriber(path: path).describe($0) }.joined(separator: "\n\n"),
        terminator: "\n",
        to: &stdout
      )
    }
  }
}
