//
//  Device.swift
//  frame-it
//
//  Created by Yoann LATHUILIERE on 18/07/2023.
//

import Foundation
import SwiftUI

struct Device: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let frame: Image
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
