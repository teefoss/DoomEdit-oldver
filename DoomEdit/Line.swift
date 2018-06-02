//
//  Line.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/2/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

let BLOCKS_ALL = 1
let BLOCKS_MONSTERS = 2
let TWO_SIDED = 4
let UPPER_UNPEGGED = 8
let LOWER_UNPEGGED = 16
let SECRET = 32
let BLOCKS_SOUND = 64
let NOT_ON_MAP = 128
let SHOW_ON_MAP = 256

struct Side {
	var x_offset: Int = 0
	var y_offset: Int = 0
	var middleTexture: String?
	var upperTexture: String?
	var lowerTexture: String?
	var ends = SectorDef()
	var sector: Int = -1
}

struct Line {
	
	var pt1, pt2: Int
	var side:     [Side?]	// side[0] front, side[1] back
	var flags:    Int
	var special:  Int
	var tag:      Int
	var selected: Int = 0
	var sectorCopy: Bool
	var sectorPaste: Bool
	
	var length: Int {
		var xlen = abs(points[pt2].coord.x - points[pt1].coord.x)
		xlen = xlen * xlen
		var ylen = abs(points[pt2].coord.y - points[pt1].coord.y)
		ylen = ylen * ylen
		return Int(sqrt(xlen + ylen))
	}
	var midpoint:   NSPoint
	var normal:     NSPoint	 // The point at the end of the 'tick mark' of a line
	
	var checkNormal: NSPoint // Used in connectSector
	var backNormal: NSPoint  // The point on the opposite side from the normal (backside)

	var color: NSColor {
		if special != 0 {
			return Color.lineSpecial
		} else if flags & TWO_SIDED != 0 {
			return Color.lineTwoSided
		}
		return COLOR_LINE_ONESIDED
	}
	
	init() {
		side = Array(repeating: nil, count: 2)
		pt1 = 0
		pt2 = 0
		flags = 0
		special = 0
		tag = 0
		midpoint = NSPoint()
		normal = NSPoint()
		backNormal = NSPoint()
		checkNormal = NSPoint()
		sectorCopy = false
		sectorPaste = false
	}

	func hasOption(_ option: Int) -> Bool {
		return (flags & option != 0) ? true : false
	}
}

enum LineSpecialType {
	case button
	case effect
	case impact
	case manual
	case retrigger
	case swtch
	case trigger
}

enum LineSpecialCategory {
	case door
	case ceiling
	case floor
	case lift
	case lights
	case teleport
	case stairs
	case exit
	case crush
}

struct LineSpecial {
	
	var index: Int = 0
	var type: String = ""
	var name: String = ""
}
