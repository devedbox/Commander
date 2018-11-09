//
//  Bool+.swift
//  Commander
//
//  Created by devedbox on 2018/11/9.
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

// MARK: - Bool.

extension Bool {
  /// Applying the given true closure on the subject when the value is true.
  /// Otherwise, applying none of closure on the subject.
  @discardableResult
  public func `true`<U>(_ transform: () throws -> U) rethrows -> U? {
    return self ? try transform() : nil
  }
  /// Applying the given false closure on the subject when the value is false.
  /// Otherwise, applying none of closure on the subject.
  @discardableResult
  public func `false`<U>(_ transform: () throws -> U) rethrows -> U? {
    return self ? nil : try transform()
  }
  /// Union with the other bool value by using '&&' operator.
  ///
  /// - Parameter other: The other bool value.
  /// - Returns: Returns the result after operator '&&'.
  public func and(_ other: () -> Bool) -> Bool {
    return self && other()
  }
  /// Union with the other bool value by using '||' operator.
  ///
  /// - Parameter other: The other bool value.
  /// - Returns: Returns the result after operator '||'.
  public func or(_ other: () -> Bool) -> Bool {
    return self || other()
  }
}
