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

extension MapView {
	
	override var acceptsFirstResponder: Bool { return true }
	override func becomeFirstResponder() -> Bool { return true }
	override func resignFirstResponder() -> Bool { return true }

	
	
	// MARK: - Key Actions

	override func keyDown(with event: NSEvent) {
		
		if event.keyCode == KEY_MINUS {			// zoom out
			scale /= 2
			print("scale = \(scale)")
			let mouseLoc = convert(event.locationInWindow, from: nil)
			delegate?.zoom(to: mouseLoc, with: scale)
		}
		else if event.keyCode == KEY_EQUALS	{	// zoom in
			scale *= 2
			print("scale = \(scale)")
			let mouseLoc = convert(event.locationInWindow, from: nil)
			delegate?.zoom(to: mouseLoc, with: scale)
		}
		else if event.keyCode == KEY_LEFTBRACKET {
			decreaseGrid()
			
		} else if event.keyCode == KEY_RIGHTBRACKET {
			increaseGrid()
		}
		
		//world.updateWindows()
	}
		
	func increaseGrid() {
		if gridSize < 64 {
			gridSize *= 2
			print("grid size = \(gridSize)")
			needsDisplay = true
		}
	}
	
	func decreaseGrid() {
		if gridSize > 1 {
			gridSize /= 2
			print("grid size = \(gridSize)")
			needsDisplay = true
		}
	}
	
	
	// MARK: - Mouse Actions
	
	override func mouseDown(with event: NSEvent) {
		
		self.startPoint = getGridPoint(from: event)
		
		shapeLayer = CAShapeLayer()
		shapeLayer.lineWidth = 1.0
		shapeLayer.fillColor = NSColor.clear.cgColor
		shapeLayer.strokeColor = NSColor.black.cgColor
		self.layer?.addSublayer(shapeLayer)
		
	}
	
	override func mouseDragged(with event: NSEvent) {
		
		needsDisplay = false		// don't redraw everything while adding a line (???)
		
		endPoint = getGridPoint(from: event)
		let path = CGMutablePath()
		path.move(to: self.startPoint)
		path.addLine(to: endPoint)
		self.shapeLayer.path = path

	}
	
	override func mouseUp(with event: NSEvent) {
		let pt1 = convert(startPoint, to: superview)
		let pt2 = convert(endPoint, to: superview)
		world.newLine(from: pt1, to: pt2)

		frame = world.updateBounds()
	}

}
