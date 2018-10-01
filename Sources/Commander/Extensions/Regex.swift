//
//  Regex.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
//

import Foundation

extension NSRegularExpression {
  public func matches(in string: String, options: MatchingOptions = [.anchored]) -> [NSTextCheckingResult] {
    return matches(in: string, options: options, range: (string as NSString).range(of: string))
  }
}
