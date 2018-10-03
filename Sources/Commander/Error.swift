//
//  Error.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
//

public enum Error: Swift.Error {
  case invalidCommandGiven
  case option(Error.Option)
}

extension Error {
  public enum Option: Swift.Error {
    case invalidPattern(pattern: String, rawValue: String)
    case invalidCountOfArrayLiteral(arrayLiteral: [String])
  }
}
