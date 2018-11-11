//
//  Error.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
//
//  Copyright (c) 2018 devedbox
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

// MARK: - Return.

/// The error type represents the error is a common signal and can be handled.
public enum Signal: Swift.Error {
  /// Case 'return' indicates the 'return' signal.
  case `return`
}

// MARK: - CommanderError.

public enum CommanderError: Swift.Error, CustomStringConvertible {
  case invalidCommand(command: String)
  case emptyCommand
  case unrecognizedCommands(commands: [String])
  case extraOptions(options: [String])
  case unrecognizedOptions([String], path: CommandPath, underlyingError: Swift.Error?)
  
  public var description: String {
    switch self {
    case .invalidCommand(command: let command):
      return "Invalid command given error: '\(command)'. See 'help' for more information."
    case .emptyCommand:
      return "None of command is given. See 'help' for more information."
    case .unrecognizedCommands(commands: let commands):
      return "Unrecognized command error: '\(commands.joined(separator: " "))'."
    case .extraOptions(options: let options):
      return "Invalid help options format error: Expecting 'help' or 'h' alone but giving '\(options.joined(separator: " "))'."
    case .unrecognizedOptions(let options, let path, underlyingError: _):
      return "Unrecognized options for command '\(path.command.symbol)': '\(options.joined(separator: " "))'."
    }
  }
}
