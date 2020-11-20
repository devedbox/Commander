//
//  DefaultOptions.swift
//  Commander
//
//  Created by devedbox on 2020/11/18.
//

// MARK: - DefaultOptions.

public enum DefaultOptions {
  // MARK: - EmptyOptionKeys.
  
  /// The coding key type of `CodingKey & StringRawRepresentable` for decoding.
  public struct EmptyOptionKeys: OptionKeysRepresentable {
    /// A type that can represent a collection of all values of this type.
    public typealias AllCases = [EmptyOptionKeys]
    /// A collection of all values of this type.
    public static var allCases: [EmptyOptionKeys] = []
    /// The string to use in a named collection (e.g. a string-keyed dictionary).
    public var stringValue: String
    /// Creates the instance with string value.
    public init?(rawValue: String) { self.stringValue = rawValue }
  }
  
  // MARK: - None.
  
  /// The concrete type conforms `NoneOptionsRepresentable` represents the options and arguments is
  /// not resolvable. Used by the `OptionsRepresentable` as default argument type and
  /// by the `CommanderRepresentable` as default options type.
  public struct None: NoneOptionsRepresentable {
    /// The coding key type of `CodingKey & StringRawRepresentable` for decoding.
    public typealias OptionKeys = DefaultOptions.EmptyOptionKeys
    /// The short keys of the options' coding keys.
    public static let keys: [OptionKeys : Character] = [:]
    /// The extends option keys for the `Options`.
    public static let descriptions: [OptionKeys : OptionDescription] = [:]
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
      throw OptionsDecoder.Error.unresolvableArguments
    }
  }
  
  // MARK: - Empty.
  
  /// The concrete type conforms `EmptyOptionsRepresentable` represents the options and arguments is
  /// default empty.
  public struct Empty: EmptyOptionsRepresentable {
    /// The coding key type of `CodingKey & StringRawRepresentable` for decoding.
    public typealias OptionKeys = EmptyOptionKeys
    /// The short keys of the options' coding keys.
    public static let keys: [OptionKeys : Character] = [:]
    /// The extends option keys for the `Options`.
    public static let descriptions: [OptionKeys : OptionDescription] = [:]
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
      // Default do nothing.
    }
  }
}

extension OptionsRepresentable where ArgumentsResolver == Commander.ArgumentsResolver<DefaultOptions.None> {
  /// The arguments of the options if arguments can be resolved.
  public var arguments: [ArgumentsResolver.Argument] {
    get { return [] }
    set { }
  }
}

extension OptionsRepresentable where ArgumentsResolver == Commander.ArgumentsResolver<DefaultOptions.Empty> {
  /// The arguments of the options if arguments can be resolved.
  public var arguments: [ArgumentsResolver.Argument] {
    get { return [] }
    set { }
  }
}
