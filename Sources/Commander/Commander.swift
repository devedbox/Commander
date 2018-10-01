#if os(Linux)
import Glibc
#else
import Darwin
#endif

import Foundation

public struct Commander {
  var text = "Hello, World!"
  
  public mutating func watch(command: Command) {
    
  }
}

public let verbose: Option = ["--verbose", "-v"]

extension Commander {
  public func dispatch() {
    let args = CommandLine.arguments
  }
}
