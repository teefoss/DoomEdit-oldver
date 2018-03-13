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


