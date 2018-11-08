//
//  Complete.swift
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

// MARK: - Complete.Generate

extension Complete {
  internal struct Generate: CommandRepresentable {
    internal struct Options: OptionsRepresentable {
      internal enum CodingKeys: String, CodingKeysRepresentable {
        case shell
      }
      
      internal static var keys: [CodingKeys: Character] = [.shell: "s"]
      internal static var descriptions: [CodingKeys: OptionDescription] = [
        .shell: .default(value: "bash", usage: "The shell type to gen. Available shell: bash, zsh")
      ]
      
      internal let shell: Shell
    }
    
    internal static let symbol = "generate"
    internal static let usage = "Generate and print the bash completion script to the standard output"
    
    internal static func main(_ options: Complete.Generate.Options) throws {
      switch options.shell {
      case .bash:
        logger <<< bashCompletion
      case .zsh:
        logger <<< zshCompletion
      }
    }
  }
}

extension Complete.Generate {
  internal static var bashCompletion: String {
    let commander = CommandPath.runningCommanderPath.split(separator: "/").last!
    return """
    #!/bin/bash
    
    _\(commander)() {
      declare -a cur # prev
    
      cur=\"${COMP_WORDS[COMP_CWORD]}\"
      # prev=\"${COMP_WORDS[COMP_CWORD-1]}\"
    
      completions=$(\(CommandPath.runningCommanderPath!) complete \"$COMP_LINE\" -s=bash | tr \"\\n\" \" \")
    
      COMPREPLY=( $(compgen -W \"$completions\" -- \"$cur\") )
    }
    
    complete -F _\(commander) \(commander)
    """
  }
  
  internal static var zshCompletion: String {
    let commander = CommandPath.runningCommanderPath.split(separator: "/").last!
    return """
    #compdef \(commander)
    
    _\(commander)() {
      local -a comps
      comps=($(\((CommandPath.runningCommanderPath!)) complete "$words" | tr \"\\n\" \" \"))
      compadd -a comps
    }
    
    _\(commander)
    """
  }
}

/// The command to add bash-completion scripts of the commander
internal struct Complete: CommandRepresentable {
  internal struct Options: OptionsRepresentable {
    internal typealias ArgumentsResolver = AnyArgumentsResolver<String>
    
    internal enum CodingKeys: String, CodingKeysRepresentable {
      case shell
    }
    
    internal static var keys: [CodingKeys: Character] = [.shell: "s"]
    internal static var descriptions: [CodingKeys: OptionDescription] = [
      .shell: .default(value: "bash", usage: "The shell type to complete. Available shell: bash, zsh")
    ]
    
    internal let shell: Shell
  }
  
  internal static let symbol = "complete"
  internal static let usage = "The built-in command to generate bash-completion wordlist"
  internal static let subcommands: [AnyCommandRepresentable.Type] = [
    Generate.self
  ]
  
  internal static func main(_ options: Complete.Options) throws {
    guard options.arguments.isSingle else {
      return
    }
    
    let arguments = options.arguments.last!.split(separator: " ").map { String($0) }
    
    guard arguments.isEmpty == false else {
      return
    }
    
    let commands = Array(arguments.dropFirst())
    
    guard
      commands.isEmpty == false,
      let command = CommandPath.runningCommands.first(where: { $0.symbol == commands.first! })
    else {
      logger <<< CommandPath.runningCommander.completions(for: "").joined(separator: " ") <<< "\n"
      return
    }
    
    // Make an exception for 'help' command.
    if commands.first == Help.symbol {
      let args = Array(commands.dropFirst())
      
      logger <<< CommandPath.runningCommands.compactMap {
        !(args.contains($0.symbol) || $0.symbol == Help.symbol) ? $0.symbol : nil
        }.joined(separator: " ") <<< "\n"
      
      return
    }
    
    let help = OptionsDecoder.optionsFormat.symbol + Help.Options.CodingKeys.help.rawValue
    let h = OptionsDecoder.optionsFormat.shortSymbol + String(Help.Options.keys[.help]!)
    
    if
      arguments.contains(help)
   || arguments.contains(h)
    {
      return
    }
    
    if
      !commands.last!.hasPrefix(OptionsDecoder.optionsFormat.symbol),
      !commands.last!.hasPrefix(OptionsDecoder.optionsFormat.shortSymbol),
      !commands.filter({ $0.hasPrefix(OptionsDecoder.optionsFormat.symbol) || $0.hasPrefix(OptionsDecoder.optionsFormat.shortSymbol) }).isEmpty
    {
      return
    }
    
    let path = try CommandPath(
      running: command,
      at: CommandPath.runningCommanderPath
    ).run(
      with: Array(commands.dropFirst()),
      ignoresExecution: true
    )
    
    var completions = path.command.completions(for: commands.last!)
    
    if !commands.filter({ $0.hasPrefix(OptionsDecoder.optionsFormat.symbol) || $0.hasPrefix(OptionsDecoder.optionsFormat.shortSymbol) }).isEmpty {
      completions = completions.filter {
        !($0 == help || $0 == h)
      }
    }
    
    logger <<< completions.joined(separator: " ") <<< "\n"
//
//    return
//
//    guard arguments.isEmpty == false else {
//      return
//    }
//
//    if arguments.isSingle { // Consider a commander.
//      logger <<< CommandPath.runningCommander.completions(for: "").joined(separator: " ") <<< "\n"
//    } else { // Complete according to the last arg.
//      let last = commands.last!
//
//      // Make an exception for 'help' command.
//      if commands.first == Help.symbol {
//        let args = Array(commands.dropFirst())
//
//        logger <<< CommandPath.runningCommands.compactMap {
//            !(args.contains($0.symbol) || $0.symbol == Help.symbol) ? $0.symbol : nil
//        }.joined(separator: " ") <<< "\n"
//
//        return
//      }
//
//      switch OptionsDecoder.optionsFormat {
//      case .format(let symbol, short: let short):
//        if
//          arguments.contains("\(short)\(Help.Options.keys[.help]!)")
//       || arguments.contains("\(symbol)\(Help.Options.CodingKeys.help.rawValue)")
//        {
//          return
//        }
//
//        _ = path.map {
//          logger <<< $0.command.completions(for: last).joined(separator: " ") <<< "\n"
//        }
//
//        return
//
//        var listOptions: List.Options
//
//        switch last {
//        case let arg where arg.hasPrefix(symbol):
//          if
//            case let commandPath? = path,
//            commandPath.command.optionsDescriber.allCodingKeys.map({ "\(symbol)\($0)" }).contains(arg)
//          {
//            return
//          }
//
//          if commands.dropLast().filter({ $0.hasPrefix(symbol) || $0.hasPrefix(short) }).isEmpty {
//            listOptions = List.Options(type: .options, help: true, shell: options.shell)
//          } else {
//            listOptions = List.Options(type: .options, help: false, shell: options.shell)
//          }
//
//          listOptions.arguments = Array(commands.dropLast())
//        case let arg where arg.hasPrefix(short):
//          if
//            case let commandPath? = path,
//            commandPath.command.optionsDescriber.keys.values.map({ "\(short)\($0)" }).contains(arg)
//          {
//            return
//          }
//
//          if commands.dropLast().filter({ $0.hasPrefix(symbol) || $0.hasPrefix(short) }).isEmpty {
//            listOptions = List.Options(type: .optionsWithShortKeys, help: true, shell: options.shell)
//          } else {
//            listOptions = List.Options(type: .optionsWithShortKeys, help: false, shell: options.shell)
//          }
//
//          listOptions.arguments = Array(commands.dropLast())
//        default:
//          guard commands.filter({ $0.hasPrefix(symbol) || $0.hasPrefix(short) }).isEmpty else {
//            return
//          }
//
//          listOptions = List.Options(type: .command, help: true, shell: options.shell)
//          listOptions.arguments = commands
//        }
//
//        try List.main(listOptions)
//      }
//    }
  }
}
