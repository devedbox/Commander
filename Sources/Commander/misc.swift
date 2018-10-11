//
//  misc.swift
//  Commander
//
//  Created by devedbox on 2018/10/5.
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

#if os(Linux)
import Glibc
#else
import Darwin
#endif
import Foundation

internal func dispatchSuccess() -> Never {
  return exit(EXIT_SUCCESS)
}

internal func dispatchFailure() -> Never {
  return exit(EXIT_FAILURE)
}

// MARK: - Substring.

extension Substring {
  /// Returns the value of string of `String` by initialize a string value with the receiver.
  internal var string: String { return String(self) }
}

// MARK: FileHandle.

extension FileHandle {
  /// Returns the file handle for terminal.
  internal static var terminal: (master: FileHandle, slave: FileHandle)? {
    var master: Int32 = 0
    var slave: Int32 = 0
    let result = openpty(&master, &slave, nil, nil, nil)
    
    if result != 0 {
      return nil
    }
    
    _ = fcntl(master, F_SETFD, FD_CLOEXEC)
    _ = fcntl(slave, F_SETFD, FD_CLOEXEC)
    
    let masterHandle = FileHandle(fileDescriptor: master, closeOnDealloc: true)
    let slaveHandle = FileHandle(fileDescriptor: slave, closeOnDealloc: true)
    
    return (master: masterHandle, slave: slaveHandle)
  }
}

/// Returns the environment variable path of the system if any.
internal let envPaths = { () -> [String] in
  let env_paths = getenv("PATH")
  let char_env_paths = unsafeBitCast(env_paths, to: UnsafePointer<CChar>.self)
  #if swift(>=4.1)
  return String(validatingUTF8: char_env_paths)?.split(separator: ":").compactMap { String($0) } ?? []
  #else
  return
  String(validatingUTF8: char_env_paths)?.split(separator: ":").flatMap { String($0) } ?? []
  #endif
}()
/// Find the executable path with a path extension.
internal func executable(_ name: String) -> String? {
  let paths = [FileManager.default.currentDirectoryPath] + envPaths
  return paths.map { name.hasPrefix("/") ? $0 + name : $0 + "/\(name)" }.first { FileManager.default.isExecutableFile(atPath: $0) }
}
/// Run the command with the given arguments.
///
/// - Parameter command: The command to run.
/// - Parameter arguments: The arguments for the command to run with.
///
/// - Returns: The stdoutput or stderror results.
@discardableResult
internal func shell(
  _ command: String,
  arguments: [String],
  at currentWorkingDirectory: String? = nil,
  stdin: Any? = nil,
  stdout: Any? = nil) -> Int32
{
  // Creates a new process.
  let process = Process()
  // Changing the current working path if needed.
  if let cwd = currentWorkingDirectory {
    process.currentDirectoryPath = cwd
  }
  
  process.launchPath = executable(command)
  process.arguments = arguments
  process.standardInput = stdin
  process.standardOutput = stdout
  // Using custom output.
  process.launch()
  process.waitUntilExit()
  
  return process.terminationStatus
}
/// Run the command along with the arguments.
///
/// - Parameter commands: The command to run.
///
/// - Returns: The stdoutput or stderror results.
@discardableResult
internal func shell(
  _ commands: String,
  at currentWorkingDirectory: String? = nil,
  stdin: Any? = nil,
  stdout: Any? = nil) -> Int32
{
  var compos = commands.split(separator: " ")
  return shell(
    String(compos.removeFirst()),
    arguments: compos.map { String($0) },
    at: currentWorkingDirectory,
    stdin: stdin,
    stdout: stdout
  )
}
