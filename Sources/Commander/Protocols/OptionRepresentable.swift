//
//  OptionRepresentable.swift
//  Commander
//
//  Created by devedbox on 2018/7/4.
//

import Foundation

public protocol OptionRepresentable: OptionSet where RawValue: Hashable {
  /// Type of the scope of the option.
  associatedtype Scope = (RawValue, Set<RawValue>)
  /// Type of the style of the option.
  associatedtype OptionStyleType: OptionStyleRepresentable = OptionStyle
  /// The style of options of `OptionStyle`. Default would be `--option` as normal and `-o` as short.
  var style: OptionStyleType { get }
  /// Represents the option scope of the option.
  ///
  /// A simplest option would be like `--option` or `-o`, but for a complex option can be complex such as
  /// `--option someoptionValue` or `--option someKey1=someValue1 someKey2=someValue2`.
  var scopes: [Scope] { get }
}

extension OptionRepresentable where Self.OptionStyleType == OptionStyle {
  /// The style of options of `OptionStyle`. Default would be `--option` as normal and `-o` as short.
  public var style: OptionStyleType {
    return .default
  }
}
