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

fileprivate let KEY_MINUS: 			UInt16 = 27
fileprivate let KEY_EQUALS: 		UInt16 = 24
fileprivate let KEY_LEFTBRACKET: 	UInt16 = 33
fileprivate let KEY_RIGHTBRACKET: 	UInt16 = 30
fileprivate let KEY_I: 				UInt16 = 34
fileprivate let KEY_SPACE:			UInt16 = 49



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
			frame = world.updateBounds()
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
			frame = world.updateBounds()
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
			}
		case .draw:
			if didDragLine {
				dragLine_LMUp()
			}
		}
	}
	
	
	
	// =========================
	// MARK: - Selection Methods
	// =========================
	
	// https://stackoverflow.com/questions/33158513/checking-keydown-event-modifierflags-yields-error
	/// Selects a point at the mouse location. If no point is present, selects a line, thing, or sector in that order of priority.
	func selectObject(at event: NSEvent) {
		
		var pointIndex: Int = -1
		var thingIndex: Int = -1
		var pt = Point()
		var left, right, top, bottom: CGFloat  // For a box around the click point
		var clickPoint: NSPoint
		
		clickPoint = worldCoord(for: event.locationInWindow)
		print("clickPoint: \(clickPoint)")

		//
		// see if the click hit a point
		//

		// TODO: adjust this after zooming fixed
		// set up a box around the click point
		left = clickPoint.x - POINT_SIZE/scale/CGFloat(2)
		right = clickPoint.x + POINT_SIZE/scale/CGFloat(2)
		bottom = clickPoint.y - POINT_SIZE/scale/CGFloat(2)
		top = clickPoint.y + POINT_SIZE/scale/CGFloat(2)
		
		for i in 0..<world.points.count {
			pt = world.points[i]
			// if the point is inside the box
			if pt.coord.x > left && pt.coord.x < right &&
				pt.coord.y < top && pt.coord.y > bottom {
				pointIndex = i
				break	// got one, move on
			}
		}
		

		// clicked a point
		if pointIndex >= 0 && pointIndex < world.points.count {

			// if the point is already selected
			if world.points[pointIndex].isSelected {
				// shift is not being held
				if !event.modifierFlags.contains(.shift) {
					deselectAll()
					return
				} else {
					deselectPoint(pointIndex)
					return
				}
			// point is not already selected
			} else {
				// shift is not being held
				if !event.modifierFlags.contains(.shift) {
					deselectAll()
					selectPoint(pointIndex)
					return
				} else {
					selectPoint(pointIndex)
					return
				}
			}
			//drag
		}
		
		//
		// didn't hit a point, check for a line
		//
		
		for i in 0..<world.lines.count {
			
			let p1 = world.lines[i].end1.coord
			let p2 = world.lines[i].end2.coord
			
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
				if world.lines[i].isSelected {
					if !event.modifierFlags.contains(.shift) {
						deselectAll()
						return
					} else {
						deselectLine(i)
						return
					}
				// line is not already selected
				} else {
					// shift if not held
					if !event.modifierFlags.contains(.shift) {
						deselectAll()
						selectLine(i)
						return
					// shift is held
					} else {
						selectLine(i)
						return
					}
				}
				// TODO: add drag functionality
			}
			
		}
		
		
		//
		// didn't hit a line, check for a thing
		//
		
		left = clickPoint.x - CGFloat(THING_DRAW_SIZE/2)
		right = clickPoint.x + CGFloat(THING_DRAW_SIZE/2)
		bottom = clickPoint.y - CGFloat(THING_DRAW_SIZE/2)
		top = clickPoint.y +  CGFloat(THING_DRAW_SIZE/2)
		
		for i in 0..<world.things.count {
			
			let thing = world.things[i]
			if thing.origin.x > left && thing.origin.x < right
				&& thing.origin.y < top && thing.origin.y > bottom {
				thingIndex = i
				break
			}
		}
		
		if thingIndex >= 0 && thingIndex < world.things.count {

			// Thing is already seleted
			if world.things[thingIndex].isSelected {
				// shift is not being held
				if !event.modifierFlags.contains(.shift) {
					deselectAllThings()
					return
				// shift is being held
				} else {
					deselectThing(thingIndex)
					return
				}
				
			// Thing is not already selected
			} else {
				if !event.modifierFlags.contains(.shift) {
					deselectAll()
					selectThing(thingIndex)
					return
				} else {
					selectThing(thingIndex)
					return
				}
			}
		}

		//
		//  Hit nothing
		//
		if !event.modifierFlags.contains(.shift) {
			deselectAll()
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
		for i in 0..<world.points.count {
			let pt = world.points[i].coord
			if NSPointInRect(pt, selectionBox) {
				selectPoint(i)
			}
		}
		
		// get lines in the selection box
		makeBox(&box1, from: selectionBox)
		for i in 0..<world.lines.count {
			
			var p1 = world.points[world.lines[i].pt1].coord
			var p2 = world.points[world.lines[i].pt2].coord
			
			makeBox(&box2, with: p1, and: p2)
			
			if box1.right < box2.left || box1.left > box2.right ||
				box1.top < box2.bottom || box1.bottom > box2.top {
				continue
			}
			
			if lineInRect(x0: &p1.x, y0: &p1.y, x1: &p2.x, y1: &p2.y, rect: selectionBox) {
				selectLine(i)
			}
		}
		
		// get things in the selection box
		for i in 0..<world.things.count {
			let org = world.things[i].origin
			if NSPointInRect(org, selectionBox) {
				selectThing(i)
			}
		}
	}


	
	
	func selectPoint(_ i: Int) {
		world.points[i].isSelected = true
	}
	
	func deselectPoint(_ i: Int) {
		world.points[i].isSelected = false
	}
	
	func deselectAllPoints() {
		for i in 0..<world.points.count {
			world.points[i].isSelected = false
		}
	}
	
	func selectLine(_ i: Int) {
		world.lines[i].isSelected = true
		
		
		// also select its points
		world.points[world.lines[i].pt1].isSelected = true
		world.points[world.lines[i].pt2].isSelected = true
	}
	
	func deselectLine(_ i: Int) {
		world.lines[i].isSelected = false
		
		// also deselect its points
		world.points[world.lines[i].pt1].isSelected = false
		world.points[world.lines[i].pt2].isSelected = false

	}
	
	func deselectAllLines() {
		for i in 0..<world.lines.count {
			world.lines[i].isSelected = false
		}
	}
	
	func selectThing(_ i: Int) {
		world.things[i].isSelected = true
	}
	
	func deselectThing(_ i: Int) {
		world.things[i].isSelected = false
	}
	
	func deselectAllThings() {
		for i in 0..<world.things.count {
			world.things[i].isSelected = false
		}
	}
	
	func deselectAll() {
		deselectAllPoints()
		deselectAllLines()
		deselectAllThings()
	}
	

	
	
}
