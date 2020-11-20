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
  public struct Options: OptionsRepresentable, OptionsPropertyWrapper {
    public typealias Argument = String
    
    @Option(k: "s", usage: "Pass a value of String to the command") var stringValue: String = ""
    @Option(k: "v", usage: "Prints the logs of the command") var verbose: Bool = false
    
    public var stringValue1: String?
    
    public init() { }
    
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
  
  public static let children: [CommandDispatchable.Type] = [
    NoArgsCommand.self
  ]
  public static let symbol: String = "sample"
  public static let usage: String = "Show sample usage of commander"
  
  public static func main(_ options: Options) throws {
    print(options)
    print("arguments: \(options.arguments)")
  }
}

public struct NoArgsCommand: CommandRepresentable {
  public struct Options: OptionsRepresentable, OptionsPropertyWrapper {
    @Option(k: "A", usage: "Should add arguments to the command") var addArgs: Bool = false
    @Option(usage: "The arguments to be added to the command along with '--add-args'") var args: [String] = []
    
    public init() { }
  }
  
  @Option(usage: "set-args")
  public static var symbol: String = "set-args"
  public static let usage: String = "Set arguments of the command with given arguments"
  
  public static func main(_ options: Options) throws {
    print(options)
    print("arguments: \(options.arguments)")
  }
}
