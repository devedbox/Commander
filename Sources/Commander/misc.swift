//
//  misc.swift
//  Commander
//
//  Created by devedbox on 2018/10/5.
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
