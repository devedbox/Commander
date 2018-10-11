//
//  HelpCommand.swift
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

// MARK: - AnyCommandRepresentable.

extension AnyCommandRepresentable {
  internal static func evaluate(_ symbols: [String]) -> (command: AnyCommandRepresentable.Type?, symbol: [String]) {
    if symbol == symbols.first {
      let subsymbols = Array(symbols.dropFirst())
      if
        !subcommands.isEmpty,
        let subcommand = subcommands.first(where: { $0.symbol == subsymbols.first })
      {
        return subcommand.evaluate(subsymbols)
      } else {
        return (self, Array(symbols.dropFirst()))
      }
    }
    return (nil, symbols)
  }
}

// MARK: - HelpCommand.

/// The built-in help command for the commander.
internal struct HelpCommand: CommandRepresentable {
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
      .help: .usage(HelpCommand.usage)
    ]
    
    internal let help: Bool?
    internal let intents: Int?
    
    internal static func `default`(arguments: [ArgumentsResolver.Argument]) -> Options {
      var options = Options(help: nil, intents: nil)
      options.arguments = arguments
      return options
    }
  }
  /// The running command path.
  internal static var path: CommandPath!
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
  /// Run the command with command line arguments.
  @discardableResult
  internal static func run(with commandLineArgs: [String]) throws -> AnyCommandRepresentable.Type {
    switch OptionsDecoder.optionsFormat {
    case .format(let symbol, short: let shortSymbol):
      let options = commandLineArgs.filter {
        $0.hasPrefix(symbol) || $0.hasPrefix(shortSymbol)
      }
      if !options.isEmpty {
        throw OptionsDecoder.Error.unrecognizedOptions(options.map {
          let index = $0.endsIndex(matchs: symbol) ?? $0.endsIndex(matchs: shortSymbol)
          return String($0[index!...])
        })
      }
    }
    
    let options = try Options.decoded(from: commandLineArgs)
    try self.main(options)
    
    return self
  }
  /// The main function of the command.
  internal static func main(_ options: Options) throws {
    var stdout = FileHandle.standardOutput
    let path = self.path?.paths.joined(separator: " ") ?? Commander.runningPath.split(separator: "/").last!.string
    
    if options.arguments.isEmpty {
      print(
        CommandDescriber(path: path).describe(Commander.self),
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
      
      print(
        commands.map { CommandDescriber(path: path).describe($0) }.joined(separator: "\n\n"),
        terminator: "\n",
        to: &stdout
      )
    }
  }
}
