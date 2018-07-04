//
//  RegularExpressionConvertible.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
//

import Foundation

// MARK: - RegularExpressionConvertible.

public protocol RegularExpressionConvertible {
    associatedtype RegularExpression: NSRegularExpression = NSRegularExpression
    
    func asRegex() throws -> RegularExpression
}

extension RegularExpressionConvertible {
    public var regex: RegularExpression? {
        return try? asRegex()
    }
}
