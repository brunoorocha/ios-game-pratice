//
//  NotificationName.swift
//  spritekit-plataform
//
//  Created by João Paulo de Oliveira Sabino on 28/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import Foundation

extension Notification.Name {
    //notifies the menu scene to present an online game
    static let presentGame = Notification.Name(rawValue: "presentGame")
    //notifies the app of any authentication state changed
    static let authenticationChanged = Notification.Name(rawValue: "authenticationChanged")
}
