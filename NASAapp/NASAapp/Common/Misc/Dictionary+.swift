//
//  Dictionary+.swift
//  NASAapp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import Foundation

extension Dictionary {
    func compactMapKeys<T: Hashable>(_ transform: (Key) throws -> T?) rethrows -> [T: Value] {
        var result: [T: Value] = [:]
        for (key, value) in self {
            if let newKey = try transform(key) {
                result[newKey] = value
            }
        }
        return result
    }
}
