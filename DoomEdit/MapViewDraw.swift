//
//  MapViewDraw.swift
//  DoomEdit
//
//  Created by Thomas Foster on 10/22/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa


// Grid Style Constants

fileprivate let tileAlpha: CGFloat = 0.3		// originally 3 and 1
fileprivate let gridAlpha: CGFloat = 0.1
fileprivate let tileColor = NSColor.systemBlue.withAlphaComponent(tileAlpha)
fileprivate let gridColor = NSColor.systemBlue.withAlphaComponent(gridAlpha)
//fileprivate let tileColor = NSColor.gridColor
//fileprivate let gridColor = NSColor.gridColor

let DRAWOFFSET: CGFloat = 0.5

/**
MapView Drawing-related Methods
*/

extension MapView: EditWorldDelegate {
	
	//	override var isOpaque: Bool { return true }
	//	override var wantsDefaultClipping: Bool { return false }
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		// TODO: Draw objects in the right order
		drawGrid(in: dirtyRect)
		drawThings(in: dirtyRect)
		drawLines(in: dirtyRect)
		drawPoints(in: dirtyRect)
		displayTestingRect(editWorld.dirtyRect)
	}
	
	func displayTestingRect(_ rect: NSRect) {

		let r = convert(rect, from: superview)
		
		let path = NSBezierPath(rect: r)

		NSColor.red.setStroke()
		path.lineWidth = 2.0
		path.stroke()

	}
	
	func redisplay(_ dirtyRect: NSRect) {

		// convert from world coord to view coord
		var rect = convert(dirtyRect, from: superview)
		
		// adjust for draw offset
		rect.origin.x -= DRAWOFFSET
		rect.origin.y -= DRAWOFFSET
		
		setNeedsDisplay(rect)
	}

	/// Draws the 64x64 fixed tiles and the adjustable grid
	private func drawGrid(in rect: NSRect) {
		
		let left = Int(rect.minX)
		let bottom = Int(rect.minY)
		let right = Int(rect.maxX)
		let top = Int(rect.maxY)
		
		if let context = NSGraphicsContext.current?.cgContext {
			Color.background.setFill()
			context.fill(rect)
			context.flush()
		}
		
		func convVert(_ i: Int) -> Int {
			return i - Int(bounds.origin.y - frame.origin.y)
		}
		
		func convHor(_ i: Int) -> Int {
			return i - Int(bounds.origin.x - frame.origin.x)
		}

		NSBezierPath.defaultLineWidth = LINE_WIDTH
		
		//draw horizontal lines
		for i in bottom...top {
			if convVert(i) % 64 == 0 {
				let current_y = CGFloat(i) - DRAWOFFSET
				tileColor.set()
				NSBezierPath.strokeLine(from: CGPoint(x: 0.0, y: current_y), to: CGPoint(x: CGFloat(right), y: current_y))
			} else if convVert(i) % gridSize == 0 {
				let current_y = CGFloat(i) - DRAWOFFSET
				gridColor.set()
				NSBezierPath.strokeLine(from: CGPoint(x: 0.0, y: current_y), to: CGPoint(x: CGFloat(right), y: current_y))
			}
		}
		
		//draw verticle lines
		
		for i in left...right {
			if convHor(i) % 64 == 0 {
				let current_x = CGFloat(i) - DRAWOFFSET
				tileColor.set()
				NSBezierPath.strokeLine(from: CGPoint(x: current_x, y: 0), to: CGPoint(x: current_x, y: CGFloat(top)))
			} else if convHor(i) % gridSize == 0 {
				let current_x = CGFloat(i) - DRAWOFFSET
				gridColor.set()
				NSBezierPath.strokeLine(from: CGPoint(x: current_x, y: 0), to: CGPoint(x: current_x, y: CGFloat(top)))
			}
		}
		
	}

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
	///  Draw all world lines
	private func drawLines(in rect: NSRect) {
				
		for i in 0..<lines.count {
			
			if lines[i].selected == -1 {
				continue
			}
			
			let offset: CGFloat = 0.5
			
			// drawing will be in view coord, i.e. origin = (0, 0)...
			// so convert from superview coord system  (same as world coord)
			let pt1 = convert(NSPoint(x: points[lines[i].pt1].coord.x-offset, y: points[lines[i].pt1].coord.y-offset), from: superview)
			let pt2 = convert(NSPoint(x: points[lines[i].pt2].coord.x-offset, y: points[lines[i].pt2].coord.y-offset), from: superview)
			let midPt = convert(lines[i].midpoint, from: superview)
			let normPt = convert(lines[i].normal, from: superview)
			
			let midPtx = midPt.x - offset
			let midPty = midPt.y - offset
			let newMidPt = NSPoint(x: midPtx, y: midPty)
			
			let normPtx = normPt.x - offset
			let normPty = normPt.y - offset
			let newNormPt = NSPoint(x: normPtx, y: normPty)
			
			
			if lines[i].selected > 0 {
				NSColor.red.set()
			} else {
				lines[i].color.set()
			}
			NSBezierPath.defaultLineWidth = LINE_WIDTH
			NSBezierPath.strokeLine(from: pt1, to: pt2)			// line
			NSBezierPath.strokeLine(from: newMidPt, to: newNormPt)	// line normal 'tick'
		}
	}
	
	///  Draw all world things
	private func drawThings(in rect: NSRect) {

		for thing in things {
			if thing.selected == -1 {
				continue
			}
			let origin = convert(thing.origin, from: superview)
			let size = NSSize(width: 32, height: 32)
			let offset: CGFloat = 16.5
			let rect = NSRect(x: origin.x-offset, y: origin.y-offset, width: size.width, height: size.height)
			
			thing.def.color.set()
			if thing.selected == 1 {
				NSColor.red.set()
			}
			NSBezierPath.fill(rect)

			// FIXME: Make this just a rotation
			if thing.def.hasDirection {
				let path = thingArrow(in: rect, direction: thing.angle)
				NSColor.white.set()
				path.stroke()
			}
		}
	}
	
	///  Draw all world points
	private func drawPoints(in rect: NSRect) {
		
		for i in 0..<points.count {
			let point = points[i]
			
			if point.selected == -1 {
				continue
			}
			
			let origin = convert(point.coord, from: superview)
			let offset: CGFloat = 2.5
			let size = NSSize(width: 4, height: 4)
			let rect = NSRect(x: origin.x-offset, y: origin.y-offset, width: size.width, height: size.height)

			if point.selected == 1 {
				NSColor.red.set()
				NSBezierPath.fill(rect)
			} else {
				NSColor.black.set()
				NSBezierPath.fill(rect)
			}

		}
	}
	
	func thingArrow(in thingRect: NSRect, direction: Int) -> NSBezierPath {
		var path = NSBezierPath()
		let midx = thingRect.midX
		let midy = thingRect.midY
		
		// all the possible end points of the arrow
		let degrees_0 = NSPoint(x: midx+8, y: midy+0)
		let degrees_45 = NSPoint(x: midx+4, y: midy+4)
		let degrees_90 = NSPoint(x: midx+0, y: midy+8)
		let degrees_135 = NSPoint(x: midx-4, y: midy+4)
		let degrees_180 = NSPoint(x: midx-8, y: midy-0)
		let degrees_225 = NSPoint(x: midx-4, y: midy-4)
		let degrees_270 = NSPoint(x: midx-0, y: midy-8)
		let degrees_315 = NSPoint(x: midx+4, y: midy-4)
		let diagArrowEnd_45 = NSPoint(x: midx+8, y: midy+8)
		let diagArrowEnd_135 = NSPoint(x: midx-8, y: midy+8)
		let diagArrowEnd_225 = NSPoint(x: midx-8, y: midy-8)
		let diagArrowEnd_315 = NSPoint(x: midx+8, y: midy-8)

		switch direction {
		case 0:
			makeArrowPath(&path, p1: degrees_180, p2: degrees_0, p3: degrees_45, p4: degrees_315)
		case 45:
			makeArrowPath(&path, p1: diagArrowEnd_225, p2: diagArrowEnd_45, p3: degrees_90, p4: degrees_0)
		case 90:
			makeArrowPath(&path, p1: degrees_270, p2: degrees_90, p3: degrees_135, p4: degrees_45)
		case 135:
			makeArrowPath(&path, p1: diagArrowEnd_315, p2: diagArrowEnd_135, p3: degrees_180, p4: degrees_90)
		case 180:
			makeArrowPath(&path, p1: degrees_0, p2: degrees_180, p3: degrees_225, p4: degrees_135)
		case 225:
			makeArrowPath(&path, p1: diagArrowEnd_45, p2: diagArrowEnd_225, p3: degrees_270, p4: degrees_180)
		case 270:
			makeArrowPath(&path, p1: degrees_90, p2: degrees_270, p3: degrees_315, p4: degrees_225)
		case 315:
			makeArrowPath(&path, p1: diagArrowEnd_135, p2: diagArrowEnd_315, p3: degrees_0, p4: degrees_270)
		default:
			break
		}
		
		return path
	}
	
	func makeArrowPath(_ path: inout NSBezierPath, p1: NSPoint, p2: NSPoint, p3: NSPoint, p4: NSPoint) {
		path.move(to: p1)
		path.line(to: p2)
		path.line(to: p3)
		path.move(to: p4)
		path.line(to: p2)
		path.lineJoinStyle = .roundLineJoinStyle
		path.lineWidth = 2.0
	}
	
	// =====================
	// MARK: - Line Drawing
	// =====================
	
	func drawLine_LMDown(with event: NSEvent) {
		// TODO: Move all this out into a function
		// TODO: Draw the 'tick' mark while adding a line
		
		// animated drawing is done in view coord system
		editWorld.deselectAll()
		self.startPoint = getViewGridPoint(from: event.locationInWindow)
		shapeLayer = CAShapeLayer()
		shapeLayer.lineWidth = 1.0
		shapeLayer.fillColor = NSColor.clear.cgColor
		shapeLayer.strokeColor = NSColor.black.cgColor
		layer?.addSublayer(shapeLayer)
		shapeLayerIndex = layer?.sublayers?.index(of: shapeLayer)
	}
	
	func drawLine_LMDragged(with event: NSEvent) {
		didDragLine = true
		needsDisplay = false		// don't redraw everything while adding a line (???)
		endPoint = getViewGridPoint(from: event.locationInWindow)
		let path = CGMutablePath()
		path.move(to: self.startPoint)
		path.addLine(to: endPoint)
		self.shapeLayer.path = path
	}
	
	func drawLine_LMUp() {
		
		var line = Line()
		line.side[0] = lines.last?.side[0]

		layer?.sublayers?.remove(at: shapeLayerIndex)
		
		// convert startPoint to world coord
		let pt1 = convert(startPoint, to: superview)
		
		if let endPoint = endPoint {
			// convert endPoint to world coord
			let pt2 = convert(endPoint, to: superview)
			// if line didn't end where it started
			if pt1.x == pt2.x && pt1.y == pt2.y {
				return
			} else {
				editWorld.newLine(line: &line, from: pt1, to: pt2)
				editWorld.selectLine(lines.count-1)
				frame = editWorld.getBounds()
				setNeedsDisplay(bounds)
			}
		}
		didDragLine = false
		doomProject.mapDirty = true
	}
	
}







