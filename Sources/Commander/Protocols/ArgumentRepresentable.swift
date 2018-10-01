//
//  ArgumentRepresentable.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
//

import Foundation

public enum State {
  case failure(error: Error)
  case pending(option: Option)
  case success
}

public protocol StateRepresentable {
  
}

public protocol ArgumentRepresentable: OptionWatchable {
  associatedtype ResultType
  associatedtype State: StateRepresentable
  
  mutating func prepare()
  mutating func filter(_ option: OptionType)
  mutating func final()
}

extension ArgumentRepresentable {
  public mutating func filter(_ option: OptionType) {
    
  }
}
