//
//  SampleCommand.swift
//  commander-sample
//
//  Created by devedbox on 2018/10/3.
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

import Commander

public struct SampleCommand: CommandRepresentable {
  public struct Options: OptionsRepresentable {
    public typealias ArgumentsResolver = AnyArgumentsResolver<String>
    public enum CodingKeys: String, CodingKeysRepresentable {
      case verbose = "verbose"
      case stringValue = "string-value"
    }
    
    public static let keys: [SampleCommand.Options.CodingKeys : Character] = [
      .verbose: "v",
      .stringValue: "s"
    ]
    
    public static let descriptions: [SampleCommand.Options.CodingKeys : OptionDescription] = [
      .verbose: .usage("Prints the logs of the command"),
      .stringValue: .usage("Pass a value of String to the command")
    ]
    
    public var verbose: Bool = false
    public var stringValue: String = ""
    
    public static func completions(for key: String) -> [String] {
      switch key {
      case "":
        return [
          "a", "b", "c"
        ]
      default:
        return [ ]
      }
    }
  }
  
  public static let subcommands: [AnyCommandRepresentable.Type] = [
    NoArgsCommand.self
  ]
  public static let symbol: String = "sample"
  public static let usage: String = "Show sample usage of commander"
  
  public static func main(_ options: Options) throws {
    print(options)
    print("arguments: \(options.arguments)")
    print("\n\n\(Options.CodingKeys.stringValue.stringValue)")
  }
}

public struct NoArgsCommand: CommandRepresentable {
  public struct Options: OptionsRepresentable {
    public enum CodingKeys: String, CodingKeysRepresentable {
      public static let shortKeys: [NoArgsCommand.Options.CodingKeys : Character] = [:]
      
      case addArgs = "add-args"
      case args
    }
    
    public static var keys: [NoArgsCommand.Options.CodingKeys : Character] = [
      .args: "A"
    ]
    
    public static let descriptions: [Options.CodingKeys: OptionDescription] = [
      .addArgs: .default(value: false, usage: "Should add arguments to the command"),
      .args: .usage("The arguments to be added to the command along with '--add-args'")
    ]
    
    public var addArgs: Bool
    public var args: [String]
  }
  
  public static let symbol: String = "set-args"
  public static let usage: String = "Set arguments of the command with given arguments"
  
  public static func main(_ options: Options) throws {
    print(options)
    print("arguments: \(options.arguments)")
    
    print("\n\n\(Options.CodingKeys.addArgs.stringValue)")
  }
}
