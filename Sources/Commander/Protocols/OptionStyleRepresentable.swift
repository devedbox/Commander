//
//  OptionStyleRepresentable.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
//

import Foundation

public protocol OptionStyleRepresentable: RegularExpressionConvertible {
    associatedtype Token: StringProtocol
    var normalToken: Token { get }
    var shortToken: Token { get }
}

extension OptionStyleRepresentable where RegularExpression == NSRegularExpression {
    public func asRegex() throws -> RegularExpression {
        return try RegularExpression(pattern: "^((\(normalToken)([A-Za-z0-9]+-?)+)|(\(shortToken)[A-Za-z0-9]+))$", options: [.caseInsensitive, .anchorsMatchLines])
    }
}
