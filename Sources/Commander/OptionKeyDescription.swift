//
//  OptionKeyDescription.swift
//  Commander
//
//  Created by devedbox on 2018/10/3.
//

// MARK: - OptionKeyDescription.

/// The type represents the description of `Options`. The instances of this type provides the short
/// symbol of the Options and usage description of the Options.
public struct OptionKeyDescription {
  /// Optional short symbol of the `OptionKeyDescription`.
  public let shortSymbol: String?
  /// Required usage description of the `OptionKeyDescription`.
  public let usage: String
  
  /// Returns the instance of `OptionKeyDescription` with short symbol and usage descs.
  ///
  /// - Parameter shortSymbol: The short symbol of the key description.
  /// - Parameter usage: The human-readable usage desctiprion of the key description.
  ///
  /// - Returns: The instance of `OptionKeyDescription` with short symbol and usage.
  public static func short(
    _ shortSymbol: String,
    usage: String) -> OptionKeyDescription
  {
    return OptionKeyDescription(
      shortSymbol: shortSymbol,
      usage: usage
    )
  }
  /// Returns the instance of `OptionKeyDescription` with usage description only.
  ///
  /// - Parameter usage: The human-readable usage desctiprion of the key description.
  ///
  /// - Returns: The instance of `OptionKeyDescription` with usage.
  public static func usage(_ usage: String) -> OptionKeyDescription {
    return OptionKeyDescription(
      shortSymbol: nil,
      usage: usage
    )
  }
}
