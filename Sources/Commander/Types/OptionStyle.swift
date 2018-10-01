//
//  OptionStyle.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
//

//public enum OptionStyle {
//    case normal(pattern: String)
//    case short(pattern: String)
//}

public struct OptionStyle: OptionStyleRepresentable {
  public typealias Token = String
  
  public var normalToken: String
  public var shortToken: String
}

extension OptionStyle {
  public static let `default` = OptionStyle(normalToken: "--", shortToken: "-")
}
