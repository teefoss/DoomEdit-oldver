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
	/// A list of the lines connects to this point. These are the same numbers as each `line.ref`
	var ref: [Int]
	
	init() {
		coord = NSPoint()
		isSelected = false
		hovering = false
		ref = []
	}
}

struct Side {

	var x_offset: Int = 0
	var y_offset: Int = 0
	var middleTexture: String?
	var upperTexture: String?
	var lowerTexture: String?
	var ends: SectorDef = SectorDef()
	var sector: Int = 0
	
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






















