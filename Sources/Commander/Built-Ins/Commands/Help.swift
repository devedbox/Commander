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

import Utility

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
    }
    internal static let keys: [Options.CodingKeys: Character] = [.help: "h"]
    /// Returns the description of the options.
    internal static var descriptions: [Options.CodingKeys: OptionDescription] = [
      .help: .usage("Prints the help message of the command. Usage: [[--help|-h][COMMAND --help][COMMAND -h]]")
    ]
    
    internal let help: Bool?
    
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
  }
  /// The resolving command path.
  internal static var path: CommandPath!
  /// The command symbol.
  internal static var symbol: String = "help"
  /// The usage of the command.
  internal static var usage: String = "Prints the help message of the command. Usage: [help [COMMANDS]]"
  /// Try to validate and run the help command if the given options if valid help options.
  internal static func with(
    _ options: [String],
    path: CommandPath?,
    commandLineArgs: [String]) throws
  {
    guard path?.command != self, options.firstIndex(where: { Options.validate($0) }) != nil else {
      throw Error.unrecognizedOptions(options, path: path, underlyingError: nil)
    }
    
    let index = commandLineArgs.firstIndex { OptionsDecoder.optionsFormat.validate($0) }!
    let helpOptions = try OptionsDecoder().decode(Options.self, from: Array(commandLineArgs[index...]))
    guard helpOptions.arguments.isEmpty else {
      throw OptionsDecoder.Error.unrecognizedArguments(helpOptions.arguments)
    }

    self.path = path; defer { self.path = nil }
    try main(helpOptions)
  }
  /// Help the given command symbols for the commander.
  internal static func with(_ symbols: [String]) throws {
    try with(try CommandPath.maxMatches(symbols))
  }
  /// Help the given command paths for the commander.
  internal static func with(_ commandPaths: [CommandPath]) throws {
    (logger ?? BuiltIn.Commander())
      <<< commandPaths.map { CommandDescriber().describe($0) }.joined(separator: "\n\n") <<< "\n"
  }
  /// The main function of the command.
  internal static func main(_ options: Options) throws {
    if options.arguments.isEmpty {
      if let commandPath = self.path {
        logger <<< CommandDescriber().describe(commandPath) <<< "\n"
      } else {
        logger <<< CommandDescriber().describe(CommandPath.running.commander) <<< "\n"
      }
    } else {
      try with(options.arguments)
    }
  }
}
