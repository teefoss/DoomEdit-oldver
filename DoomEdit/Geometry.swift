//
//  Geometry.swift
//  DoomEdit
//
//  Created by Thomas Foster on 11/18/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

struct Box {
	var left: CGFloat = 0
	var bottom: CGFloat = 0
	var right: CGFloat = 0
	var top: CGFloat = 0
}

func makeBox(_ box: inout Box, from rect: NSRect) {
	
	box.left = rect.minX
	box.right = rect.maxX
	box.bottom = rect.minY
	box.top = rect.maxY
	
}

func makeBox(_ box: inout Box, with pt1: NSPoint, and pt2: NSPoint) {
	
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
func makeRect(_ rect: inout NSRect, with pt1: NSPoint, and pt2: NSPoint) {
	
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
	
//	var right: CGFloat = rect.maxX - 1
//	var top: CGFloat = rect.maxY - 1

	var right = rect.origin.x + rect.size.width - 1
	var top = rect.origin.y + rect.size.height - 1
	
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



// Copied from https://en.wikipedia.org/wiki/Cohen%E2%80%93Sutherland_algorithm
// with minor alterations to include given rect and return Bool

typealias OutCode = Int
fileprivate let INSIDE: Int = 0 // 0000
fileprivate let LEFT: Int = 1 // 0001
fileprivate let RIGHT: Int = 2 // 0010
fileprivate let BOTTOM: Int = 4 // 0100
fileprivate let TOP: Int = 8 // 1000

// Compute the bit code for a point (x, y) using the clip rectangle
// bounded diagonally by (xmin, ymin), and (xmax, ymax)
// ASSUME THAT xmax, xmin, ymax and ymin are global constants.
fileprivate func ComputeOutCode(_ x: CGFloat, _ y: CGFloat, _ rect: NSRect) -> OutCode {
    var code: OutCode
    code = INSIDE
    // initialised as being inside of [[clip window]]
    if x < rect.minX {
        // to the left of clip window
        code |= LEFT
    }
    else if x > rect.maxX {
        // to the right of clip window
        code |= RIGHT
    }
    if y < rect.minY {
        // below the clip window
        code |= BOTTOM
    }
    else if y > rect.maxY {
        // above the clip window
        code |= TOP
    }
    return code
}

func lineInRect(_ line: Line, _ rect: NSRect) -> Bool {
	var x0 = points[line.pt1].coord.x
	var y0 = points[line.pt1].coord.y
	var x1 = points[line.pt2].coord.x
	var y1 = points[line.pt2].coord.y
	
	return lineInRect(x0: &x0, y0: &y0, x1: &x1, y1: &y1, rect: rect)
}

// Cohen–Sutherland clipping algorithm clips a line from
// P0 = (x0, y0) to P1 = (x1, y1) against a rectangle with
// diagonal from (xmin, ymin) to (xmax, ymax).
func lineInRect(x0: inout CGFloat, y0: inout CGFloat, x1: inout CGFloat, y1: inout CGFloat, rect: NSRect) -> Bool {
        // compute outcodes for P0, P1, and whatever point lies outside the clip rectangle
    var outcode0 = ComputeOutCode(x0, y0, rect)
    var outcode1 = ComputeOutCode(x1, y1, rect)
    var accept = false
    while true {
        if outcode0 | outcode1 == 0 {
            // Bitwise OR is 0. Trivially accept and get out of loop
            accept = true
            break
        }
        else if outcode0 & outcode1 != 0 {
            // Bitwise AND is not 0. (implies both end points are in the same region outside the window). Reject and get out of loop
            break
        }
        else {
                // failed both tests, so calculate the line segment to clip
                // from an outside point to an intersection with clip edge
            var x = CGFloat()
            var y = CGFloat()
                // At least one endpoint is outside the clip rectangle; pick it.
            let outcodeOut: OutCode = outcode0 != 0 ? outcode0 : outcode1
            // Now find the intersection point;
            // use formulas:
            //   slope = (y1 - y0) / (x1 - x0)
            //   x = x0 + (1 / slope) * (ym - y0), where ym is ymin or ymax
            //   y = y0 + slope * (xm - x0), where xm is xmin or xmax
            if outcodeOut & TOP != 0 {
                // point is above the clip rectangle
                x = x0 + (x1 - x0) * (rect.maxY - y0) / (y1 - y0)
                y = rect.maxY
            }
            else if outcodeOut & BOTTOM != 0 {
                // point is below the clip rectangle
                x = x0 + (x1 - x0) * (rect.minY - y0) / (y1 - y0)
                y = rect.minY
            }
            else if outcodeOut & RIGHT != 0 {
                // point is to the right of clip rectangle
                y = y0 + (y1 - y0) * (rect.maxX - x0) / (x1 - x0)
                x = rect.maxX
            }
            else if outcodeOut & LEFT != 0 {
                // point is to the left of clip rectangle
                y = y0 + (y1 - y0) * (rect.minX - x0) / (x1 - x0)
                x = rect.minX
            }
            // Now we move outside point to intersection point to clip
            // and get ready for next pass.
            if outcodeOut == outcode0 {
                x0 = x
                y0 = y
                outcode0 = ComputeOutCode(x0, y0, rect)
            }
            else {
                x1 = x
                y1 = y
                outcode1 = ComputeOutCode(x1, y1, rect)
            }
        }
    }
	if accept {
		return true
	} else {
		return false
	}
}

func pointOutsideRect(_ point: NSPoint, _ rect: NSRect) -> Bool {
	if point.x > rect.maxX || point.x < rect.minX || point.y > rect.maxY || point.y < rect.minY {
		return true
	}
	return false
}













