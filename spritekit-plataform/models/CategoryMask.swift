//
//  CategoryMask.swift
//  Attack
//
//  Created by Thiago Valente on 21/02/19.
//  Copyright © 2019 Thiago Valente. All rights reserved.
//

import Foundation

struct CategoryMask {
    static let none : UInt32 = 0
    static let player : UInt32 = 0x1 << 0
    static let plataform : UInt32 = 0x1 << 1
    static let ground : UInt32 = UInt32.max
}
