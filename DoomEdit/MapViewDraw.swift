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

fileprivate let tileAlpha: CGFloat = 0.3		// originally 3 and 1
fileprivate let gridAlpha: CGFloat = 0.1
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
		drawThings(in: dirtyRect)
		drawPoints(in: dirtyRect)
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
		
		NSBezierPath.defaultLineWidth = 1.0
		
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
			
			let offset: CGFloat = 0.5
			
			// drawing will be in view coord, i.e. origin = (0, 0)
			// so use superview's coord system, they are the same as world coord
			let pt1 = convert(NSPoint(x: line.pt1.coord.x-offset, y: line.pt1.coord.y-offset), from: superview)
			let pt2 = convert(NSPoint(x: line.pt2.coord.x-offset, y: line.pt2.coord.y-offset), from: superview)
			let midPt = convert(line.midpoint, from: superview)
			let normPt = convert(line.normal, from: superview)
			
			let midPtx = midPt.x - offset
			let midPty = midPt.y - offset
			let newMidPt = NSPoint(x: midPtx, y: midPty)
			
			let normPtx = normPt.x - offset
			let normPty = normPt.y - offset
			let newNormPt = NSPoint(x: normPtx, y: normPty)
			
			
			line.color.set()
			NSBezierPath.defaultLineWidth = 1.0
			NSBezierPath.strokeLine(from: pt1, to: pt2)			// line
			NSBezierPath.strokeLine(from: newMidPt, to: newNormPt)	// line normal 'tick'
		}
	}
	
	///  Draw all world things
	private func drawThings(in rect: NSRect) {

		for thing in world.things {
			let origin = convert(thing.origin, from: superview)
			let size = NSSize(width: 32, height: 32)
			let offset: CGFloat = 16.5
			let rect = NSRect(x: origin.x-offset, y: origin.y-offset, width: size.width, height: size.height)
			
			thing.color.set()
			NSBezierPath.fill(rect)
			
		}
	}
	
	private func drawPoints(in rect: NSRect) {
		
		for i in 0..<world.points.count {
			let point = world.points[i]
			
			let origin = convert(point.coord, from: superview)
			let offset: CGFloat = 2.5
			let size = NSSize(width: 4, height: 4)
			let rect = NSRect(x: origin.x-offset, y: origin.y-offset, width: size.width, height: size.height)

			if point.isSelected {
				NSColor.red.set()
				NSBezierPath.fill(rect)
				if i == 204 {
					print("204 red")
				}
			} else {
				NSColor.black.set()
				NSBezierPath.fill(rect)
				if i == 204 {
					print("204 black")
				}

			}

		}
	}
}

