//
//  CommanderError.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
//

public enum CommanderError: Error {
    case option(CommanderError.Option)
}

extension CommanderError {
    public enum Option: Error {
        case invalidPattern(pattern: String, rawValue: String)
        case invalidCountOfArrayLiteral(arrayLiteral: [String])
    }
}
