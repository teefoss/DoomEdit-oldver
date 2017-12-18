//
//  MapViewResp.swift
//  DoomEdit
//
//  Created by Thomas Foster on 11/12/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//
//  MapView Responder Methods
//

import Cocoa



// Dragging Objects
fileprivate var cursor = NSPoint.zero
fileprivate var oldDragRect = NSRect.zero
fileprivate var fixedRect = NSRect.zero
fileprivate var dragRect = NSRect.zero
fileprivate var currentDragRect = NSRect.zero
fileprivate var updateRect = NSRect.zero
fileprivate var lineList: [Int] = []
fileprivate var lineCount: Int = 0
fileprivate var lastPoint: Int = 0
fileprivate var pointCount: Int = 0
fileprivate var totalMoved = NSPoint.zero




/**
MapView Responder Methods
*/

extension MapView {
	
	override var acceptsFirstResponder: Bool { return true }
	override func becomeFirstResponder() -> Bool { return true }
	override func resignFirstResponder() -> Bool { return true }
	

	
	// ===================
	// MARK: - Key Presses
	// ===================
	
	override func keyDown(with event: NSEvent) {
		
		switch event.keyCode {
		case KEY_MINUS:
			zoomOut(from: event)
		case KEY_EQUALS:
			zoomIn(to: event)
		case KEY_LEFTBRACKET:
			increaseGrid()
		case KEY_RIGHTBRACKET:
			decreaseGrid()
		case KEY_I:
			printCoordInfo()
		case KEY_SPACE:
			toggleDrawMode()
		default: break
		}
	}
	
	/// Grid lines get farther apart
	func increaseGrid() {
		if gridSize < 64 {
			gridSize *= 2
			print("grid size = \(gridSize)")
			needsDisplay = true
		}
	}
	
	/// Grid lines get closer together
	func decreaseGrid() {
		if gridSize > 1 {
			gridSize /= 2
			print("grid size = \(gridSize)")
			needsDisplay = true
		}
	}
	
	// FIXME: When mouse is outside window?
	/// Zooms in on mouse location
	func zoomIn(to event: NSEvent) {
		if scale < 4 {
			scale *= 2
			print("scale = \(scale*100)%")
			let mouseLoc = worldCoord(for: event.locationInWindow)
			delegate?.zoom(to: mouseLoc, with: scale)
			frame = editWorld.getBounds()
		} else {
			NSSound.beep()
		}
	}
	
	/// Zooms out from mouse location
	func zoomOut(from event: NSEvent) {
		if scale > 0.125 {
			scale /= 2
			print("scale = \(scale*100)%")
			let mouseLoc = worldCoord(for: event.locationInWindow)
			delegate?.zoom(to: mouseLoc, with: scale)
			frame = editWorld.getBounds()
		} else {
			NSSound.beep()
		}
	}
	
	
	
	
	// ===========================
	// MARK: - Testing Information
	// ===========================

	func printCoordInfo() {
		print("frame: \(frame)")
		print("frame.origin.x: \(frame.origin.x)")
		print("bounds: \(bounds)")
		print("visibleRect: \(visibleRect)")
		let converted = convert(visibleRect.origin, from: nil)
		print("viz rect origin converted: \(converted)")
	}
	
	
	
	
	// =====================
	// MARK: - Mouse Actions
	// =====================
	
	override func mouseDown(with event: NSEvent) {
		
		
		switch currentMode {
		case .edit:
			selectObject(at: event)
			if shouldDragSelectionBox {
				dragBox_LMDown(with: event)
			}
		case .draw:
			dragLine_LMDown(with: event)
		}
		setNeedsDisplay(bounds)
	}
	
	override func mouseDragged(with event: NSEvent) {
		
		switch currentMode {
		case .edit:
			if didDragSelectionBox {
				dragBox_LMDragged(with: event)
			} else if didDragObject {
				print("object dragged")
				dragObjects_LMDragged(with: event)
			}
		case .draw:
			dragLine_LMDragged(with: event)
		}
	}
	
	override func mouseUp(with event: NSEvent) {
		
		needsDisplay = true
		
		switch currentMode {
		case .edit:
			if didDragSelectionBox {
				dragBox_LMUp()
			} else if didDragObject {
				dragObjects_LMUp(with: event)
				didDragObject = false
			}
		case .draw:
			if didDragLine {
				dragLine_LMUp()
			}
		}
	}
	
	override func rightMouseDown(with event: NSEvent) {

		selectObject(at: event)
		if didClickThing {
			let thingRect = NSRect(x: selectedThing.origin.x-16, y: selectedThing.origin.y-16, width: 32, height: 32)
			let newThingRect = convert(thingRect, from: superview)
			let thingView = NSView(frame: newThingRect)
			self.addSubview(thingView)
			displayThingPopover(at: thingView)
			didClickThing = false
		} else if didClickLine {
			let lineRect = NSRect(x: selectedLine.midpoint.x-16, y: selectedLine.midpoint.y-16, width: 32, height: 32)
			let newLineRect = convert(lineRect, from: superview)
			let lineView = NSView(frame: newLineRect)
			self.addSubview(lineView)
			displayLinePopover(at: lineView)
			didClickLine = false
		} else if didClickSector {
			let pointRect = NSRect(x: event.locationInWindow.x-16, y: event.locationInWindow.y-16, width: 32, height: 32)
			let newPointRect = convert(pointRect, from: nil)
			let pointView = NSView(frame: newPointRect)
			self.addSubview(pointView)
			let clickpoint = worldCoord(for: event.locationInWindow)
			print (clickpoint)
			blockWorld.floodFillSector(from: clickpoint)
			displaySectorPanel(at: pointView)
			didClickSector = false
			setNeedsDisplay(self.bounds)
		}

	}
	
	
	
	// =========================
	// MARK: - Selection Methods
	// =========================
	
	// https://stackoverflow.com/questions/33158513/checking-keydown-event-modifierflags-yields-error
	/// Selects a point at the mouse location. If no point is present, selects a line or thing.
	func selectObject(at event: NSEvent) {
		
		var pointIndex: Int = -1
		var thingIndex: Int = -1
		var pt = Point()
		var left, right, top, bottom: CGFloat  // For a box around the click point
		var clickPoint: NSPoint
		
		clickPoint = worldCoord(for: event.locationInWindow)
		//print("clickPoint: \(clickPoint)")

		//
		// see if the click hit a point
		//

		// TODO: adjust this after zooming fixed
		// set up a box around the click point
		left = clickPoint.x - POINT_SIZE/scale/CGFloat(2)
		right = clickPoint.x + POINT_SIZE/scale/CGFloat(2)
		bottom = clickPoint.y - POINT_SIZE/scale/CGFloat(2)
		top = clickPoint.y + POINT_SIZE/scale/CGFloat(2)
		
		for i in 0..<points.count {
			pt = points[i]
			// if the point is inside the box
			if pt.coord.x > left && pt.coord.x < right &&
				pt.coord.y < top && pt.coord.y > bottom {
				pointIndex = i
				break	// got one, move on
			}
		}
		

		// clicked a point
		if pointIndex >= 0 && pointIndex < points.count {

			// if the point is already selected
			if points[pointIndex].isSelected {
				// shift is not being held
				if !event.modifierFlags.contains(.shift) {
					dragObjects_LMDown(with: event)
//					deselectAll()
					return
				} else {
//					deselectPoint(pointIndex)
					dragObjects_LMDown(with: event)
					return
				}
			// point is not already selected
			} else {
				// shift is not being held
				if !event.modifierFlags.contains(.shift) {
					editWorld.deselectAll()
					editWorld.selectPoint(pointIndex)
					dragObjects_LMDown(with: event)
					return
				} else {
					editWorld.selectPoint(pointIndex)
					dragObjects_LMDown(with: event)
					return
				}
			}
		}
		
		//
		// didn't hit a point, check for a line
		//
		
		for i in 0..<lines.count {
			
			let p1 = lines[i].end1.coord
			let p2 = lines[i].end2.coord
			
			if (p1.x < left && p2.x < left)
			|| (p1.x > right && p2.x > right)		// DoomEd p2.x > left, mistake?
			|| (p1.y > top && p2.y > top)
			|| (p1.y < bottom && p2.y < bottom)
			{
				continue
			}
			

			let layer = CAShapeLayer()
			layer.lineWidth = 32.0
			let path = CGMutablePath()
			path.move(to: p1)
			path.addLine(to: p2)
			layer.path = path
			
			let newPath = path.copy(strokingWithWidth: 32.0, lineCap: .butt, lineJoin: .miter, miterLimit: 1.0)
			
			// Clicked on a line
			if newPath.contains(clickPoint) {
				// line is already selected
				if lines[i].isSelected {
					if !event.modifierFlags.contains(.shift) {
						dragObjects_LMDown(with: event)
						didClickLine = true
						selectedLine = lines[i]
						selectedLineIndex = i
						//deselectAll()
						return
					} else {
						dragObjects_LMDown(with: event)
						didClickLine = true
						selectedLine = lines[i]
						selectedLineIndex = i

						//deselectLine(i)
						return
					}
				// line is not already selected
				} else {
					// shift if not held
					if !event.modifierFlags.contains(.shift) {
						editWorld.deselectAll()
						editWorld.selectLine(i)
						dragObjects_LMDown(with: event)
						didClickLine = true
						selectedLine = lines[i]
						selectedLineIndex = i

						return
					// shift is held
					} else {
						editWorld.selectLine(i)
						dragObjects_LMDown(with: event)
						didClickLine = true
						selectedLine = lines[i]
						selectedLineIndex = i

						return
					}
				}
			}
			
		}
		
		
		//
		// didn't hit a line, check for a thing
		//
		
		left = clickPoint.x - CGFloat(THING_DRAW_SIZE/2)
		right = clickPoint.x + CGFloat(THING_DRAW_SIZE/2)
		bottom = clickPoint.y - CGFloat(THING_DRAW_SIZE/2)
		top = clickPoint.y +  CGFloat(THING_DRAW_SIZE/2)
		
		for i in 0..<things.count {
			
			let thing = things[i]
			if thing.origin.x > left && thing.origin.x < right
				&& thing.origin.y < top && thing.origin.y > bottom {
				thingIndex = i
				break
			}
		}
		
		if thingIndex >= 0 && thingIndex < things.count {

			// Thing is already selected
			if things[thingIndex].isSelected {
				// shift is not being held
				if !event.modifierFlags.contains(.shift) {
					dragObjects_LMDown(with: event)
					didClickThing = true
					selectedThing = things[thingIndex]
					selectedThingIndex = thingIndex
					//deselectAllThings()
					return
				// shift is being held
				} else {
					dragObjects_LMDown(with: event)
					didClickThing = true
					selectedThing = things[thingIndex]
					selectedThingIndex = thingIndex
					//deselectThing(thingIndex)
					return
				}
				
			// Thing is not already selected
			} else {
				if !event.modifierFlags.contains(.shift) {
					editWorld.deselectAll()
					editWorld.selectThing(thingIndex)
					dragObjects_LMDown(with: event)
					didClickThing = true
					selectedThing = things[thingIndex]
					selectedThingIndex = thingIndex

					return
				} else {
					editWorld.selectThing(thingIndex)
					dragObjects_LMDown(with: event)
					didClickThing = true
					selectedThing = things[thingIndex]
					selectedThingIndex = thingIndex
					return
				}
			}
		}

		//
		//  Hit nothing
		//
		if !event.modifierFlags.contains(.shift) {
			editWorld.deselectAll()
			didClickSector = true
			if let def = getSector(from: event.locationInWindow) {
				selectedDef = def
			} else {
				didClickSector = false
			}
		} else {
			
		}
		
		shouldDragSelectionBox = true
	}
	
	
	//https://stackoverflow.com/questions/20357960/drawing-selection-box-rubberbanding-marching-ants-in-cocoa-objectivec

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
	
	

	func selectObjectsInBox() {
		
		var box1 = Box()	// the selection box
		var box2 = Box()	// a box around a line
		
		// get points in the selection box
		for i in 0..<points.count {
			let pt = points[i].coord
			if NSPointInRect(pt, selectionBox) {
				editWorld.selectPoint(i)
			}
		}
		
		// get lines in the selection box
		makeBox(&box1, from: selectionBox)
		for i in 0..<lines.count {
			
			var p1 = points[lines[i].pt1].coord
			var p2 = points[lines[i].pt2].coord
			
			makeBox(&box2, with: p1, and: p2)
			
			if box1.right < box2.left || box1.left > box2.right ||
				box1.top < box2.bottom || box1.bottom > box2.top {
				continue
			}
			
			if lineInRect(x0: &p1.x, y0: &p1.y, x1: &p2.x, y1: &p2.y, rect: selectionBox) {
				editWorld.selectLine(i)
			}
		}
		
		// get things in the selection box
		for i in 0..<things.count {
			let org = things[i].origin
			if NSPointInRect(org, selectionBox) {
				editWorld.selectThing(i)
			}
		}
	}
	
	
	
	// ================
	// MARK: - Dragging
	// ================

	func dragObjects_LMDown(with event: NSEvent) {

		print("dragObjects_LMDown called")
		
		cursor = getWorldGridPoint(from: event.locationInWindow)
		
		// set up negative rects
		fixedRect.origin.x = CGFloat.greatestFiniteMagnitude/4
		fixedRect.origin.y = CGFloat.greatestFiniteMagnitude/4
		fixedRect.size.width = -CGFloat.greatestFiniteMagnitude/2
		fixedRect.size.height = -CGFloat.greatestFiniteMagnitude/2
		dragRect = fixedRect;
		
		for i in 0..<lines.count {

			let end1 = points[lines[i].pt1].isSelected
			let end2 = points[lines[i].pt2].isSelected

			if end1 || end2 {
				lineList.append(i)
			}
			
			if end1 && !end2 {
				enclosePoint(rect: &fixedRect, point: points[lines[i].pt2].coord)  // pt2 is fixed
			} else if end2 && !end1 {
				enclosePoint(rect: &fixedRect, point: points[lines[i].pt1].coord)  // pt1 is fixed
			}
		}
		
		lineCount = lineList.count

		//
		// the dragrect encloses all selected points
		//
		let offset = CGFloat(THING_DRAW_SIZE/2 + 2)
		
		
		for i in 0..<points.count {
			if points[i].isSelected {
				pointCount += 1
				lastPoint = i
				enclosePoint(rect: &dragRect, point: points[i].coord)
			}
		}
		
		for i in 0..<things.count {
			if things[i].isSelected {
				var pt: NSPoint
				
				pt = things[i].origin
				pt.x -= offset
				pt.y -= offset
				enclosePoint(rect: &dragRect, point: pt)
				pt.x = things[i].origin.x + offset
				pt.y = things[i].origin.y + offset
				enclosePoint(rect: &dragRect, point: pt)
			}
		}
		
		oldDragRect = dragRect		// absolute coordinates
		
		dragRect.origin.x -= cursor.x	// relative to cursor
		dragRect.origin.y -= cursor.y
		
		print("didDragObject set to true")
		
		didDragObject = true
	}
	
	
	func dragObjects_LMDragged(with event: NSEvent) {
		
		print("dragObjects_LMDragged called")
		
		var moved: NSPoint = cursor
		totalMoved = cursor
		
		// calculate new rectangle
		cursor = getWorldGridPoint(from: event.locationInWindow) // handle grid and such

		// move all selected points
		if pointCount == 1 {
			points[lastPoint].coord = cursor
		} else {
			
			moved.x = cursor.x - moved.x
			moved.y = cursor.y - moved.y
			
			for i in 0..<points.count {
				if points[i].isSelected {
					points[i].coord.x += moved.x
					points[i].coord.y += moved.y
				}
			}
			
			for i in 0..<things.count {
				if things[i].isSelected {
					things[i].origin.x += moved.x
					things[i].origin.y += moved.y
				}
			}

			// TODO: Set project dirty

			moved = cursor

			// TODO: update line normals
			for i in 0..<lineCount {
				editWorld.updateLineNormal(lineList[i])
			}
			
			// redraw new frame
			currentDragRect = dragRect
			currentDragRect.origin.x += cursor.x
			currentDragRect.origin.y += cursor.y
			updateRect = currentDragRect
			NSUnionRect(oldDragRect, updateRect)
			NSUnionRect(fixedRect, updateRect)
			oldDragRect = currentDragRect;
			self.setNeedsDisplay(updateRect)
		}


	}

	func dragObjects_LMUp(with event: NSEvent) {

		print("dragObjects_LMUp called")

		// tell the world about the changes
		// the points have to be set back to their original positions before sending
		// the new point to the server so the dirty rect will contain everything touched
		// by the old and new positions

		totalMoved.x = cursor.x - totalMoved.x;
		totalMoved.y = cursor.y - totalMoved.y;
		
		for i in 0..<points.count {
			if points[i].isSelected {
				let newPoint = points[i]
				points[i].coord.x -= totalMoved.x
				points[i].coord.y -= totalMoved.y
				editWorld.changePoint(i, to: newPoint)
				// TODO: set project dirty
				// if (totalmoved.x || totalmoved.y)
				// [doomproject_i	setDirtyMap:TRUE];

			}
		}
		
	}
	
	
	// =============
	// MARK: Sectors
	// =============

	func lineByPoint(point: NSPoint, side: inout Int) -> Int {
		
		var pt = point
		var bestDistance: CGFloat = CGFloat.greatestFiniteMagnitude
		var p1, p2: NSPoint
		var frac, xIntercept, distance: CGFloat
		var bestLine: Int = -1
		
		pt.x += 0.5
		pt.y += 0.5
		
		// find the closest line to the given point
		for l in 0..<lines.count {
			
			p1 = points[lines[l].pt1].coord
			p2 = points[lines[l].pt2].coord
			
			if p1.y == p2.y {
				continue
			}
			
			if p1.y < p2.y {
				frac = (pt.y - p1.y) / (p2.y - p1.y)
				if frac < 0 || frac > 1 {
					continue
				}
				xIntercept = p1.x + frac*(p2.x - p1.x)
			}
			
			else {
				frac = (pt.y - p2.y) / (p1.y - p2.y)
				if frac < 0 || frac > 1 {
					continue
				}
				xIntercept = p2.x + frac*(p1.x - p2.x)
			}
			
			distance = abs(xIntercept - pt.x)
			if distance < bestDistance {
				bestDistance = distance
				bestLine = l
			}
		}
		
		// if no line is intercepted, the point was outside all areas
		if bestDistance == CGFloat.greatestFiniteMagnitude {
			side = 0
			return -1
		}
		side = lineSideToPoint(lines[bestLine], to: pt)
		return bestLine
	}
	
	func lineSideToPoint(_ line: Line, to point: NSPoint) -> Int {

		var p1, p2: NSPoint
		var slope, yintercept: CGFloat
		var direction, test: Int
		
		p1 = points[line.pt1].coord
		p2 = points[line.pt2].coord
		
		if p1.y == p2.y {
			var r1, r2: Int
			p1.x < p2.x ? (r1 = 1) : (r1 = 0)
			point.y < p1.y ? (r2 = 1) : (r2 = 0)
			return r1 ^ r2
		}
		if p1.x == p2.x {
			var r1, r2: Int
			p1.y < p2.y ? (r1 = 1) : (r1 = 0)
			point.x > p1.x ? (r2 = 1) : (r2 = 0)
			return r1 ^ r2
		}
		
		slope = (p2.y - p1.y) / (p2.x - p1.x)
		yintercept = p1.y - slope*p1.x
		
		// for y > mx+b, substitute in the normal point, which is on the front
		if line.normal.y > slope*line.normal.x + yintercept {
			direction = 1
		} else {
			direction = 0
		}
		if point.y > slope*point.x + yintercept {
			test = 1
		} else {
			test = 0
		}
		if direction == test {
			return 0	// front side
		}
		return 1		// back side
	}
	
	
	
	func getSector(from point: NSPoint) -> SectorDef? {
		
		var pt: NSPoint
		var line: Int
		var side: Int = 0
		
		pt = worldCoord(for: point)
		line = lineByPoint(point: pt, side: &side)
		
		if let def = lines[line].side[side]?.ends {
			return def
		}
		return nil
	}
	
	
	
}
