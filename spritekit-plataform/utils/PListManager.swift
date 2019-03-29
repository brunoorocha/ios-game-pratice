//
//  PListManager.swift
//  spritekit-plataform
//
//  Created by Guilherme Colombini on 09/03/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import Foundation
import UIKit

class PListManager {
	static func loadArena(with name: String) -> Arena {
		let plistData = self.openFile(name)
		
		let slotsData = plistData!["playerSlots"] as! [Any]
		let slots = self.loadSlots(slotsData)
		let platformsData = plistData!["platforms"] as! [Any]
		let platforms = self.loadPlatforms(platformsData)
		let gameMode = plistData!["mode"] as! String
		let environmentData = plistData!["environment"] as! [String: Any]
		
		let floor = environmentData["floor"] as! String
		let propData = environmentData["prop"] as! [String: Any]
		let prop = self.loadProp(propData)
		let background = environmentData["background"] as! [String]
		
		let arena = Arena(slots: slots, platforms: platforms, mode: gameMode, background: background, floor: floor, prop: prop)
		return arena
	}
	
	static func openFile(_ name: String) -> [String: Any]? {
		var format = PropertyListSerialization.PropertyListFormat.xml //format of the property list
		let plistPath: String? = Bundle.main.path(forResource: name, ofType: "plist")! //the path of the data
		let plistXML = FileManager.default.contents(atPath: plistPath!)! //the data in XML format
		do{ //convert the data to a dictionary and handle errors.
			let plistData = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &format) as! [String: Any]
			
			return plistData
		}
		catch{ // error condition
			print("Error reading plist: \(error), format: \(format)")
			
			return nil
		}
	}
	
	static func loadSlots(_ array: [Any]) -> [CGPoint] {
		var slots: [CGPoint] = []
		
		array.forEach { (dictionary) in
			let slot = dictionary as! [String: Double]
			let point = CGPoint(x: slot["positionX"]!, y: slot["positionY"]!)
			slots.append(point)
		}
		
		return slots
	}
	
	static func loadPlatforms(_ array: [Any]) -> [Platform] {
		var platforms: [Platform] = []
		
		array.forEach { (element) in
			let dictionary = element as! [String: Any]
			let platform = Platform(with: dictionary)
			platforms.append(platform)
		}
		
		return platforms
	}
	
	static func loadProp(_ dictionary: [String: Any]) -> Prop {
		let positionX = dictionary["positionX"] as! Double
		let positionY = dictionary["positionY"] as! Double
		let position = CGPoint(x: positionX, y: positionY)
		let scale = dictionary["scale"] as! CGFloat
		let atlas = dictionary["atlas"] as! String
		
		return Prop(scale: scale, position: position, atlas: atlas)
	}
}
