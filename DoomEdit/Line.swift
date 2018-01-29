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
	var side: [Side?]	// side[0] front, side[1] back
	var flags: Int
	var special: Int
	var tag: Int
	var selected: Int = 0
	
	// TODO: - var length
	var midpoint: NSPoint

	/// The point at the end of the 'tick mark' of a line
	var normal: NSPoint

	var color: NSColor {
		if special != 0 {
			return Color.lineSpecial
		} else if flags & TWO_SIDED == TWO_SIDED {
			return Color.lineTwoSided
		}
		return Color.lineOneSided
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
