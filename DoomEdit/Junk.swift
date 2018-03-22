//
//  Junk.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/18/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Foundation

/**
Stuff that didn't work, but save it just in case, or old versions.
*/

// From WadFile, patchToImage
/*
for i in 0..<width {
	
	var data = Int(patchInfo.columnOffset[i])
	
	repeat {
		let topdelta = patchData[data]
		data += 1
		if topdelta == 255 {
			break
		}
		var count = patchData[data]; data += 1
		var index = (Int(topdelta)*width+i)*4; data += 1
		while count != 0 {
			count -= 1
			let bytes = patchToRGB(patchData[data], palette: palette)
			dest.insert(contentsOf: bytes, at: index)
			index += width*4
		}
		data += 1
		
	} while true
}
*/

/// ==============
//  MARK: pointers
/*
let ptr = UnsafeMutablePointer<Point>.allocate(capacity: points.count)
defer { ptr.deallocate(capacity: points.count) }

let buf = UnsafeMutableBufferPointer(start: ptr, count: points.count)

for (i, _) in buf.enumerated() {
if buf[i].selected == 1 {
buf[i].coord.x += moved.x
buf[i].coord.y += moved.y
}
}
*/

/// version that uses linecross
// MARK: drawLines(in:)
/*
func drawLines(in rect: NSRect) {

let offset: CGFloat = 0.5
var xc = 0; var yc = 0
var clippoint: [Int] = Array(repeating: 0, count: points.count)

let left = rect.origin.x-1
let bottom = rect.origin.y-1
let right = rect.origin.x + rect.size.width+2
let top = rect.origin.y + rect.size.height+2

for p in 0..<points.count {
if points[p].selected == -1 {
continue
}

if points[p].coord.x < left {
xc = 0
} else if points[p].coord.x > right {
xc = 2
} else {
xc = 1
}

if points[p].coord.y < bottom {
yc = 0
} else if points[p].coord.y > top {
yc = 2
} else {
yc = 1
}
clippoint[p] = yc*3+xc
}

// only draw lines that might intersect the visible rect

for line in lines {
if line.selected == -1 {
continue
}
if !lineCross[clippoint[line.pt1]][clippoint[line.pt2]] {
continue
}

if line.selected > 0 {
NSColor.red.set()
} else {
line.color.set()
}

if points[line.pt1].coord.x != points[line.pt2].coord.x ||
points[line.pt1].coord.y != points[line.pt2].coord.y
{
let pt1 = convert(NSPoint(x: points[line.pt1].coord.x-offset, y: points[line.pt1].coord.y-offset), from: superview)
let pt2 = convert(NSPoint(x: points[line.pt2].coord.x-offset, y: points[line.pt2].coord.y-offset), from: superview)
let midPt = convert(line.midpoint, from: superview)
let normPt = convert(line.normal, from: superview)
let midPtx = midPt.x - offset
let midPty = midPt.y - offset
let newMidPt = NSPoint(x: midPtx, y: midPty)
let normPtx = normPt.x - offset
let normPty = normPt.y - offset
let newNormPt = NSPoint(x: normPtx, y: normPty)

NSBezierPath.defaultLineWidth = LINE_WIDTH
NSBezierPath.strokeLine(from: pt1, to: pt2)			// line
NSBezierPath.strokeLine(from: newMidPt, to: newNormPt)	// line normal 'tick'
}
}
}
*/

// MARK: polyLine(event:)
/*
func polyLine(_ event: NSEvent) {
	
	var fixedpoint, dragpoint: NSPoint
	let shapelayer = CAShapeLayer()
	
	fixedpoint = getGridPoint(from: event)
	shapelayer.lineWidth = 1.0
	shapelayer.fillColor = NSColor.clear.cgColor
	shapelayer.strokeColor = COLOR_LINE_ONESIDED.cgColor
	layer?.addSublayer(shapelayer)
	
	var nextevent: NSEvent?
	var oldmask: NSEvent?
	repeat {
		nextevent = window?.nextEvent(matching: NSEvent.EventTypeMask.leftMouseUp)
	} while nextevent?.type != .leftMouseUp
	
	repeat {
		fixedpoint = getGridPoint(from: nextevent!)
		oldmask = window?.nextEvent(matching: NSEvent.EventTypeMask.mouseMoved)
		
		repeat {
			nextevent = window?.nextEvent(matching: NSEvent.EventTypeMask.leftMouseDown.union(.leftMouseUp).union(.mouseMoved).union(.leftMouseDragged))
			dragpoint = getGridPoint(from: nextevent!)
			if nextevent?.type == .leftMouseUp {
				break
			}
			
			let path = CGMutablePath()
			path.move(to: fixedpoint)
			path.addLine(to: dragpoint)
			shapelayer.path = path
		} while true
		
		// add to the world
		if dragpoint.x == fixedpoint.x && dragpoint.y == fixedpoint.y {
			break
		}
		
		addLine(from: fixedpoint, to: dragpoint)
		if pointOutsideRect(fixedpoint, frame) || pointOutsideRect(dragpoint, frame) {
			frame = editWorld.getBounds()
			bounds = frame
		}
		editWorld.updateWindows()
		doomProject.setDirtyMap(true)
	} while true
}

// MARK: dragLine(event:)
func dragLine(_ event: NSEvent) {
	// TODO: Draw the 'tick' mark while adding a line
	
	var fixedPoint, dragPoint: NSPoint
	let shapeLayer = CAShapeLayer()
	
	editWorld.deselectAll()
	
	fixedPoint = getGridPoint(from: event)
	shapeLayer.lineWidth = 1.0
	shapeLayer.fillColor = NSColor.clear.cgColor
	shapeLayer.strokeColor = COLOR_LINE_ONESIDED.cgColor
	layer?.addSublayer(shapeLayer)
	
	//
	// Mouse-tracking loop
	//
	
	var nextEvent: NSEvent?
	repeat {
		nextEvent = window?.nextEvent(matching: NSEvent.EventTypeMask.leftMouseDragged.union(.leftMouseUp))
		dragPoint = getGridPoint(from: nextEvent!)
		
		let path = CGMutablePath()
		path.move(to: fixedPoint)
		path.addLine(to: dragPoint)
		shapeLayer.path = path
		
	} while nextEvent?.type != .leftMouseUp
	
	if dragPoint.x == fixedPoint.x && dragPoint.y == fixedPoint.y {
		return
	}
	
	editWorld.deselectAll()
	shapeLayer.removeFromSuperlayer()
	addLine(from: fixedPoint, to: dragPoint)
	
	if pointOutsideRect(fixedPoint, frame) || pointOutsideRect(dragPoint, frame) {
		frame = editWorld.getBounds()
		bounds = frame
	}
	//		var updateRect = NSRect()
	//		makeRect(&updateRect, with: fixedPoint, and: dragPoint)
	//		setNeedsDisplay(updateRect)
	editWorld.updateWindows()
	doomProject.mapDirty = true
}
*/

