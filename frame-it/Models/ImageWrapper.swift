//
//  ImageWrapper.swift
//  frame-it
//
//  Created by Yoann LATHUILIERE on 19/07/2023.
//

import Foundation
import SwiftUI

struct ImageWrapper: Identifiable {
    let id = UUID()
    let image: Image
    let fileName: String
}
