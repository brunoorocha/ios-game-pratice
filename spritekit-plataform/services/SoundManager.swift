//
//  SoundManager.swift
//  spritekit-plataform
//
//  Created by Thiago Valente on 29/03/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit

enum SoundTypes{
    case action
    case music
}

class SoundManager : SKNode{
    var music: SKAction = SKAction()
    var isMutedAction: Bool = false
    var isMutedMusic: Bool = false
    
    private static var sharedSoundManager: SoundManager = {
        return SoundManager()
    }()
    
    /// Run sound of any action
    ///
    /// - Parameter name: name of file
    func action(sound name: String){
        if self.isMutedAction { return }
        self.run(SKAction.playSoundFileNamed(name, waitForCompletion: false))
    }
    
    
    /// Run the music of background
    ///
    /// - Parameter name: name of file
    func music(sound name: String){
        self.removeAction(forKey: "music")
        if self.isMutedMusic { return }
        self.music = SKAction.repeatForever(SKAction.playSoundFileNamed(name, waitForCompletion: true))
        self.run(music, withKey: "music")
    }
    
    /// Scene call this function to mute properties.
    ///
    /// - Parameter type: List of types to mute
    func mute(_ type: SoundTypes){
        switch type {
        case .action:
            self.isMutedAction = true
        case .music:
            self.isMutedMusic = true
            self.removeAction(forKey: "music")
        }
    }
    
    class func shared() -> SoundManager {
        return sharedSoundManager
    }
}
