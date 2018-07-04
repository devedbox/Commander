//
//  Option.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
//

import Foundation

public struct Option: OptionRepresentable {
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        try! self.init(optionRaws: elements)
    }
    
    public init(optionRaws: [ArrayLiteralElement]) throws {
        var optionRaws = optionRaws
        try self.init(option: optionRaws.remove(at: 0), scopes: optionRaws)
    }
    
    public typealias RawValue = String
    public typealias Scope = RawValue
    
    public typealias ArrayLiteralElement = RawValue
    
    public let option: ArrayLiteralElement
    public let scopes: [RawValue]
    
    init(option: RawValue, scopes: [Scope] = []) throws {
        self.option = option
        self.scopes = scopes
        
        guard !style.regex!.matches(in: option).isEmpty
            , scopes.filter({ !style.regex!.matches(in: $0).isEmpty }).isEmpty
        else {
            throw CommanderError.option(.invalidPattern(pattern: style.regex!.pattern,
                                                        rawValue: "\(option) \(scopes.joined(separator: " "))"))
        }
    }
}
