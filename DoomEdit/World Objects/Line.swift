//
//  Line.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/2/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

struct Line {
	
	var end1, end2: Point
	var pt1, pt2: Int
	
	var front: Side
	var back: Side?
	
	var flags: Int
	var special: Int
	var tag: Int
	
	var isSelected: Bool
	
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
		} else if back != nil {
			return Color.lineTwoSided
		}
		return NSColor.black
	}
	
	init() {
		end1 = Point()
		end2 = Point()
		pt1 = 0
		pt2 = 0
		front = Side()
		flags = 0
		special = 0
		tag = 0
		isSelected = false
		midpoint = NSPoint()
		normal = NSPoint()
	}
}
