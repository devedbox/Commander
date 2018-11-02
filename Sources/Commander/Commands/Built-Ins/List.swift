//
//  List.swift
//  Commander
//
//  Created by devedbox on 2018/11/2.
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

/// The built-in command to list all the subcommands and options info of the given parameter
/// and given command name.
public struct List: CommandRepresentable {
  public struct Options: OptionsRepresentable {
    public typealias ArgumentsRsolver = AnyArgumentsResolver<String>
    public enum CommandType: String, Codable {
      case command = "cmd"
      case options = "ops"
      case optionsWithShortKeys = "s-ops"
    }
    public enum CodingKeys: String, CodingKeysRepresentable {
      case type
    }
    public static var keys: [CodingKeys: Character] = [:]
    public static var descriptions: [CodingKeys: OptionDescription] = [:]
    
    public let type: CommandType
  }
  
  public static let symbol = "list"
  public static let usage = "List all subcommands or options of given command"
  
  public static func main(_ options: List.Options) throws {
    let arguments = options.arguments
    let path: CommandPath?

    if let root = arguments.first,  {
      path = CommandPath(running: <#T##AnyCommandRepresentable.Type#>, at: <#T##String#>)
    }
    
    switch options.type {
    case .command:
      
    case .options: break
    case .optionsWithShortKeys:
      break
    }
  }
}
