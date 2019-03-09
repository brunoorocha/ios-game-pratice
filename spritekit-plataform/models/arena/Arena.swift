//
//  Arena.swift
//  spritekit-plataform
//
//  Created by Guilherme Colombini on 01/03/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import UIKit

enum GameMode: String {
	case survival
	case deathmatch
}

class Arena {
	let playerSlots: [CGPoint]
	let platforms: [Platform]
	let mode: GameMode
	
	init(slots: [CGPoint], platforms: [Platform], mode: String) {
		self.playerSlots = slots
		self.platforms = platforms
		self.mode = GameMode.init(rawValue: mode)!
	}
}
