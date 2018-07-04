//
//  Commandable.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
//

public protocol Commandable {
    associatedtype ArgumentType: ArgumentRepresentable
    associatedtype OptionType: OptionRepresentable
}
