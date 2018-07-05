//
//  InOutStreamable.swift
//  Commander
//
//  Created by devedbox on 2018/7/5.
//

import Foundation

public protocol InOutStreamable {
    associatedtype Input
    associatedtype Output
    
    var piper: (@autoclosure () -> Input) -> Output? { get }
    func pipe(input: Input) -> Output?
}

extension InOutStreamable {
    public func pipe(input: Input) -> Output? {
        return piper(input)
    }
}
