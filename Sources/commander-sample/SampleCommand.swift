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
  }
  
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
      .addArgs: .usage("Should add arguments to the command"),
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
