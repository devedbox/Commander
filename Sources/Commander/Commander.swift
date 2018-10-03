//
//  Commander.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
//

#if os(Linux)
import Glibc
#else
import Darwin
#endif

import Foundation

public final class Commander {
  public static var commands: [AnyCommandRepresentable.Type] = []
  
  public init() { }
  
  public func dispatch() throws {
    var commands = CommandLine.arguments.dropFirst()
    let symbol = commands.popFirst()
    let command = type(of: self).commands.first {
      $0.symbol == symbol
    }
    
    guard command != nil else {
      throw Error.invalidCommandGiven
    }
    
    try command!.run(with: [String](commands))
    dispatchMain()
  }
}
