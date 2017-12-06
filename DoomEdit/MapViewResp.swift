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
			printInfo()
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
			NSCursor.crosshair.set()
		} else {
			NSCursor.arrow.set()
		}
	}
	
	// For testing
	func printInfo() {
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
		
		
		selectObject(at: event)
		
		if inDrawingMode {
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
	
	// https://stackoverflow.com/questions/33158513/checking-keydown-event-modifierflags-yields-error
	/// Selects a point at the mouse location. If no point is present, selects a line, thing, or sector in that order of priority.
	func selectObject(at event: NSEvent) {
		
		var index: Int = -1
		var pt = Point()
		var thing = Thing()
		var left, right, top, bottom: CGFloat  // For a box around the click point
		var p1, p2: NSPoint
		var clickPoint: NSPoint
		var inStroke: Int
		
		clickPoint = worldCoord(for: event.locationInWindow)

		//
		// see if the click hit a point
		//

		// set up a box around the click point
		left = clickPoint.x - pointSize/scale/CGFloat(2)
		right = clickPoint.x + pointSize/scale/CGFloat(2)
		bottom = clickPoint.y - pointSize/scale/CGFloat(2)
		top = clickPoint.y + pointSize/scale/CGFloat(2)
		
		for i in 0..<world.points.count {
			pt = world.points[i]
			// if the point is inside the box
			if pt.coord.x > left && pt.coord.x < right &&
				pt.coord.y < top && pt.coord.y > bottom {
				index = i
				break	// got one, move on
			}
		}
		
		print("world.points.count \(world.points.count)")
		
		if index >= 0 && index < world.points.count {
			// clicked a point
			if world.points[index].isSelected {
				world.deselectPoint(index)
				return
			} else {
				// if not clicking on a selection and not shift-clicking, deselect all selected points
				if !event.modifierFlags.contains(.shift) {
					world.deselectAllPoints()
				}
				world.selectPoint(index)
			}
			//drag
			return
		}
		
		//
		// didn't hit a point, check for a line
		//
		
		
		
		
		// thing
		
		if !event.modifierFlags.contains(.shift) {
			world.deselectAllPoints()
		}
		
		
		
		
	}
	
	
	
}
