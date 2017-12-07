//
//  Line.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/2/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

struct Line {
	
	var pt1, pt2: Point
	
	var front: Side
	var back: Side?
	
	var flags: Int
	var special: Int
	var tag: Int
	
	var isSelected: Bool
	/// A reference number for the line. Used so that points can hold a reference to each line it connects to.
	var ref: Int
	
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
