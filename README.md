![logo](Resources/logo.png)

![test](https://travis-ci.com/devedbox/Commander.svg?branch=master)[![codecov](https://codecov.io/gh/devedbox/Commander/branch/master/graph/badge.svg)](https://codecov.io/gh/devedbox/Commander)![license](https://img.shields.io/github/license/mashape/apistatus.svg)![lang](https://img.shields.io/badge/language-swift-orange.svg)[![Maintainability](https://api.codeclimate.com/v1/badges/83ff78d95f31412070e1/maintainability)](https://codeclimate.com/github/devedbox/Commander/maintainability)

# Commander 

Commander is a Swift framework for decoding command-line arguments by integrating with Swift Standard Library Protocols e.g. Encodable & Decodable. With Commander, you just need to focus on writing options model of commands, the rest works will be handled by Commander.

## Test Coverage Graph

![coverage graph](https://codecov.io/gh/devedbox/Commander/commit/1a15f7be4db03125027641205529e0e5d5050b21/graphs/sunburst.svg)

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

After which, arguments can be resolved by declaration of  `ArgumentsResolver`:

```swift
public typealias ArgumentsResolver = AnyArgumentsResolver<T> // T must be Decodable
```

And you can fetch the arguments by:
```swift
public static func main(_ options: Options) throws {
  print("arguments: \(options.arguments)") // 'arguments' is being declared in OptionsRepresentable 
}
```

It's easy and fun!!!

## License

Commander is released under the [MIT license](LICENSE).
