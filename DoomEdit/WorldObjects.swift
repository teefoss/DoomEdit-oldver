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



struct Sector {
	var def = SectorDef()
	var lines: [Int] = []
}



struct SectorDef: Equatable {
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
	
	static func == (l: SectorDef, r: SectorDef) -> Bool {
		return l.ceilingFlat == r.ceilingFlat &&
			   l.floorFlat == r.floorFlat &&
			   l.ceilingHeight == r.ceilingHeight &&
			   l.floorHeight == r.floorHeight &&
			   l.lightLevel == r.lightLevel &&
			   l.special == r.special &&
			   l.tag == r.tag
	}
}



struct Flat {
	var image = NSImage()
	var name: String = ""
	var index: Int = 0
}






















