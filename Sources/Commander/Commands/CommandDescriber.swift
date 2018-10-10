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

import Foundation

extension String {
  internal func merging(_ other: String) -> String {
    var merging: String
    let merged: String
    
    if self.endIndex > other.endIndex {
      merging = self; merged = other
    } else {
      merging = other; merged = self
    }
    
    merging.replaceSubrange(merged.startIndex..<merged.endIndex, with: merged)
    return merging
  }
}

internal struct CommandDescriber {
  private let intents: Int
  
  internal init(intents: Int = 0) {
    self.intents = intents
  }
  
  internal func describe(_ commander: Commander.Type) -> String {
    let path = Commander.runningPath.split(separator: "/").last!
    
    let commandsSymbols = commander.allCommands.map { ($0.symbol, $0.usage) }
    
    let count = commandsSymbols.reduce(0) { max($0, $1.0.count) }
    let alignment = String(repeating: " ", count: count)
    
    return """
    Usage:
    \(returns(0))
    \(intents(1))$ \(path) COMMAND
    \(returns(0))
    \(intents(2))\(Commander.usage)
    \(returns(0))
    Commands:
    \(returns(0))
    \(commandsSymbols.map { intents(2) + $0.0.merging(alignment) + intents(1) + $0.1 }.joined(separator: "\n"))
    """
  }
  
  internal func describe(_ command: AnyCommandRepresentable.Type) -> String {
    // var sample = String(repeating: " ", count: path.count + 1 + commandSymbols.reduce(0) { max($0, $1.count) })
    let path = String(Commander.runningPath.split(separator: "/").last!)
    
    let subcommandSymbols = command.subcommands.map { ($0.symbol, $0.usage) }
    let optionsSymbols = command.optionsDescriber.descriptions.map { desc -> (String, String) in
      let shortKey = command.optionsDescriber.keys[desc.key]
      let keyDesc = (shortKey.map { "-\($0), " } ?? "") + "--\(desc.key)"
      return (keyDesc, desc.value.usage)
    }
    let argumentsSymbols: [(String, String)] = command.optionsDescriber.isArgumentsResolvable == false ? [] : [
      ("[\(String(describing: command.optionsDescriber.argumentType))]", "\(path) \(command.symbol) [options] arg1 arg2 ...")
    ]
    
    let count = (subcommandSymbols + optionsSymbols + argumentsSymbols).reduce(0) {
      return max($0, $1.0.count)
    }
    let alignment = String(repeating: " ", count: count)
    
    let subcommandsSummary = subcommandSymbols.isEmpty ? "" : " [SUBCOMMANDS]"
    let optionsSummary = optionsSymbols.isEmpty ? "" : " [OPTIONS]"
    let argumentsSummary = command.optionsDescriber.isArgumentsResolvable ? " [ARGUMENTS]" : ""
    
    let subcommandsLabel = subcommandSymbols.isEmpty ? "" : """
    \(returns(1))
    \(intents(1))Subcommands:
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
    \(intents(0))Usage of '\(command.symbol)':
    \(returns(0))
    \(intents(1))$ \(path) \(command.symbol) \(subcommandsSummary)\(optionsSummary)\(argumentsSummary)\(returns(1))
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
