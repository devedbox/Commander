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
import Utility

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
    internal static let keys: [Options.CodingKeys: Character] = [.help: "h"]
    /// Returns the description of the options.
    internal static var descriptions: [Options.CodingKeys: OptionDescription] = [
      .help: .usage("Prints the help message of the command. Usage: [[--help|-h][COMMAND --help][COMMAND -h]]")
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
      let options = commandLineArgs.filter { OptionsDecoder.optionsFormat.validate($0) }
      
      try options.isEmpty.false {
        throw OptionsDecoder.Error.unrecognizedOptions(options.map {
          String($0[OptionsDecoder.optionsFormat.index(of: $0)!...])
        }, decoded: nil, decoder: nil, decodeError: nil)
      }
      
      return try OptionsDecoder().decode(self, from: commandLineArgs)
    }
    
    internal static func `default`(arguments: [ArgumentsResolver.Argument]) -> Options {
      var options = Options()
      options.arguments = arguments
      return options
    }
  }
  /// The resolving command path.
  internal static var path: CommandPath!
  /// The command symbol.
  internal static var symbol: String = "help"
  /// The usage of the command.
  internal static var usage: String = "Prints the help message of the command. Usage: [help [COMMANDS]]"
  /// Returns a bool value indicates if the given options raw value is 'help' option.
  internal static func validate(options: [String]) throws -> Bool {
    try options.isSingle.false {
      throw CommanderError.helpExtraOptions(options: options)
    }
    
    if
      let option = options.last,
      option == Options.CodingKeys.help.rawValue
   || option == (Options.keys[.help]).map { String($0) }
    {
      return true
    }
    
    return false
  }
  /// Try to validate and run the help command if the given options if valid help options.
  internal static func resolve(
    _ options: [String],
    path: CommandPath,
    commandLineArgs: [String]) throws
  {
    var options = options; options += commandLineArgs.compactMap {
      if let index = OptionsDecoder.optionsFormat.index(of: $0) {
        return Optional.some(String($0[index...])).flatMap {
          if
            $0 != Options.CodingKeys.help.rawValue,
            $0 != String(Options.keys[.help]!),
            !options.contains($0)
          {
            return $0
          }
          
          return nil
        }
      }
      return nil
    }
    
    if
      try validate(options: options) == true,
      try validate(options: [path.command.symbol]) == false
    {
      self.path = path; defer { self.path = nil }
      try main(.default(arguments: []))
    } else {
      throw CommanderError.unrecognizedOptions(options, path: path, underlyingError: nil)
    }
  }
  /// The main function of the command.
  internal static func main(_ options: Options) throws {
    let path = self.path?.paths.joined(separator: " ") ?? CommandPath.runningCommanderPath.split(separator: "/").last!.string
    
    if options.arguments.isEmpty {
      if let command = self.path?.command {
        logger <<< CommandDescriber(path: path).describe(command) <<< "\n"
      } else {
        logger <<< CommandDescriber(path: path).describe(CommandPath.runningCommander) <<< "\n"
      }
    } else {
      var unrecognizedCommand = [String]()
      let commands = options.arguments.compactMap { arg -> CommandDispatchable.Type? in
        if let command = CommandPath.runningCommands.first(where: { $0.symbol == arg }) {
          return command
        } else {
          unrecognizedCommand.append(arg)
        }
        return nil
      }
      
      guard unrecognizedCommand.isEmpty else {
        throw CommanderError.helpUnrecognizedCommands(commands: unrecognizedCommand)
      }
      
      logger <<< commands.map { CommandDescriber(path: path).describe($0) }.joined(separator: "\n\n") <<< "\n"
    }
  }
}
