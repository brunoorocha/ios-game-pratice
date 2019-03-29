//
//  FighterSound.swift
//  spritekit-plataform
//
//  Created by Thiago Valente on 29/03/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import Foundation

enum FighterSoundList{
    case attack
    case hurt
    case jump
    case death
}

extension FighterSoundList{
    var named: String{
        switch self{
        case .attack:
            return "FighterAttack"
        case .hurt:
            return "FighterHurt"
        case .jump:
            return "FighterJump"
        case .death:
            return "FighterDeath"
        }
    }
}

class FighterSound{
    static func run(type: FighterSoundList){
        SoundManager.shared().action(sound: type.named)
    }
}
