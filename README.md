![logo](Resources/logo.svg)

![test](https://travis-ci.com/devedbox/Commander.svg?branch=master)[![codecov](https://codecov.io/gh/devedbox/Commander/branch/master/graph/badge.svg)](https://codecov.io/gh/devedbox/Commander)![license](https://img.shields.io/badge/license-MIT-blue.svg)![lang](https://img.shields.io/badge/language-swift-orange.svg)[![Maintainability](https://api.codeclimate.com/v1/badges/83ff78d95f31412070e1/maintainability)](https://codeclimate.com/github/devedbox/Commander/maintainability)

Commander is a Swift framework for decoding command-line arguments by integrating with Swift standard library protocols Decodable & Decoder. Commander can help you to write **structured cli** program by declaring the structure of `command` and `options` of that command without writing any codes to parse the cli arguments. With Commander, you just need to focus on writing `options` structure of commands, the rest works will be handled by Commander automatically.

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

## Test Coverage Graph

![coverage graph](https://codecov.io/gh/devedbox/Commander/commit/1a15f7be4db03125027641205529e0e5d5050b21/graphs/sunburst.svg)

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

In Commander, a command is a type(`class` or `struct`) that conforms to protocol `CommandRepresentable`. The protocol *CommandRepresentable* declares the infos of the conforming commands:

- `Options`: The associated type of command's options.
- `symbol`: The symbol of the command used by command line shell.
- `usage`: The usage help message for that command.
- `children`: The subcommands of that command.

#### Creating a Command

```swift
public struct Hello: CommandRepresentable {
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
    if options.verbose {
      print(options.argiments.first ?? "")
    }
  }
}
```

#### Dispatching a command

Once a command has been created, it can be dispathed against a list of arguments, usually taken from CommandLine.arguments with droping of the symbol of command itself.

```swift
let arguments = ["sample", "--verbose", "Hello world"]
Command.dispatch(with: arguments.dropFirst())
// Hello world
```

As a real dispatching of command, you don't need to dispatch the command manually, the dispatching will be handled by Commander automatically.

### Options

The `Options` is the same as command, is a type(`class` or `struct`) that conforms to protocol `OptionsRepresentable` which inherited from `Decodable` and can be treated as a simple data model, will be decoed by the built in code type `OptionsDecoder` in Commander.

#### Declaring an options

As mentioned earlier in *[Creating a Command](#Creating-a-Command)*, declaring an options type is extremely easy, just another data model represents the raw string in command line arguments:

```swift
public struct Options: OptionsRepresentable {
  public enum CodingKeys: String, CodingKeysRepresentable {
    case verbose
  }

  public static let descriptions: [SampleCommand.Options.CodingKeys : OptionDescription] = [
    .verbose: .usage("Prints the logs of the command"),
  ]

  public var verbose: Bool = false
}
```

#### Changing option symbol

As declared as `public var verbose: Bool`, we can use symbol in command line with `--verbose` accordingly, but how to use another different symbol in command line to wrap `verbose` such as `--is-verbose`? In Commander, we can just do as this:

```swift
public enum CodingKeys: String, CodingKeysRepresentable {
  case verbose = "is-verbose"
}
```

#### Providing a short key

Sometimes in develping command line tools, using a pattern like `-v` is necessary and helpful. In Commander, providing a short key for option is easy, we just need to declare a key-value pairs of type `[CodingKeys: Character]` in `Options.keys`:

```swift
public struct Options: OptionsRepresentable {
  ...
  public static let keys: [CodingKeys: Character] = [
    .verbose: "v"
  ]
  ...
}
```

#### Providing a default value

When we difine a flag option in our command, provide a default value for flag is required because if we miss typing the flag in command line, the value of that flag means `false`. Providing default value in Commander is by add declaration in `Options.descritions` as this:

```swift
public struct Options: OptionsRepresentable {
  ...
  public static let descriptions: [SampleCommand.Options.CodingKeys : OptionDescription] = [
    .verbose: .default(value: false, usage:"Prints the logs of the command")
  ]
  ...
}
```

### Values

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

## License

Commander is released under the [MIT license](LICENSE).
