//
//  SampleCommand.swift
//  commander-sample
//
//  Created by devedbox on 2018/10/3.
//

import Commander

public struct SampleCommand: CommandRepresentable {
  public struct Options: OptionsRepresentable {
    public typealias ArgumentsResolver = AnyArgumentsResolver<String>
    public enum CodingKeys: String, CodingKey, StringRawRepresentable {
      case verbose = "verbose"
      case stringValue = "string-value"
    }
    
    public static let description: [Description] = [
      (.verbose, .short("v", usage: "Prints the logs of the command")),
      (.stringValue, .short("s", usage: "Pass a value of String to the command"))
    ]
    
    public var verbose: Bool = false
    public var stringValue: String = ""
  }
  
  public static let symbol: String = "sample"
  public static let usage: String = "Show sample usage of commander"
  
  public static func main(_ options: Options) throws {
    print(options)
    print("arguments: \(options.arguments)")
  }
}

public struct NoArgsCommand: CommandRepresentable {
  public struct Options: OptionsRepresentable {
    public enum CodingKeys: String, CodingKey, StringRawRepresentable {
      case addArgs = "add-args"
      case args
    }
    
    public static let description: [Description] = [
      (.addArgs, .usage("Should add arguments to the command")),
      (.args, .short("A", usage: "The arguments to be added to the command along with '--add-args'"))
    ]
    
    public var addArgs: Bool
    public var args: [String]
  }
  
  public static let symbol: String = "set-args"
  public static let usage: String = "Set arguments of the command with given arguments"
  
  public static func main(_ options: Options) throws {
    print(options)
    print("arguments: \(options.arguments)")
  }
}
