//
//  Option.swift
//  Commander
//
//  Created by devedbox on 2020/11/19.
//

// MARK: - OptionDescribable.

/// A protocol represents the conforming types can be described as the coding keys for the given
/// `Option` type.
public protocol OptionDescribable: Decodable {
  /// Returns the short key of the option description.
  var k: String? { get }
  /// Returns the usage of the option description.
  var usage: String { get }
  /// Returns the default value of the option description.
  var defaultValue: Decodable { get }
}

// MARK: - Option.

/// A property wrapper for the property of `OptionsRepresentable & OptionsPropertyWwapper` to describe the info
/// of given option property by speficying the short key and usage.
@propertyWrapper public struct Option<T>: OptionDescribable where T: Codable & Hashable {
  /// The wrapped underlying storage of wrapped type `T`.
  public let wrappedValue: T
  /// Returns the short key of the option description.
  public let k: String?
  /// Returns the usage of the option description.
  public let usage: String
  /// Returns the default value of the option description.
  public var defaultValue: Decodable {
    return wrappedValue
  }
  
  /// Customize the decoable protocol by interpret the decoder to the underlying wrapped type.
  public init(from decoder: Decoder) throws {
    self.wrappedValue = try T.init(from: decoder)
    self.k = nil
    self.usage = ""
  }
  
  /// Creates the option wrapped with the given parameters.
  ///
  /// - Parameter wrappedValue: The value to be wrapped.
  /// - Parameter k: The short key description.
  /// - Parameter usage: The usage info of the option description.
  public init(wrappedValue: T, k: String? = nil, usage: String) {
    self.wrappedValue = wrappedValue
    self.k = k
    self.usage = usage
  }
}

extension Option: Encodable {
  /// Encodes this value into the given encoder.
  ///
  /// If the value fails to encode anything, `encoder` will encode an empty
  /// keyed container in its place.
  ///
  /// This function throws an error if any values are invalid for the given
  /// encoder's format.
  ///
  /// - Parameter encoder: The encoder to write data to.
  public func encode(to encoder: Encoder) throws {
    var encodeContainer = encoder.singleValueContainer()
    try encodeContainer.encode(wrappedValue)
  }
}

extension Option: Hashable {
  /// Returns a Boolean value indicating whether two values are equal.
  ///
  /// Equality is the inverse of inequality. For any values `a` and `b`,
  /// `a == b` implies that `a != b` is `false`.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  public static func == (lhs: Option<T>, rhs: Option<T>) -> Bool {
    return lhs.wrappedValue == rhs.wrappedValue && lhs.k == rhs.k && lhs.usage == rhs.usage
  }
}

extension Option: CustomStringConvertible {
  /// A textual representation of this instance.
  ///
  /// Calling this property directly is discouraged. Instead, convert an
  /// instance of any type to a string by using the `String(describing:)`
  /// initializer. This initializer works with any type, and uses the custom
  /// `description` property for types that conform to
  /// `CustomStringConvertible`:
  ///
  ///     struct Point: CustomStringConvertible {
  ///         let x: Int, y: Int
  ///
  ///         var description: String {
  ///             return "(\(x), \(y))"
  ///         }
  ///     }
  ///
  ///     let p = Point(x: 21, y: 30)
  ///     let s = String(describing: p)
  ///     print(s)
  ///     // Prints "(21, 30)"
  ///
  /// The conversion of `p` to a string in the assignment to `s` uses the
  /// `Point` type's `description` property.
  public var description: String {
    return "\(self.wrappedValue)"
  }
}

// MARK: - WrappedOptionKeys.

/// A type used by the `OptionsPropertyWrapper` to interpret the options keys using `Option`.
public struct WrappedOptionKeys<T>: OptionKeysRepresentable where T: OptionsPropertyWrapper {
  /// A type that can represent a collection of all values of this type.
  public typealias AllCases = [WrappedOptionKeys]
  /// A collection of all values of this type.
  public static var allCases: [WrappedOptionKeys] {
    return (try? allCases(reflecting: T.init())) ?? []
  }
  /// The string to use in a named collection (e.g. a string-keyed dictionary).
  public var stringValue: String
  /// Creates the instance with string value.
  public init?(rawValue: String) { self.stringValue = rawValue }
}
