//
//  Shell.swift
//  Commander
//
//  Created by devedbox on 2018/11/5.
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

import Utility

// MARK: - Shell.

/// The type of 'shell' to perform shell-specificed actions.
public enum Shell: String, Codable {
  /// The GNU Bourne-Again SHell. Usually located at '/bin/bash'.
  case bash
  /// The Z shell. Usually located at '/bin/zsh'.
  case zsh
  /// The fish, a smart and user-friendly command lin shell. Usually located at '/bin/fish'.
  case fish
}

// MARK: - ShellCompletable.

/// A protocol represents the conforming types can provide the complete list
/// to the shell completion system.
public protocol ShellCompletable {
  /// Returns the completions list for the specific option key.
  ///
  /// - Parameter commandLine: The command line arguments.
  /// - Returns: Returns the completion list for the given key.
  static func completions(for commandLine: Utility.CommandLine) -> [String]
}

extension ShellCompletable {
  /// Returns the completions list for the specific option key.
  ///
  /// - Parameter commandLine: The command line arguments.
  /// - Returns: Returns the completion list for the given key.
  public static func completions(for commandLine: Utility.CommandLine) -> [String] {
    return [
      // Default empty...
    ]
  }
}
