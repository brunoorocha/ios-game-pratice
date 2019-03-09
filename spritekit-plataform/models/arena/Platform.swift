//
//  Platform.swift
//  spritekit-plataform
//
//  Created by Guilherme Colombini on 01/03/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import UIKit

class Platform {
	let size: CGSize
	let atlas: String
	let position: CGPoint
	
	init(with dictionary: [String: Any]) {
		let width = dictionary["width"] as! CGFloat
		let height = dictionary["height"] as! CGFloat
		let x = dictionary["positionX"] as! CGFloat
		let y = dictionary["positionY"] as! CGFloat
		
		self.size = CGSize(width: width, height: height)
		self.position = CGPoint(x: x, y: y)
		self.atlas = dictionary["atlas"] as! String
	}
}
