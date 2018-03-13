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

/// old version of selection box (three-method approach)
/*
func dragBox_LMDown(with event: NSEvent) {
startPoint = convert(event.locationInWindow, from: nil)
shapeLayer = CAShapeLayer()
shapeLayer.lineWidth = SELECTION_BOX_WIDTH
shapeLayer.fillColor = NSColor.clear.cgColor
shapeLayer.strokeColor = NSColor.gray.cgColor
self.layer?.addSublayer(shapeLayer)
didDragSelectionBox = true
shouldDragSelectionBox = false
}

func dragBox_LMDragged(with event: NSEvent) {
let dragPoint = convert(event.locationInWindow, from: nil)
let path = CGMutablePath()
path.move(to: NSPoint(x: startPoint.x, y: startPoint.y))
path.addLine(to: NSPoint(x: dragPoint.x, y: startPoint.y))
path.addLine(to: NSPoint(x: dragPoint.x, y: dragPoint.y))
path.addLine(to: NSPoint(x: startPoint.x, y: dragPoint.y))
path.closeSubpath()
let pt1 = convert(startPoint, to: superview)
let pt2 = convert(dragPoint, to: superview)
makeRect(&selectionBox, with: pt1, and: pt2)
shapeLayer.path = path
}

func dragBox_LMUp() {
selectObjectsInBox()
shapeLayer.removeFromSuperlayer()
shapeLayer = nil
didDragSelectionBox = false
selectionBox = NSRect.zero
}
*/

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


