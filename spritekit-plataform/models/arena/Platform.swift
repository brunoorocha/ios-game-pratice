//
//  Platform.swift
//  spritekit-plataform
//
//  Created by Guilherme Colombini on 01/03/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import UIKit

class Platform {
	let atlas: String
	let position: CGPoint
	
	init(with dictionary: [String: Any]) {
		let x = dictionary["positionX"] as! CGFloat
		let y = dictionary["positionY"] as! CGFloat
		
		self.position = CGPoint(x: x, y: y)
		self.atlas = dictionary["atlas"] as! String
	}
}
