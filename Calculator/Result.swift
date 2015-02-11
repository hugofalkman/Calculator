//
//  Result.swift
//  Calculator
//
//  Created by H Hugo Falkman on 2015-02-09.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import Foundation

// Stack value or error message
enum Result: Printable {
    case Value(Double)
    case Error(String)
    
    var description: String {
        switch self {
        case .Value(let value):
            return "\(value)"
        case .Error(let errmsg):
            return errmsg
        }
    }
}
