//
//  PlayerDefaults.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 28/03/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//
import Foundation

fileprivate enum UserDefaultKeys: String {
    case playerAlias = "playerAlias"
    case isSoundEnabled = "isSoundEnabled"
    case isControlsVisible = "isControlsVisible"
}

struct PlayerDefaults {
    static var playerAlias: String {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultKeys.playerAlias.rawValue) ?? ""
        }
        
        set (value) {
            UserDefaults.standard.set(value, forKey: UserDefaultKeys.playerAlias.rawValue)
        }
    }
    
    static var isSoundEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultKeys.isSoundEnabled.rawValue)
        }
        
        set (value) {
            UserDefaults.standard.set(value, forKey: UserDefaultKeys.isSoundEnabled.rawValue)
        }
    }
    
    static var isControlsVisible: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultKeys.isControlsVisible.rawValue)
        }
        
        set (value) {
            UserDefaults.standard.set(value, forKey: UserDefaultKeys.isControlsVisible.rawValue)
        }
    }
}
