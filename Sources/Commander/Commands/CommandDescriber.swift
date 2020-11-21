//
//  CommandDescriber.swift
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

// MARK: - CommandDescriber.

internal struct CommandDescriber {
  private let intents: Int
  
  internal init(intents: Int = 0) {
    self.intents = intents
  }
  
  internal func describe(_ commandPath: CommandPath) -> String {
    return self.describe(
      commandPath.command,
      path: commandPath.paths.joined(separator: " "),
      usagePath: (commandPath.paths.dropFirst() + [commandPath.command.symbol]).joined(separator: " ")
    )
  }
  
  internal func describe(_ command: CommandDescribable.Type, path: String = "", usagePath: String? = nil) -> String {
    let optionsFormat: (symbol: String, short: String) = (
      OptionsDecoder.optionsFormat.symbol,
      OptionsDecoder.optionsFormat.shortSymbol
    )
    
    let subcommandSymbols = command.childrenDescribers.map { ($0.symbol, $0.usage) }
    let optionsSymbols = command
      .optionsDescriber
      .stringDescriptions
      .sorted { $0.key < $1.key }
      .map { desc -> (String, String) in
        let shortKey = command.optionsDescriber.stringKeys[desc.key]
        let keyDesc = (shortKey.map { "\(optionsFormat.short)\($0), " } ?? "") + "\(optionsFormat.symbol)\(desc.key)"
        
        var usage = desc.value.usage
        if let defaultValue = desc.value.defaultValue {
          let separator = usage.hasSuffix(".") ? "" : "."
          usage += separator + " Optional with default value: '\(defaultValue)'"
        }
        
        return (keyDesc, usage)
      }
    
    let argumentsSymbols: [(String, String)] = command.optionsDescriber.isArgumentsResolvable == false ? [] : [
      ("[\(String(describing: command.optionsDescriber.argumentType))]", "\(path) \(command.symbol) [options] arg1 arg2 ...")
    ]
    
    let count = (subcommandSymbols + optionsSymbols + argumentsSymbols).reduce(0) {
      return max($0, $1.0.count)
    }
    let alignment = String(repeating: " ", count: count)
    
    let subcommandsDesc = command.level == .commander ? "[COMMAND]" : " [SUBCOMMAND]"
    
    let subcommandsSummary = subcommandSymbols.isEmpty ? "" : "\(subcommandsDesc)"
    let optionsSummary = optionsSymbols.isEmpty ? "" : " [OPTIONS]"
    let argumentsSummary = command.optionsDescriber.isArgumentsResolvable ? " [ARGUMENTS]" : ""
    
    let subcommandsLabel = subcommandSymbols.isEmpty ? "" : """
    \(returns(1))
    \(intents(1))\(command.level == .commander ? "Commands" : "Subcommands"):
    \(returns(0))
    """
    let optionsLabel = optionsSymbols.isEmpty ? "" : """
    \(returns(1))
    \(intents(1))Options:
    \(returns(0))
    """
    let argumentsLabel = command.optionsDescriber.isArgumentsResolvable == false ? "" : """
    \(returns(1))
    \(intents(1))Arguments:
    \(returns(0))
    """
    
    let subcommandsOutputs = subcommandsLabel.isEmpty ? "" : """
    \(subcommandsLabel)
    \(subcommandSymbols.map { intents(2) + $0.0.merging(alignment) + intents(1) + $0.1 }.joined(separator: "\n"))
    """
    
    let optionsOutputs = optionsLabel.isEmpty ? "" : """
    \(optionsLabel)
    \(optionsSymbols.map    { intents(2) + $0.0.merging(alignment) + intents(1) + $0.1 }.joined(separator: "\n"))
    """
    
    let argumentsOutputs = argumentsLabel.isEmpty ? "" : """
    \(argumentsLabel)
    \(argumentsSymbols.map  { intents(2) + $0.0.merging(alignment) + intents(1) + $0.1 }.joined(separator: "\n"))
    """
    
    return """
    \(intents(0))Usage\(command.level == .commander ? "" : " of '\(usagePath ?? command.symbol)'"):
    \(returns(0))
    \(intents(1))$ \(path) \(command.symbol)\(subcommandsSummary)\(optionsSummary)\(argumentsSummary)\(returns(1))
    \(intents(2))\(command.usage)\(subcommandsOutputs)\(optionsOutputs)\(argumentsOutputs)
    """
  }
}

extension CommandDescriber {
  private func intents(_ level: Int) -> String {
    return String(repeating: " ", count: 2 * (level + intents))
  }
  
  private func returns(_ level: Int, basis: Int? = 0) -> String {
    return String(repeating: "\n", count: max(0, (level - intents)))
  }
}
