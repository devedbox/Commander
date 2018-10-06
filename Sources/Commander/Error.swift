//
//  Error.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
//

public enum CommanderError: Swift.Error, CustomStringConvertible {
  case invalidCommand(command: String)
  case emptyCommand
  
  public var description: String {
    switch self {
    case .invalidCommand(command: let command):
      return "Commander Error: Invalid command given: '\(command)'. See 'help' for more information"
    case .emptyCommand:
      return "Commander Error: None of command is given. See 'help' for more information"
    }
  }
}
