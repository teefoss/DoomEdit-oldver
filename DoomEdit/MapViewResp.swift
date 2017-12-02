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
			decreaseGrid()
		case KEY_RIGHTBRACKET:
			increaseGrid()
		case KEY_I:
			printInfo()
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
	
	override func mouseMoved(with event: NSEvent) {
		super.mouseMoved(with: event)
		
		let gridPoint = getWorldGridPoint(from: event.locationInWindow)
		let closestPoint = world.closestPoint(to: gridPoint)
		self.closestPoint = closestPoint
		print(self.closestPoint)
		if let pt = self.closestPoint {
			if pt.hovering == true {
				setNeedsDisplay(bounds)
			}
		}
	}
	
	override func mouseDown(with event: NSEvent) {
		
		// animated drawing is done in view coord system
		self.startPoint = getViewGridPoint(from: event.locationInWindow)
		
		shapeLayer = CAShapeLayer()
		shapeLayer.lineWidth = 1.5
		shapeLayer.fillColor = NSColor.clear.cgColor
		shapeLayer.strokeColor = NSColor.black.cgColor
		layer?.addSublayer(shapeLayer)
		shapeLayerIndex = layer?.sublayers?.index(of: shapeLayer)
		
	}
	
	override func mouseDragged(with event: NSEvent) {
		
		didDragLine = true
		needsDisplay = false		// don't redraw everything while adding a line (???)
		
		endPoint = getViewGridPoint(from: event.locationInWindow)
		let path = CGMutablePath()
		path.move(to: self.startPoint)
		path.addLine(to: endPoint)
		
		self.shapeLayer.path = path
		
	}
	
	override func mouseUp(with event: NSEvent) {
		
		// FIXME: Make shapeLayer line go away
		//self.shapeLayer.sublayers = nil
		var line = Line()
		
		if didDragLine {
			layer?.sublayers?.remove(at: shapeLayerIndex)
			
			// convert startPoint to world coord
			let pt1 = convert(startPoint, to: superview)
			
			if let endPoint = endPoint {
				// convert endPoint to world coord
				let pt2 = convert(endPoint, to: superview)
				//world.newLine(from: pt1, to: pt2)
				line.pt1.coord = pt1
				line.pt2.coord = pt2
				world.newLine(line: &line)
				frame = world.updateBounds()
				setNeedsDisplay(bounds)
			}
			didDragLine = false
		}
	}
	
	
	func visibleRectOriginInWorldCoord() -> NSPoint {
		return worldCoord(for: visibleRect.origin)
	}
	
	func mouseLocationInWorldCoord(from event: NSEvent) -> NSPoint {
		return worldCoord(for: event.locationInWindow)
	}
	
	
	
}
