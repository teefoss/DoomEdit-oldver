//
//  WorldObjects.swift
//  DoomEdit
//
//  Created by Thomas Foster on 9/18/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//
//  Points, Lines, Sectors, Things, etc.
//

import Cocoa

struct Point {
	var coord: NSPoint
	var isSelected: Bool
	
	init() {
		coord = NSPoint()
		isSelected = false
	}
}

struct Side {

	var x_offset: Int
	var y_offset: Int
	var middleTexture: String?
	var upperTexture: String?
	var lowerTexture: String?
	var ends: SectorDef
	var sector: Int
	
	init() {
		x_offset = 0
		y_offset = 0
		ends = SectorDef()
		sector = 0
	}
}

struct Line {

	var pt1, pt2: Point

	var front: Side
	var back: Side?
	
	var flags: Int
	var special: Int
	var tag: Int

	// TODO: - var length
	var midpoint: NSPoint {
			let x = (pt1.coord.x + pt2.coord.x) / 2
			let y = (pt1.coord.y + pt2.coord.y) / 2
			return CGPoint(x: x, y: y)
	}
	/// The point at the end of the 'tick mark' of a line
	var normal: NSPoint {
		let dx = Double(pt2.coord.x - pt1.coord.x)
		let dy = Double(pt2.coord.y - pt1.coord.y)
		let length = CGFloat(sqrt(dx*dx + dy*dy) / Double(lineNormalLength))
		
		let normalX = midpoint.x + CGFloat(dy)/length
		let normalY = midpoint.y - CGFloat(dx)/length
		
		return NSPoint(x: normalX, y: normalY)
	}
	var isSelected: Bool
	var ref: Int
	
	var color: NSColor {
		if special != 0 {
			return Color.lineSpecial
		} else if back != nil {
			return Color.lineTwoSided
		}
		return NSColor.black
	}
	
	init() {
		pt1 = Point()
		pt2 = Point()
		front = Side()
		flags = 0
		special = 0
		tag = 0
		isSelected = false
		ref = 0
	}
}


struct Sector {
	var def: SectorDef
	var lines: [Line]
}

struct SectorDef {
	var ceilingFlat, floorFlat: String
	var ceilingHeight, floorHeight: Int
	var lightLevel: Int
	var special, tag: Int
	
	init() {
		ceilingFlat = ""
		floorFlat = ""
		ceilingHeight = 0
		floorHeight = 0
		lightLevel = 0
		special = 0
		tag = 0
	}
}



struct Thing {

	var isSelected: Bool

	var origin: NSPoint
	var angle: Int
	var type: Int
	var options: Int
	var size: NSSize
	
	init() {
		isSelected = false
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
			return .gray
		}
	}
	
	

}






















