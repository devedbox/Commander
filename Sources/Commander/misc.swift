//
//  misc.swift
//  Commander
//
//  Created by devedbox on 2018/10/5.
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

#if os(Linux)
import Glibc
#else
import Darwin
#endif
import Foundation

#if DEBUG
public typealias Result = Int32
#else
public typealias Result = Never
#endif

internal func dispatchSuccess() -> Result {
#if DEBUG
  return EXIT_SUCCESS
#else
  return exit(EXIT_SUCCESS)
#endif
}

internal func dispatchFailure() -> Result {
#if DEBUG
  return EXIT_FAILURE
#else
  return exit(EXIT_FAILURE)
#endif
}

// MARK: - Substring.

extension Substring {
  /// Returns the value of string of `String` by initialize a string value with the receiver.
  internal var string: String { return String(self) }
}

// MARK: - <<<.

infix operator <<<: StreamPrecedence
precedencegroup StreamPrecedence {
  associativity: left
}

@discardableResult
public func <<< <Target: StringProtocol>(left: TextOutputStream, right: Target) -> TextOutputStream {
  var stream = left; stream.write("\(right)"); return stream
}
