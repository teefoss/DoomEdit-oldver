//
//  Geometry.swift
//  DoomEdit
//
//  Created by Thomas Foster on 11/18/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Foundation

struct Box {
	var left: CGFloat = 0
	var bottom: CGFloat = 0
	var right: CGFloat = 0
	var top: CGFloat = 0
}

func makeBox(box: inout Box, from rect: NSRect) {
	
	box.left = rect.minX
	box.right = rect.maxX
	box.bottom = rect.minY
	box.top = rect.maxY
	
}

func makeBox(from box: inout Box, with pt1: NSPoint, and pt2: NSPoint) {
	
	if pt1.x < pt2.x {
		box.left = pt1.x
		box.right = pt2.x
	} else {
		box.right = pt1.x
		box.left = pt2.x
	}
	
	if pt1.y < pt2.y {
		box.bottom = pt1.y
		box.top = pt2.y
	} else {
		box.top = pt1.y
		box.bottom = pt2.y
	}
}

/// Transforms given rect to just touch given points
func makeRect(from rect: inout NSRect, with pt1: NSPoint, and pt2: NSPoint) {
	
	if pt1.x < pt2.x {
		rect.origin.x = pt1.x
		rect.size.width = pt2.x - pt1.x + 1
	} else {
		rect.origin.x = pt2.x
		rect.size.width = pt1.x - pt2.x + 1
	}
	
	if pt1.y < pt2.y {
		rect.origin.y = pt1.y
		rect.size.height = pt2.y - pt1.y + 1
	} else {
		rect.origin.y = pt2.y
		rect.size.height = pt1.y - pt2.y + 1
	}
	
}

func enclosePoint(rect: inout NSRect, point: NSPoint) {
	
	var right: CGFloat = 0
	var top: CGFloat = 0
	
	right = rect.maxX - 1
	top = rect.maxY - 1
	
	if point.x < rect.origin.x {
		rect.origin.x = point.x
	}
	if point.y < rect.origin.y {
		rect.origin.y = point.y
	}
	if point.x > right {
		right = point.x
	}
	if point.y > top {
		top = point.y
	}
	
	rect.size.width = right - rect.origin.x + 1
	rect.size.height = top - rect.origin.y + 1
}

infix operator <->

extension NSPoint {
	
	static func <-> (left: NSPoint, right: NSPoint) -> CGFloat {
		return sqrt(pow(left.x - right.x, 2) + pow(left.y - right.y, 2))
	}
	
}


