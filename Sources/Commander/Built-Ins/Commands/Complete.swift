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

import Utility

// MARK: - Help.Options.

extension Help.Options {
  /// Validates and returns the result of given command line indicates if the
  /// command line contains help command's options.
  fileprivate static func validte(_ commandLine: Utility.CommandLine) -> Bool {
    return commandLine.arguments.contains {
      $0 == OptionsDecoder.optionsFormat.format(OptionKeys.help.rawValue) ||
      $0 == OptionsDecoder.optionsFormat.format(String(keys[.help]!), isShort: true)
    }
  }
  /// Filters and excludes the help options from the given container.
  fileprivate static func exclude(from commands: [String]) -> [String] {
    return commands.filter {
      $0 != OptionsDecoder.optionsFormat.format(OptionKeys.help.rawValue) &&
      $0 != OptionsDecoder.optionsFormat.format(String(keys[.help]!), isShort: true)
    }
  }
}

// MARK: - Complete.Generate

extension Complete {
  internal struct Generate: CommandRepresentable {
    internal enum Error: Swift.Error, CustomStringConvertible {
      case fishCompletionIsNotSupportedForNow
      
      var description: String {
        switch self {
        case .fishCompletionIsNotSupportedForNow:
          return "Error: The completions scripts for fish shell is not supported for now"
        }
      }
    }
    
    internal struct Options: OptionsRepresentable, OptionsPropertyWrapper {
      
      @Option(k: "s", usage: "The shell type to gen. Available shell: bash, zsh")
      var shell: Shell = .bash
      
      init() { }
    }
    
    internal static let symbol = "generate"
    internal static let usage = "Generate and print the bash completion script to the standard output"
    
    internal static func main(_ options: Complete.Generate.Options) throws {
      switch options.shell {
      case .bash:
        logger <<< bashCompletion
      case .zsh:
        logger <<< zshCompletion
      case .fish:
        throw Error.fishCompletionIsNotSupportedForNow
      }
    }
  }
}

extension Complete.Generate {
  internal static var bashCompletion: String {
    let commander = CommandPath.running.commanderPath.split(separator: "/").last!
    return """
    #!/bin/bash
    
    _\(commander)() {
      declare -a cur # prev
    
      cur=\"${COMP_WORDS[COMP_CWORD]}\"
      # prev=\"${COMP_WORDS[COMP_CWORD-1]}\"
    
      completions=$(\(CommandPath.running.commanderPath!) complete \"$COMP_LINE\" -s=bash | tr \"\\n\" \" \")
    
      COMPREPLY=( $(compgen -W \"$completions\" -- \"$cur\") )
    }
    
    complete -F _\(commander) \(commander)
    """
  }
  
  internal static var zshCompletion: String {
    let commander = CommandPath.running.commanderPath.split(separator: "/").last!
    return """
    #compdef \(commander)
    
    _\(commander)() {
      local -a comps
      comps=($(\((CommandPath.running.commanderPath!)) complete "$words" | tr \"\\n\" \" \"))
      compadd -a comps
    }
    
    _\(commander)
    """
  }
}

/// The command to generate and provide the completion word list to the bash/zsh completion system.
///
/// - Precondition: The given arguments must be single and the single element(String) must not be empty.
internal struct Complete: CommandRepresentable {
  internal struct Options: OptionsRepresentable, OptionsPropertyWrapper {
    internal typealias Argument = String
    
    @Option(k: "s", usage: "The shell type to complete. Available shell: bash, zsh")
    var shell: Shell = .bash
    
    init() { }
  }
  
  internal static let symbol = "complete"
  internal static let usage = "The built-in command to generate bash-completion wordlist"
  internal static let children: [CommandDispatchable.Type] = [
    Generate.self
  ]
  
  internal static func main(_ options: Complete.Options) throws {
    try options.arguments.isSingle.false { throw Signal.return }
    
    let commandLine = CommandLine(options.arguments.last!)
    let arguments = commandLine.arguments
    try arguments.isEmpty.true { throw Signal.return }
    
    let commands = Array(arguments.dropFirst())
    
    guard
      commands.isEmpty == false,
      let command = CommandPath.running.commands.first(where: { $0.symbol == commands.first! })
    else {
      logger <<< CommandPath.running.commander.completions(for: commandLine).joined(separator: " ") <<< "\n"
      return
    }
    
    // MARK: Built-in 'Help'.
    // If the command is built-in 'help' command, then complete with the first level commands of
    // commander.
    try (commands.first == Help.symbol).true {
      logger <<< CommandPath.running.commands.compactMap { cmd in
        commands.dropFirst().contains(cmd.symbol).or { cmd.symbol == Help.symbol }.false {
          cmd.symbol
        }
      }.joined(separator: " ") <<< "\n"
      throw Signal.return
    }
    // If the command line contains the options of built-in 'help' command's options, then complete
    // with empty list.
    try Help.Options.validte(commandLine).true { throw Signal.return }
    
    // MARK: CommandPath.
    
    let path = try CommandPath(running: command, at: CommandPath.running.commanderPath).run(
      with: Array(commands.dropFirst()),
      skipping: true
    )
    
    // The options validator to validates the given string is options or not.
    let optionsValidate = OptionsDecoder.optionsFormat.validate
    
    // MARK: Options Completion.
    // If the command line contains options, then
    try commands.filter { optionsValidate($0) }.isEmpty.false {
      // If the last command line arg is not options, then
      try optionsValidate(commands.last!).false {
        // If the type of 'options' can resolve arguments, then
        // path.command.optionsDescriber.isArgumentsResolvable.true {
          // Complete the options with 'optionsDescriber.completions(for:)'.
          logger <<< path.command.optionsDescriber.completions(for: commandLine).joined(separator: " ") <<< "\n"
        // }
        // Returns.
        throw Signal.return
      }
    }
    
    // MARK: Commands Completion.
    // Completes the commands with 'command.completions(for:)'.
    var completions = path.command.completions(for: commandLine)
    // If the last arg is not an options, and
    optionsValidate(commands.last!).and {
      // If the commands contains options, then
      !commands.dropLast().filter { optionsValidate($0) }.isEmpty
    }.true {
      // Excludes the built-in 'help' command's options.
      completions = Help.Options.exclude(from: completions)
    }
    
    logger <<< completions.joined(separator: " ") <<< "\n"
  }
}
