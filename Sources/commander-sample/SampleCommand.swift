//
//  SampleCommand.swift
//  commander-sample
//
//  Created by devedbox on 2018/10/3.
//

import Commander

public struct SampleCommand: CommandRepresentable {
  public struct Options: OptionsRepresentable {
    public enum CodingKeys: String, CodingKey, StringRawRepresentable {
      case verbose = "verbose"
      case stringValue
    }
    
    public static let description: [Description] = [
      (.verbose, .short("v", usage: ""))
    ]
    
    public var verbose: Bool = false
    public let stringValue: String?
  }
  
  public static let symbol: String = "sample"
  public static let usage: String = "Show sample usage of commander"
  
  public static func main(_ options: Options) throws {
    print(options)
  }
}
