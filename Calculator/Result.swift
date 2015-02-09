//
//  Result.swift
//  Calculator
//
//  Created by H Hugo Falkman on 2015-02-09.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import Foundation

/*
// enum with either result (of evaluation) or error message
enum Result<T> {
    case Value(T)
    case Error(String)

    // executes function f on result or just passes on the error message
    func mapping<P>(f: T -> P) -> Result<P> {
        switch self {
        case Value(let value):
            return .Value(f(value))
        case Error(let errMessage):
            return .Error(errMessage)
        }
    }
}
*/