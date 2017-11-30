//
//  MapViewDraw.swift
//  DoomEdit
//
//  Created by Thomas Foster on 10/22/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

let lineNormalLength = 6

// Grid Style Constants

fileprivate let tileAlpha: CGFloat = 0.4		// originally 3 and 1
fileprivate let gridAlpha: CGFloat = 0.2
fileprivate let tileColor = NSColor.systemBlue.withAlphaComponent(tileAlpha)
fileprivate let gridColor = NSColor.systemBlue.withAlphaComponent(gridAlpha)



/**
MapView Drawing-related Methods
*/

extension MapView {
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
				
		drawGrid(in: dirtyRect)
		drawLines(in: dirtyRect)
	}

	/// Draws the 64x64 fixed tiles and the adjustable grid
	private func drawGrid(in rect: NSRect) {
		
		let left = Int(rect.minX)
		let bottom = Int(rect.minY)
		let right = Int(rect.maxX)
		let top = Int(rect.maxY)
		
		let offSet = CGFloat(0.5)
		
		if let context = NSGraphicsContext.current?.cgContext {
			NSColor.white.setFill()
			context.fill(rect)
			context.flush()
		}
		
		//draw horizontal lines
		for i in bottom...top {
			if i % 64 == 0 {
				let current_y = CGFloat(i) - offSet
				tileColor.set()
				NSBezierPath.strokeLine(from: CGPoint(x: 0.0, y: current_y), to: CGPoint(x: CGFloat(right), y: current_y))
			} else if i % gridSize == 0 {
				let current_y = CGFloat(i) - offSet
				gridColor.set()
				NSBezierPath.strokeLine(from: CGPoint(x: 0.0, y: current_y), to: CGPoint(x: CGFloat(right), y: current_y))
			}
		}
		
		//draw verticle lines
		for i in left...right {
			if i % 64 == 0 {
				let current_x = CGFloat(i) - offSet
				tileColor.set()
				NSBezierPath.strokeLine(from: CGPoint(x: current_x, y: 0), to: CGPoint(x: current_x, y: CGFloat(top)))
			} else if i % gridSize == 0 {
				let current_x = CGFloat(i) - offSet
				gridColor.set()
				NSBezierPath.strokeLine(from: CGPoint(x: current_x, y: 0), to: CGPoint(x: current_x, y: CGFloat(top)))
			}
		}
	}

	///  Draw all world lines
	private func drawLines(in rect: NSRect) {

		for line in world.lines {
			// drawing will be in view coord, i.e. origin = (0, 0)
			// so use superview's coord system, they are the same as world coord
			let pt1 = convert(NSPoint(x: line.pt1.coord.x, y: line.pt1.coord.y), from: superview)
			let pt2 = convert(NSPoint(x: line.pt2.coord.x, y: line.pt2.coord.y), from: superview)
			let midPt = convert(line.midPoint, from: superview)
			let normPt = convert(line.normal, from: superview)

			NSColor.black.set()
			NSBezierPath.strokeLine(from: pt1, to: pt2)			// line
			NSBezierPath.strokeLine(from: midPt, to: normPt)	// line normal 'tick'			
		}
	}
	
	///  Draw all world things
	private func drawThings(in rect: NSRect) {
		
	}
}
