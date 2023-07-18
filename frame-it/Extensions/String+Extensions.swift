//
//  String+Extensions.swift
//  frame-it
//
//  Created by Yoann LATHUILIERE on 19/07/2023.
//

import Foundation

extension String {
    var removingExtension: String {
        let components = self.components(separatedBy: ".")
        guard components.count > 1 else {
            return self
        }
        return components.dropLast().joined(separator: ".")
    }
}
