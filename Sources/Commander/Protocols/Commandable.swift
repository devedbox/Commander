//
//  Commandable.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
//

public protocol Commandable {
    associatedtype ArgumentType: ArgumentRepresentable
    associatedtype OptionType: OptionRepresentable
    
    var dependencies: [Self] { get }
    func execute()
}

extension Commandable {
    public func execute() {
        dependencies.forEach { $0.execute() }
    }
}
