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

struct Line {
	
//	var end1, end2: Point
	var pt1, pt2: Int
	
	var side: [Side?]
	
	var flags: Int
	var special: Int
	var tag: Int
	var selected: Int = 0
	
	// TODO: - var length
	var midpoint: NSPoint
//		let x = (end1.coord.x + end2.coord.x) / 2
//		let y = (end1.coord.y + end2.coord.y) / 2
//		return CGPoint(x: x, y: y)

	/// The point at the end of the 'tick mark' of a line
	var normal: NSPoint
//		let dx = Double(end2.coord.x - end1.coord.x)
//		let dy = Double(end2.coord.y - end1.coord.y)
//		let length = CGFloat(sqrt(dx*dx + dy*dy) / Double(LINE_NORMAL_LENGTH))
//
//		let normalX = midpoint.x + CGFloat(dy)/length
//		let normalY = midpoint.y - CGFloat(dx)/length
//
//		return NSPoint(x: normalX, y: normalY)

	
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
//		end1 = Point()
//		end2 = Point()
		pt1 = 0
		pt2 = 0
		flags = 0
		special = 0
		tag = 0
		midpoint = NSPoint()
		normal = NSPoint()
	}
}
