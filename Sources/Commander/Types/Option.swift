//
//  Option.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
//

import Foundation

let token = "--"

public struct Option: OptionRepresentable {
    
    public typealias RawValue = String
    public typealias Scope = (RawValue, Set<RawValue>)
    
    public typealias ArrayLiteralElement = RawValue
    
    private var _raws: Set<RawValue> = []
    
    public var scopes: [Scope] {
        return _raws.map { ele -> Scope in
            var comps = ele.components(separatedBy: CharacterSet.whitespaces)
            return (comps.remove(at: 0), Set(comps))
        }
    }
    
    public var rawValue: String {
        return _raws.joined(separator: " ")
    }
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        try! self.init(raws: elements)
    }
    
    public init() {
        try! self.init(raws: [])
    }
    
    public init(rawValue: String) {
        let components = rawValue.components(separatedBy: CharacterSet.whitespaces)
        
        let filter: (String) -> Bool = { $0.hasPrefix(token) }
        
        let tokens = components.filter(filter)
        let raws = zip(tokens, components.split(whereSeparator: filter)).map { "\($0) \($1.joined(separator: " "))" }
        
        try! self.init(raws: raws)
    }
    
    public init(raws: [RawValue]) throws {
        let whole = "(--([A-Za-z0-9=]+[- ]?)+)"
        let short = "(-[A-Za-z0-9]+)"
        
        let regexOptions: NSRegularExpression.Options = [.caseInsensitive, .anchorsMatchLines]
        
        let wholeRegex = try NSRegularExpression(pattern: "^\(whole)$", options: regexOptions)
        let shortRegex = try NSRegularExpression(pattern: "^\(short)$", options: regexOptions)
        
        let handledRaws = try raws.map { element -> [Option.RawValue] in
            let wholeMatches = wholeRegex.matches(in: element)
            let shortMatches = shortRegex.matches(in: element)
            
            guard wholeMatches.count + shortMatches.count == 1 else {
                throw CommanderError.option(.invalidPattern(pattern: "^(\(whole)|\(short))$", rawValue: element))
            }
            
            if shortMatches.isEmpty {
                return [element]
            }
            
            return element.unicodeScalars.map { "-" + String($0) }.filter { $0 != "-" }
        }.flatMap { $0 }
        
        
        self._raws = Set(handledRaws)
    }
}

extension Option {
    public mutating func formUnion(_ other: Option) {
        _raws.formUnion(other._raws)
    }
    
    public mutating func formIntersection(_ other: Option) {
        _raws.formIntersection(other._raws)
    }
    
    public mutating func formSymmetricDifference(_ other: Option) {
        _raws.formSymmetricDifference(other._raws)
    }
}
