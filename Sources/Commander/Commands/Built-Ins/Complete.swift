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
      internal enum ShellMode: String, Codable {
        case bash
      }
      
      internal enum CodingKeys: String, CodingKeysRepresentable {
        case mode
      }
      
      internal static var keys: [CodingKeys: Character] = [:]
      internal static var descriptions: [CodingKeys: OptionDescription] = [:]
      
      internal let mode: ShellMode
    }
    
    internal static let symbol = "generate"
    internal static let usage = "Generate and print the bash completion script to the standard output"
    
    internal static func main(_ options: Complete.Generate.Options) throws {
      switch options.mode {
      case .bash:
        logger <<< bashCompletion
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
    
      completions=$(\(CommandPath.runningCommanderPath!) complete \"$COMP_LINE\" | tr \"\\n\" \" \")
    
      COMPREPLY=( $(compgen -W \"$completions\" -- \"$cur\") )
    }
    
    complete -F _\(commander) \(commander)
    """
  }
}

/// The command to add bash-completion scripts of the commander
internal struct Complete: CommandRepresentable {
  internal struct Options: OptionsRepresentable {
    internal typealias ArgumentsResolver = AnyArgumentsResolver<String>
    
    internal enum CodingKeys: String, CodingKeysRepresentable {
      case none
    }
    
    internal static var keys: [CodingKeys: Character] = [:]
    internal static var descriptions: [CodingKeys: OptionDescription] = [:]
    
    internal let none: Bool?
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
    let commands = Array(arguments.dropFirst())
    var path: CommandPath?
    
    if
      let root = commands.first,
      let command = CommandPath.runningCommands.first(where: { $0.symbol == root })
    {
      path = try CommandPath(
        running: command,
        at: CommandPath.runningCommanderPath
      ).run(
        with: Array(commands.dropFirst()),
        ignoresExecution: true
      )
    }
    
    guard arguments.isEmpty == false else {
      return
    }
    
    if arguments.isSingle { // Consider a commander.
      try List.main(.init(type: .command))
    } else { // Complete according to the last arg.
      let last = commands.last!
      
      switch OptionsDecoder.optionsFormat {
      case .format(let symbol, short: let shortSymbol):
        var listOptions: List.Options
        
        switch last {
        case let arg where arg.hasPrefix(symbol):
          if
            let commandPath = path,
            commandPath.command.optionsDescriber.allCodingKeys.map({ "\(symbol)\($0)" }).contains(arg)
          {
            return
          }
          
          listOptions = List.Options(type: .options)
          listOptions.arguments = Array(commands.dropLast())
        case let arg where arg.hasPrefix(shortSymbol):
          if
            let commandPath = path,
            commandPath.command.optionsDescriber.keys.values.map({ "\(shortSymbol)\($0)" }).contains(arg)
          {
            return
          }
          
          listOptions = List.Options(type: .optionsWithShortKeys)
          listOptions.arguments = Array(commands.dropLast())
        default:
          guard commands.filter({ $0.hasPrefix(symbol) || $0.hasPrefix(shortSymbol) }).isEmpty else {
            return
          }
          
          listOptions = List.Options(type: .command)
          listOptions.arguments = commands
        }
        
        try List.main(listOptions)
      }
    }
  }
}
