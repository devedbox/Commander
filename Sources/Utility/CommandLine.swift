//
//  CommandLine.swift
//  Utility
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

import Foundation

// MARK: - StdLib+.

fileprivate extension Array where Element == String {
  /// Advance by adding empty string to the container.
  fileprivate mutating func advance() {
    self.append("")
  }
  /// Append a char to the top element of the container.
  ///
  /// - Parameter char: The character to be appended.
  fileprivate mutating func lastAppend(_ char: Character) {
    isEmpty ? advance() : ()
    append(popLast()! + String(char))
  }
}

// MARK: - CommandLine.

/// A type that parses the command line arguments.
public struct CommandLine {
  /// Indicates if the reading of command line is quoting.
  internal private(set) var isQuoting: Bool = false
  /// Indicates if the reading of command line is escaping.
  internal private(set) var isEscaping: Bool = false
  /// The count of the arguments excluding the command path.
  public private(set) var argc: Int32 = -1
  /// The parsed arguments.
  public private(set) var arguments: [String] = []
  
  /// Parse the given command line string.
  public mutating func parse(_ commandLine: String) throws {
    for char in commandLine {
      switch char {
      case "\\":
        isEscaping = true
      case "\"", "'":
        isQuoting.toggle()
      case " ":
        arguments.advance(); argc += 1
      default:
        isEscaping ? isEscaping.toggle() : ()
        arguments.lastAppend(char)
      }
    }
  }
}
