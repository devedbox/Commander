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
      case shell
      case help = "with-help"
    }
    internal static var keys: [CodingKeys: Character] = [
      .type: "t",
      .shell: "s"
    ]
    internal static var descriptions: [CodingKeys: OptionDescription] = [
      .type: .usage("The type to list. Available types: 'command', 'options' and 'optionsS'"),
      .shell: .default(value: "bash", usage: "The shell type to list. Available shell: 'bash', 'zsh'"),
      .help: .default(value: true, usage: "Should list alongwith help options")
    ]
    
    internal let type: CommandType
    internal let help: Bool
    internal let shell: Shell
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
      switch options.shell {
      case .bash, .zsh:
        if path == nil {
          logger <<< CommandPath.runningCommands.map { $0.symbol }.joined(separator: " ")
        } else {
          logger <<< path!.command.subcommands.map { $0.symbol }.joined(separator: " ")
        }
        /*
      case .zsh:
        if path == nil {
          logger <<< CommandPath.runningCommands.map {
            "\($0.symbol):\($0.usage.replacingOccurrences(of: ":", with: "\\:"))"
          }.joined(separator: "\n")
        } else {
          logger <<< path!.command.subcommands.map {
            "\($0.symbol):\($0.usage.replacingOccurrences(of: ":", with: "\\:"))"
          }.joined(separator: "\n")
        }
         */
      }
      
      throughCommand = true; fallthrough
    case .optionsWithShortKeys:
      var opts: [String]
      var sopts: [String]
      
      switch OptionsDecoder.optionsFormat {
      case .format(let symbol, short: let short):
        switch options.shell {
        case .bash, .zsh:
          opts = path?.command.optionsDescriber.descriptions.map {
            "\(symbol)\($0.key)"
          } ?? []
          
          sopts = path?.command.optionsDescriber.descriptions.compactMap { desc in
            path!.command.optionsDescriber.keys[desc.key].map { "\(short)\($0)" }
          } ?? []
          
          if options.help {
            opts += [
              "\(symbol)\((BuiltIn.help as! Help.Type).Options.CodingKeys.help)"
            ]
            sopts += [
              "\(short)\((BuiltIn.help as! Help.Type).Options.keys[.help]!)"
            ]
          }
          
          logger <<< (path?.command.subcommands.isEmpty ?? CommandPath.runningCommands.isEmpty || !throughCommand ? "" : " ")
          logger <<< (sopts + opts).joined(separator: " ") <<< "\n"
          /*
        case .zsh:
          opts = path!.command.optionsDescriber.descriptions.map {
            "\(symbol)\($0.key):\($0.value.usage.replacingOccurrences(of: ":", with: "\\:"))"
          }
          sopts = path!.command.optionsDescriber.descriptions.compactMap { desc in
            path!.command.optionsDescriber.keys[desc.key].map {
              "\(short)\($0):\(desc.value.usage.replacingOccurrences(of: ":", with: "\\:"))"
            }
          }
          
          logger <<< (path?.command.subcommands.isEmpty ?? CommandPath.runningCommands.isEmpty || !throughCommand ? "" : "\n")
          logger <<< (sopts + opts).joined(separator: "\n") <<< "\n"
         */
        }
      }
    case .options:
      switch OptionsDecoder.optionsFormat {
      case .format(let symbol, short: _):
        switch options.shell {
        case .bash, .zsh:
          var opts = path?.command.optionsDescriber.descriptions.keys.map {
            "\(symbol)\($0)"
          } ?? []
          
          if options.help {
            opts += [
              "\(symbol)\((BuiltIn.help as! Help.Type).Options.CodingKeys.help)"
            ]
          }
          
          logger <<< opts.joined(separator: " ") <<< "\n"
          /*
        case .zsh:
          logger <<< path!.command.optionsDescriber.descriptions.map {
            "\(symbol)\($0.key):\($0.value.usage.replacingOccurrences(of: ":", with: "\\:"))"
          }.joined(separator: "\n") <<< "\n"
         */
        }
      }
    }
  }
}
