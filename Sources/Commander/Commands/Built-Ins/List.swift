//
//  List.swift
//  Commander
//
//  Created by devedbox on 2018/11/2.
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

/// The built-in command to list all the subcommands and options info of the given parameter
/// and given command name.
internal struct List: CommandRepresentable {
  internal struct Options: OptionsRepresentable {
    internal typealias ArgumentsResolver = AnyArgumentsResolver<String>
    internal enum CommandType: String, Codable {
      case command // List subcommands, and then list the options.
      case options // List the options only.
      case optionsWithShortKeys = "optionsS"
    }
    internal enum CodingKeys: String, CodingKeysRepresentable {
      case type
    }
    internal static var keys: [CodingKeys: Character] = [:]
    internal static var descriptions: [CodingKeys: OptionDescription] = [:]
    
    internal let type: CommandType
  }
  
  internal static let symbol = "list"
  internal static let usage = "List all subcommands or options of given command"
  
  internal static func main(_ options: List.Options) throws {
    let arguments = options.arguments
    var path: CommandPath?

    if
      let root = arguments.first,
      let command = CommandPath.runningCommands.first(where: { $0.symbol == root })
    {
      path = try CommandPath(
        running: command,
        at: CommandPath.runningCommanderPath
      ).run(
        with: Array(arguments.dropFirst()),
        ignoresExecution: true
      )
    }
    
    var throughCommand = false
    
    switch options.type {
    case .command:
      if path == nil {
        logger <<< CommandPath.runningCommands.map { $0.symbol }.joined(separator: " ")
      } else {
        logger <<< path!.command.subcommands.map { $0.symbol }.joined(separator: " ")
      }
      
      throughCommand = true; fallthrough
    case .optionsWithShortKeys:
      guard path != nil else {
        break
      }
      
      let allCodingKeys = path!.command.optionsDescriber.allCodingKeys
      let allShortKeys = allCodingKeys.compactMap {
        path!.command.optionsDescriber.keys[$0].map { "-" + String($0) }
      }
      logger <<< (path?.command.subcommands.isEmpty ?? CommandPath.runningCommands.isEmpty || !throughCommand ? "" : " ")
      logger <<< (allShortKeys + allCodingKeys.map { "--" + $0 }).joined(separator: " ")
    case .options:
      guard path != nil else {
        break
      }
      logger <<< path!.command.optionsDescriber.allCodingKeys.map { "--\($0)" }.joined(separator: " ")
    }
  }
}
