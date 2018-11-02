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
public struct List: CommandRepresentable {
  public struct Options: OptionsRepresentable {
    public typealias ArgumentsResolver = AnyArgumentsResolver<String>
    public enum CommandType: String, Codable {
      case command
      case options
      case optionsWithShortKeys = "optionsS"
    }
    public enum CodingKeys: String, CodingKeysRepresentable {
      case type
    }
    public static var keys: [CodingKeys: Character] = [:]
    public static var descriptions: [CodingKeys: OptionDescription] = [:]
    
    public let type: CommandType
  }
  
  public static let symbol = "list"
  public static let usage = "List all subcommands or options of given command"
  
  public static func main(_ options: List.Options) throws {
    let arguments = options.arguments
    var path: CommandPath?
    var stdout = FileHandle.standardOutput

    if
      let root = arguments.first,
      let command = CommandPath.runningCommands.first(where: { $0.symbol == root })
    {
      path = CommandPath(running: command, at: CommandPath.runningCommanderPath)
    }
    
    switch options.type {
    case .command:
      if path == nil {
        print(CommandPath.runningCommands.map { $0.symbol }.joined(separator: " "), to: &stdout)
      } else {
        print(path!.command.subcommands.map { $0.symbol }.joined(separator: " "), to: &stdout)
      }
    case .options:
      guard path != nil else {
        break
      }
      print(path!.command.optionsDescriber.allCodingKeys.map { "--\($0)" }.joined(separator: " "), to: &stdout)
    case .optionsWithShortKeys:
      guard path != nil else {
        break
      }
      
      let allCodingKeys = path!.command.optionsDescriber.allCodingKeys
      let allShortKeys = allCodingKeys.compactMap {
        path!.command.optionsDescriber.keys[$0].map { "-" + String($0) }
      }
      
      print((allShortKeys + allCodingKeys.map { "--" + $0 }).joined(separator: " "), to: &stdout)
    }
  }
}
