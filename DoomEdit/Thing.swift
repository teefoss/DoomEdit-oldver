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
	
	var isSelected: Bool = false
	
	var origin: NSPoint
	var angle: Int
	var type: Int
	var options: Int
	var size: NSSize
	
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
}
