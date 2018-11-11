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

// MARK: - CommandLine.

/// A type that parses the command line arguments.
public struct CommandLine {
  /// The count of the arguments excluding the command path.
  public var argc: Int32 {
    return Int32(arguments.underestimatedCount) - 1
  }
  /// The parsed arguments.
  public private(set) var arguments: [String] = []
  /// Parse the given command line string and creates an instance of 'CommandLine'.
  ///
  /// - Parameter commandLine: The command line raw string value.
  public init(_ commandLine: String) {
    arguments = commandLine.split(delimiter: " ")
  }
}
