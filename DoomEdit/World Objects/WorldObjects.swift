//
//  WorldObjects.swift
//  DoomEdit
//
//  Created by Thomas Foster on 9/18/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//
//  Points, Sides, Sectors, etc.
//

import Cocoa

struct Point {
	var coord: NSPoint
	var isSelected: Bool
	var hovering: Bool
	
	init() {
		coord = NSPoint()
		isSelected = false
		hovering = false
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






















