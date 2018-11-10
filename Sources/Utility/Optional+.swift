//
//  Optional+.swift
//  Utility
//
//  Created by devedbox on 2018/11/10.
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

// MARK: - Optional.

extension Optional {
  /// Evaluates the given closure when this `Optional` instance is not `nil`,
  ///
  /// Use the `nil` method with a closure that returns a nonoptional value.
  /// This example performs an arithmetic operation on an
  /// optional integer.
  ///
  ///     let possibleNumber: Int? = nil
  ///     let possibleSquare = possibleNumber.nil { $0 * $0 }
  ///     print(possibleSquare)
  ///     // Prints "Optional(1764)"
  ///
  ///     let noNumber: Int? = Int("42")
  ///     let noSquare = noNumber.map { $0 * $0 }
  ///     print(noSquare)
  ///     // Prints "nil"
  ///
  /// - Parameter transform: A closure that takes the unwrapped value
  ///   of the instance.
  /// - Returns: The result of the given closure. If this instance is `nil`,
  ///   returns `nil`.
  public func `nil`<U>(_ transform: () throws -> U?) rethrows -> U? {
    switch self {
    case .none:
      return try transform()
    case .some(_):
      return nil
    }
  }
}
