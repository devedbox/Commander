//
//  ArgumentWatchable.swift
//  Commander
//
//  Created by devedbox on 2018/7/5.
//

import Foundation

public protocol ArgumentWatchable {
  
  associatedtype ArgumentType: ArgumentRepresentable
  
  var arguments: [ArgumentType] { get set }
  
  mutating func watch(_ argument: ArgumentType)
}

extension ArgumentWatchable {
  public mutating func watch(_ argument: ArgumentType) {
    self.arguments.append(argument)
  }
}
