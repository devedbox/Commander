//
//  OptionDescription.swift
//  Commander
//
//  Created by devedbox on 2018/10/3.
//
//  Copyright (c) 2018 devedbox
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

// MARK: - OptionDescription.

/// The type represents the description of `Options`. The instances of this type provides the short
/// symbol of the Options and usage description of the Options.
public struct OptionDescription {
  /// Optional short symbol of the `OptionKeyDescription`.
  // public let shortSymbol: Character?
  public let defaultValue: Encodable?
  /// Required usage description of the `OptionKeyDescription`.
  public let usage: String
  
  /// Returns the instance of `OptionDescription` with short symbol and usage descs.
  ///
  /// - Parameter shortSymbol: The short symbol of the key description.
  /// - Parameter usage: The human-readable usage desctiprion of the key description.
  ///
  /// - Returns: The instance of `OptionDescription` with short symbol and usage.
  public static func `default`(
    value: Encodable?,
    usage: String) -> OptionDescription
  {
    return OptionDescription(
      defaultValue: value,
      usage: usage
    )
  }
  /// Returns the instance of `OptionDescription` with usage description only.
  ///
  /// - Parameter usage: The human-readable usage desctiprion of the key description.
  ///
  /// - Returns: The instance of `OptionDescription` with usage.
  public static func usage(_ usage: String) -> OptionDescription {
    return OptionDescription(
      defaultValue: nil,
      usage: usage
    )
  }
}
