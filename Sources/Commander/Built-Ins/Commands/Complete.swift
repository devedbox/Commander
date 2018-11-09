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
import Utility

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
    try options.arguments.isSingle.false { throw ReturnError() }
    
    let commandLine = CommandLine(options.arguments.last!)
    let arguments = commandLine.arguments
    try arguments.isEmpty.true { throw ReturnError() }
    
    let commands = Array(arguments.dropFirst())
    
    guard
      commands.isEmpty == false,
      let command = CommandPath.runningCommands.first(where: { $0.symbol == commands.first! })
    else {
      logger <<< CommandPath.runningCommander.completions(for: commandLine).joined(separator: " ") <<< "\n"
      return
    }
    
    // Make an exception for 'help' command.
    try (commands.first == Help.symbol).true {
      logger <<< CommandPath.runningCommands.compactMap { cmd in
        return commands.dropFirst().contains(cmd.symbol).or {
          cmd.symbol == Help.symbol
        }.false {
          cmd.symbol
        }
      }.joined(separator: " ") <<< "\n"
      throw ReturnError()
    }
    
    let help = OptionsDecoder.optionsFormat.format(Help.Options.CodingKeys.help.rawValue)
    let h = OptionsDecoder.optionsFormat.format(String(Help.Options.keys[.help]!), isShort: true)
    
    try arguments.contains(help).or {
      arguments.contains(h)
    }.true {
      throw ReturnError()
    }
    
    let path = try CommandPath(
      running: command,
      at: CommandPath.runningCommanderPath
    ).run(
      with: Array(commands.dropFirst()),
      ignoresExecution: true
    )
    
    let optionsValidate = OptionsDecoder.optionsFormat.validate
    
    try commands.filter { optionsValidate($0) }.isEmpty.false {
      try optionsValidate(commands.last!).false {
        path.command.optionsDescriber.isArgumentsResolvable.true {
          logger <<< path.command.optionsDescriber.completions(for: commandLine).joined(separator: " ") <<< "\n"
        }
        throw ReturnError()
      }
    }
    
    var completions = path.command.completions(for: commandLine)
    
    optionsValidate(commands.last!).and {
      !commands.dropLast().filter { optionsValidate($0) }.isEmpty
    }.true {
      completions = completions.filter {
        !($0 == help || $0 == h)
      }
    }
    
    logger <<< completions.joined(separator: " ") <<< "\n"
  }
}
