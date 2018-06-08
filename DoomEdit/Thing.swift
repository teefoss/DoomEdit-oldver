//
//  Thing.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/2/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

// Flags

let SKILL_EASY = 1
let SKILL_NORMAL = 2
let SKILL_HARD = 4
let AMBUSH = 8
let NETWORK = 16

struct Thing {
	
	var selected: Int = 0

	var origin = NSPoint()
	var angle: Int = 0
	var type: Int = 0
	var options: Int = 0
	var def: ThingDef {
		for def in doomData.thingDefs {
			if def.type == type {
				return def
			}
		}
		return ThingDef()
	}
	
	func hasOption(_ option: Int) -> Bool {
		if self.options & option != 0 {
			return true
		}
		return false
	}
}

struct ThingDef {
	var type: Int = 0
	var name: String = ""
	var category: String = ""
	var size: Int = 0
	var game: Int = 0
	var spriteName: String = ""
	var image: NSImage? {
		for sprite in wad.sprites {
			if sprite.name == spriteName {
				return sprite.image
			}
		}
		return nil
	}
	var color: NSColor {
		switch category {
		case "Player": return .systemGreen
		case "Demon": return currentStyle.monsters
		case "Power": return .systemBlue
		case "Ammo": return .systemOrange
		case "Health": return .systemYellow
		case "Armor": return .systemYellow
		case "Card": return .systemPurple
		case "Weapon": return .systemBrown
		case "Gore": return .darkGray
		case "Dead": return .darkGray
		case "Decor": return .lightGray
		case "Light": return .lightGray
		case "Other": return .systemPink
		default: return .systemPink
		}
	}
	var hasDirection: Bool {
		switch category {
		case "Player": return true
		case "Demon": return true
		case "Other": return true
		default: return false
		}
	}
	
}

