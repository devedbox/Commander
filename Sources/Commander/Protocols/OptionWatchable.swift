//
//  OptionWatchable.swift
//  Commander
//
//  Created by devedbox on 2018/7/5.
//

import Foundation

public protocol OptionWatchable {
    
    associatedtype OptionType: OptionRepresentable
    
    var option: OptionType { get set }
    
    mutating func watch(_ option: OptionType)
}

extension OptionWatchable {
    public mutating func watch(_ option: OptionType) {
        self.option.formUnion(option)
    }
}
