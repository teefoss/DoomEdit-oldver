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
	
	var origin: NSPoint
	var angle: Int
	var type: Int
	var options: Int
	var size: NSSize
	
	var hasDirection: Bool {
		switch type {
		case 1, 2, 3, 4, 11: // player
			return true
		case 68, 64, 3003, 3305, 65, 72, 16, 3002, 3004, 9, 69, 3001, 3006, 67, 71, 66, 58, 7, 84:
			return true
		case 14: // teleport destination
			return true
		default:
			return false
		}
	}
	
	init() {
		origin = NSPoint()
		angle = 0
		type = 0
		options = 0
		size = NSSize()
	}
	
	
	enum Category {
		case player			// Green
		case monster
		case ammo
		case artifact
		case powerup
		case key
		case weapon
		case obstacle
		case decoration
		case other
	}
	
	var category: Category {
		switch type {
		case 1, 2, 3, 4, 11:
			return .player
		case 2023, 2026, 2014, 2024, 2022, 2045, 83, 2013, 2015:
			return .artifact
		case 8, 2019, 2018, 2012, 2025, 2011:
			return .powerup
		case 2006, 2002, 2005, 2004, 2003, 2001, 82:
			return .weapon
		case 2007, 2048, 2046, 2049, 2047, 17, 2010, 2008:
			return .ammo
		case 5, 40, 13, 38, 6, 39:
			return .key
		case 68, 64, 3003, 3305, 65, 72, 16, 3002, 3004, 9, 69, 3001, 3006, 67, 71, 66, 58, 7, 84:
			return .monster
		case 2035, 70, 43, 35, 41, 28, 42, 2028, 53, 52, 78, 75, 77, 76, 50, 74, 73, 51, 49, 25, 54, 29, 55, 56, 31, 36, 57, 33, 37, 86, 27, 47, 44, 45, 30, 46, 32, 85, 48, 26:
			return .obstacle
		case 10, 12, 34, 22, 21, 18, 19, 20, 23, 15, 62, 60, 59, 61, 63, 79, 80, 24, 81:
			return .decoration
		case 88, 89, 87, 14:
			return .other
		default:
			return .other
		}
	}
	
	var color: NSColor {
		switch category {
		case .player:
			return .systemGreen
		case .monster:
			return .black
		case .artifact:
			return .systemBlue
		case .ammo:
			return .systemOrange
		case .powerup:
			return .systemYellow
		case .key:
			return .systemPurple
		case .weapon:
			return .systemBrown
		case .obstacle:
			return .darkGray
		case .decoration:
			return .lightGray
		case .other:
			return .systemPink
		}
	}
	
	var name: String {
		switch type {
		case 2023: return "Berserk"
		case 2026: return "Computer Map"
		case 2014: return "Health Potion"
		case 2024: return "Invisibility"
		case 2022: return "Invulnerability"
		case 2045: return "Light Amplification Visor"
		case 83: return "Megasphere"
		case 2013: return "Soul Sphere"
		case 2015: return "Armor Bonus"
		case 8: return "Backpack"
		case 2019: return "Blue Armor"
		case 2018: return "Green Armor"
		case 2012: return "Medkit"
		case 2025: return "Radiation Suit"
		case 2011: return "Stimpack"
		case 2006: return "BFG 9000"
		case 2002: return "Chaingun"
		case 2005: return "Chainsaw"
		case 2004: return "Plasma Rifle"
		case 2003: return "Rocket Launcher"
		case 2001: return "Shotgun"
		case 82: return "Super Shotgun"
		case 2007: return "Ammo Clip"
		case 2048: return "Box of Ammo"
		case 2046: return "Box of Rockets"
		case 2049: return "Box of Shells"
		case 2047: return "Cell Charge"
		case 17: return "Cell Charge Pack"
		case 2010: return "Rocket"
		case 2008: return "Shotgun Shells"
		case 5: return "Blue Keycard"
		case 40: return "Blue Skull Key"
		case 13: return "Red Keycard"
		case 38: return "Red Skull Key"
		case 6: return "Yellow Keycard"
		case 39: return "Yellow Skull Key"
		case 68: return "Arachnotron"
		case 64: return "Arch-Vile"
		case 3003: return "Baron of Hell"
		case 3005: return "Cacodemon"
		case 65: return "Heavy Weapon Dude"
		case 72: return "Commander Keen"
		case 16: return "Cyberdemon"
		case 3002: return "Demon"
		case 3004: return "Zombieman"
		case 9: return "Shotgun Guy"
		case 69: return "Hell Knight"
		case 3001: return "Imp"
		case 3006: return "Lost Soul"
		case 67: return "Mancubus"
		case 71: return "Pain Elemental"
		case 66: return "Revenant"
		case 58: return "Spectre"
		case 7: return "Spider Mastermind"
		case 84: return "Wolfenstein SS"
		case 1: return "Player 1 Start"
		case 2: return "Player 2 Start"
		case 3: return "Player 3 Start"
		case 4: return "Player 4 Start"
		case 11: return "Deathmatch Start"
		case 14: return "Teleport Destination"
		default: return "It's F@#ked!!"

		}
	}
		
		
		var imageName: String {
			switch type {
			case 2023: return "PSTR"
			case 2026: return "PMAP"
			case 2014: return "BON1"
			case 2024: return "PINS"
			case 2022: return "PINV"
			case 2045: return "PVIS"
			case 83: return "MEGA"
			case 2013: return "SOUL"
			case 2015: return "BON2"
			case 8: return "BPAK"
			case 2019: return "ARM2"
			case 2018: return "ARM1"
			case 2012: return "MEDI"
			case 2025: return "SUIT"
			case 2011: return "STIM"
			case 2006: return "BFUG"
			case 2002: return "MGUN"
			case 2005: return "CSAW"
			case 2004: return "PLAS"
			case 2003: return "LAUN"
			case 2001: return "SHOT"
			case 82: return "SGN2"
			case 2007: return "CLIP"
			case 2048: return "AMMO"
			case 2046: return "BROK"
			case 2049: return "SBOX"
			case 2047: return "CELL"
			case 17: return "CELP"
			case 2010: return "ROCK"
			case 2008: return "SHEL"
			case 5: return "BKEY"
			case 40: return "BSKU"
			case 13: return "RKEY"
			case 38: return "RSKU"
			case 6: return "YKEY"
			case 39: return "YSKU"
			case 68: return "BSPIA1"
			case 64: return "VILEA1"
			case 3003: return "BOSSA1"
			case 3005: return "HEADA1"
			case 65: return "CPOSA1"
			case 72: return "KEEN"
			case 16: return "CYBRA1"
			case 3002: return "SARGA1"
			case 3004: return "POSSA1"
			case 9: return "SPOSA1"
			case 69: return "BOS2A1"
			case 3001: return "TROOA1"
			case 3006: return "SKULA1"
			case 67: return "FATTA1"
			case 71: return "PAINA1"
			case 66: return "SKELA1"
			case 58: return "SARGA1"
			case 7: return "SPIDA1D1"
			case 84: return "SSWVA1"
			case 1: return "PLAYA1"
			case 2: return "PLAYA1"
			case 3: return "PLAYA1"
			case 4: return "PLAYA1"
			case 11: return "PLAYA1"
			case 14: return "PLAYA1"
			default: return "It's F@#ked!!"
				
			}
	}
	
}
