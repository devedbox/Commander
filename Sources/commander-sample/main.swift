//
//  main.swift
//  Commander
//
//  Created by devedbox on 2018/10/2.
//

import Foundation
import Commander

Commander.commands = [
  SampleCommand.self
]
try Commander().dispatch()
exit(0)
