# ![logo](Resources/logo.svg) Commander

![test](https://travis-ci.com/devedbox/Commander.svg?branch=master)[![codecov](https://codecov.io/gh/devedbox/Commander/branch/master/graph/badge.svg)](https://codecov.io/gh/devedbox/Commander)![license](https://img.shields.io/badge/license-MIT-blue.svg)![lang](https://img.shields.io/badge/language-swift-orange.svg)[![Maintainability](https://api.codeclimate.com/v1/badges/83ff78d95f31412070e1/maintainability)](https://codeclimate.com/github/devedbox/Commander/maintainability)

Commander is a Swift framework for decoding command-line arguments by integrating with Swift standard library protocols Decodable & Decoder. Commander can help you to write structured cli program by declaring the structure of `command` and `options` of that command without writing any codes to parse the cli arguments. With Commander, you just need to focus on writing `options` structure of commands, the rest works will be handled by Commander automatically.

## Features

- [x] Structured-CLI, commands and options are all structured by declaration a `struct` or `class`.
- [x] Options types are type-safe by implementing `Decodable` protocol.
- [x] Automatically generate help message for the `commander` or `command`.
- [x] Shell <Tab> completion supported. Bash/zsh <Tab> auto-complete scripts supported.
- [x] Swift 4 compatibility.
- [x] Zero dependency.
- [x] Supports Linux and `swift build`.

## Requirements

- Mac OS X 10.10+ / Ubuntu 14.10
- Xcode 10
- Swift 4.2
---

## Installation

### With [SPM](https://github.com/apple/swift-package-manager)

```swift
// swift-tools-version:4.2
dependencies: [
  .package(url: "https://github.com/devedbox/Commander.git", "0.5.6..<100.0.0")
]
```
----

## Usage

Commander supports a main commander alongwith the commands of that commander, and each command has its own subcommands and options.

Using a Commander is simple, you just need to declare the `commands`, `usage` of the commander, and then call `Commander().dispatch()`, the Commander will automatically decode the command line arguments and dispatch the decoded options to the specific command given by command line.

Just as simple as following:

```swift
import Commander

BuiltIn.Commander.commands = [
  SampleCommand.self,
  NoArgsCommand.self
]
BuiltIn.Commander.usage = "The sample usage command of 'Commander'"
BuiltIn.Commander().dispatch()
```
### Command

In Commander, a command is a type(`class` or `struct`) that conforms to protocol `CommandRepresentable`. The protocol *CommandRepresentable* declare the infos of the conforming commands:

- `Options`: The associated type of command's options.
- `symbol`: The symbol of the command used by command line shell.
- `usage`: The usage help message for that command.
- `children`: The subcommands of that command.

#### Creates a Command

```swift
public struct Command: CommandRepresentable {
  public struct Options: OptionsRepresentable {
    public enum CodingKeys: String, CodingKeysRepresentable {
      case verbose
    }
    
    public static let descriptions: [SampleCommand.Options.CodingKeys : OptionDescription] = [
      .verbose: .usage("Prints the logs of the command"),
    ]
    
    public var verbose: Bool = false
  }
  
  public static let symbol: String = "sample"
  public static let usage: String = "Show sample usage of commander"
  
  public static func main(_ options: Options) throws {
    print(options)
    print("arguments: \(options.arguments)")
  }
}
```

This command is named 'sample' and takes option '--verbose'

### Options
### Arguments
### Completions

## Example

With Commander, a command and its associated options could be defined as follows:

```swift
import Commander

public struct SampleCommand: CommandRepresentable {
  public struct Options: OptionsRepresentable {
    public typealias ArgumentsResolver = AnyArgumentsResolver<String>
    public enum CodingKeys: String, CodingKeysRepresentable {
      case verbose = "verbose"
      case stringValue = "string-value"
    }

    public static let keys: [Options.CodingKeys : Character] = [
      .verbose: "v",
      .stringValue: "s"
    ]

    public static let descriptions: [Options.CodingKeys : OptionDescription] = [
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
```

Then, configuring the available commands would like this: 

```swift
import Commander

Commander.commands = [
  SampleCommand.self,
  NoArgsCommand.self
]
Commander.usage = "The sample usage command of 'Commander'"
Commander().dispatch() // Call this to dispatch and run the command
```

After which, arguments can be resolved by declaration of `ArgumentsResolver`:

```swift
public typealias ArgumentsResolver = AnyArgumentsResolver<T> // T must be Decodable
```

And you can fetch the arguments by:
```swift
public static func main(_ options: Options) throws {
  print("arguments: \(options.arguments)") // 'arguments' is being declared in OptionsRepresentable 
}
```

### Execution

From shell:

```bash
commander-sample sample --verbose --string-value String arg1 arg2
# 
# Options(verbose: true, stringValue: "String")
# arguments: ["arg1", "arg2"]
#
#
# string-value
```

It's easy and fun!!!

## Test Coverage Graph

![coverage graph](https://codecov.io/gh/devedbox/Commander/commit/1a15f7be4db03125027641205529e0e5d5050b21/graphs/sunburst.svg)

## License

Commander is released under the [MIT license](LICENSE).
