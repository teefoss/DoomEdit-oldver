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
	var coord = NSPoint()
	/// -1: deleted, 0: unselected, 1: selected
	var selected: Int = 0
	/// The number of lines connected to this point
	var refcount: Int = 0	// when 0, remove it
}

struct Side {
	var x_offset: Int = 0
	var y_offset: Int = 0
	var middleTexture: String?
	var upperTexture: String?
	var lowerTexture: String?
	var ends = SectorDef()
	var sector: Int = -1
}

struct Sector {
	var def = SectorDef()
	var lines: [Int] = []
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

struct Texture {
	var WADindex: Int = 0
	var name: String = ""
	var width: Int = 0
	var height: Int = 0
}






















