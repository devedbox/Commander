//
//  String+.swift
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

// MARK: - Merging.

extension String {
  /// Merges and returns the string value by merging and replacing the short string
  /// into the long string.
  ///
  /// - Parameter other: The other to merge with.
  public func merging(_ other: String) -> String {
    var merging: String
    let merged: String
    
    if self.endIndex > other.endIndex {
      merging = self; merged = other
    } else {
      merging = other; merged = self
    }
    
    merging.replaceSubrange(merged.startIndex..<merged.endIndex, with: merged)
    return merging
  }
}

// MARK: - EndsIndex.

extension String {
  /// Perform the exact match with the given pattern and return the index where match ends.
  ///
  /// - Parameter pattern: The pattern to be matched.
  /// - Returns: The ends index.
  public func endsIndex(matchs pattern: String) -> Index? {
    guard !isEmpty, endIndex >= pattern.endIndex else {
      return nil
    }
    
    var index = pattern.startIndex
    
    while index < pattern.endIndex, index < endIndex {
      if pattern[index] != self[index] {
        return nil
      }
      pattern.formIndex(after: &index)
    }
    
    return index
  }
  /// Returns a bool value indicates if the string is containing only one character.
  public var isSingle: Bool {
    guard !isEmpty else {
      return false
    }
    return startIndex == index(before: endIndex)
  }
}

// MARK: - Delimiters.

extension String {
  /// Splits the receiver string with the given delimiter and returns the results.
  ///
  /// - Note:
  ///   - The delimiters can be escaped with character '\'.
  ///   - The quoted string will be treated as raw string without split.
  ///
  /// - Parameter delimiter: The delimiter to split the receiver string.
  /// - Parameter omittingEmptySubsequences: If `false`, an empty subsequence is
  ///     returned in the result for each consecutive pair of `separator`
  ///     elements in the collection and for each instance of `separator` at
  ///     the start or end of the collection. If `true`, only nonempty
  ///     subsequences are returned. The default value is `true`.
  ///
  /// - Returns: Returns the results strings.
  public func split(delimiter: Character, omittingEmptySubsequences: Bool = true) -> [String] {
    var isEscaping: Bool = false
    var isQuoting: Bool = false
    var iterator = makeIterator()
    var results: [String] = []
    
    while let char = iterator.next() {
      switch char {
      case "\\"      where !isEscaping: isEscaping = true
      case "\""      where !isEscaping: fallthrough
      case "'"       where !isEscaping: isQuoting.toggle()
      case delimiter where !isEscaping:
        if isQuoting { fallthrough }
        if let last = results.last, last.isEmpty, omittingEmptySubsequences {
          break
        }
        
        results.append(String())
      default:
        isEscaping ? isEscaping.toggle() : ()
        results.isEmpty ? results.append(String()) : ()
        results.append(results.popLast()! + String(char))
      }
    }
    
    if let last = results.last, last.isEmpty, omittingEmptySubsequences {
      results.removeLast()
    }
    
    return results
  }
}

// MARK: - CamelCase2DashCase.

extension String {
  /// Returns the case convention from camel case to dash case:
  /// ```swift
  /// let value = "stringValue"
  /// print(value.camelcase2dashcase())
  ///     string-value
  /// ```
  public func camelcase2dashcase() -> String {
    var separatedComponent: [String] = []
    var index = self.startIndex
    
    while index < self.endIndex {
      let char = self[index]
      if char.isUppercase {
        if separatedComponent.isEmpty {
          separatedComponent.append(String(char.lowercased()))
        } else {
          separatedComponent.append("-\(char.lowercased())")
        }
      } else {
        var component = separatedComponent.popLast() ?? ""
        component += String(char)
        separatedComponent.append(component)
      }
      
      self.formIndex(after: &index)
    }
    
    return separatedComponent.joined()
  }
}
