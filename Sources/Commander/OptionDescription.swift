//
//  OptionDescription.swift
//  Commander
//
//  Created by devedbox on 2018/10/3.
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
