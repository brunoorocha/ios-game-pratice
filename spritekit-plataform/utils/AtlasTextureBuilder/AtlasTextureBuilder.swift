//
//  buildTexture.swift
//  Attack
//
//  Created by Thiago Valente on 22/02/19.
//  Copyright © 2019 Thiago Valente. All rights reserved.
//

import SpriteKit

class AtlasTextureBuilder {    
    public static func build(atlas name: String) -> [SKTexture]{
        let animated = SKTextureAtlas(named: name)
        var frames : [SKTexture] = []
        let numImages = animated.textureNames.count
        for i in 0..<numImages{
            let idleTextureName = animated.textureNames.sorted()[i]
            frames.append(animated.textureNamed(idleTextureName))
        }
        return frames
    }
}
