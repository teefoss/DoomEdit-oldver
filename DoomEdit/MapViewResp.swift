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
			//printInfo()
			printRefInfo()
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
	
	func toggleDrawMode() {
		inDrawingMode = !inDrawingMode
		if inDrawingMode {
			world.currentMode = .draw
			NSCursor.crosshair.set()
		} else {
			world.currentMode = .edit
			NSCursor.arrow.set()
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
	
	func printRefInfo() {

		print("=====================")
		print("Reference Number Info")
		for pt in world.points {
			if pt.isSelected {
				print("Point ref: \(pt.ref)")
			}
		}
		for line in world.lines {
			if line.isSelected {
				print("Line ref: \(line.ref)")
			}
		}
		print("=====================")
	}
	
	
	
	// =====================
	// MARK: - Mouse Actions
	// =====================
	
	override func mouseDown(with event: NSEvent) {
		
		
		selectObject(at: event)
		
		if inDrawingMode {
			
			// TODO: Move all this out into a function
			// TODO: Draw the 'tick' mark while adding a line
			
			// animated drawing is done in view coord system
			self.startPoint = getViewGridPoint(from: event.locationInWindow)
			shapeLayer = CAShapeLayer()
			shapeLayer.lineWidth = 1.0
			shapeLayer.fillColor = NSColor.clear.cgColor
			shapeLayer.strokeColor = NSColor.black.cgColor
			layer?.addSublayer(shapeLayer)
			shapeLayerIndex = layer?.sublayers?.index(of: shapeLayer)
		}
		
		setNeedsDisplay(bounds)
		
	}
	
	override func mouseDragged(with event: NSEvent) {
		
		if inDrawingMode {
			didDragLine = true
			needsDisplay = false		// don't redraw everything while adding a line (???)
			endPoint = getViewGridPoint(from: event.locationInWindow)
			let path = CGMutablePath()
			path.move(to: self.startPoint)
			path.addLine(to: endPoint)
			
			self.shapeLayer.path = path
		}
	}
	
	override func mouseUp(with event: NSEvent) {
		
		needsDisplay = true
		
		if inDrawingMode {
			var line = Line()
			if didDragLine {
				layer?.sublayers?.remove(at: shapeLayerIndex)
				
				// convert startPoint to world coord
				let pt1 = convert(startPoint, to: superview)
				
				if let endPoint = endPoint {
					// convert endPoint to world coord
					let pt2 = convert(endPoint, to: superview)
					// if line didn't end where it started
					if pt1.x != pt2.x && pt1.y != pt2.y {
						line.pt1.coord = pt1
						line.pt2.coord = pt2
						world.newLine(line: &line)
						frame = world.updateBounds()
						setNeedsDisplay(bounds)
					}
				}
				didDragLine = false
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
			
			let p1 = world.lines[i].pt1.coord
			let p2 = world.lines[i].pt2.coord
			
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
		let ref = world.lines[i].ref
		for j in 0..<world.points.count {
			if world.points[j].ref.contains(ref) {
				world.points[j].isSelected = true
			}
		}
	}
	
	func deselectLine(_ i: Int) {
		world.lines[i].isSelected = false
		
		// also deselect its points
		let ref = world.lines[i].ref
		for j in 0..<world.points.count {
			if world.points[j].ref.contains(ref) {
				world.points[j].isSelected = false
			}
		}
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
