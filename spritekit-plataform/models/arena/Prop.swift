//
//  Prop.swift
//  spritekit-plataform
//
//  Created by Guilherme Colombini on 14/03/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import UIKit

class Prop {
	let scale: CGFloat
	let position: CGPoint
	let atlas: String
	
	init(scale: CGFloat, position: CGPoint, atlas: String) {
		self.scale = scale
		self.position = position
		self.atlas = atlas
	}
}
