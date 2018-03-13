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
		if currentMode == .thing {
			drawLines(in: dirtyRect)
			drawThings(in: dirtyRect)
		} else {
			drawThings(in: dirtyRect)
			drawLines(in: dirtyRect)
			drawPoints(in: dirtyRect)
		}
		
//		displayTestingRect(editWorld.dirtyRect)
	}
	
	func addLengthLabels() {
		
		if let win = NSApp.mainWindow {
			if let cv = win.contentView {
				let visrect = convert(cv.visibleRect, from: nil)
				
				for line in lines {
					if line.selected == -1 {
						continue
					}
					let mid = convert(line.midpoint, from: superview)
					
					if !showAllLineLabels {
						if !visrect.contains(mid) {
							continue
						}
					}
					
					let label = NSTextField(frame: NSRect(x: mid.x, y: mid.y, width: 0, height: 0))
					label.isBordered = false
					label.backgroundColor = NSColor.clear
					label.integerValue = line.length
					label.sizeToFit()
					addSubview(label)
				}

			}
		}
	}
	
	func addThingImages() {
		
		guard let win = NSApp.mainWindow else { return }
		guard let cv = win.contentView else { return }
		
		let visrect = convert(cv.visibleRect, from: nil)
		
		for thing in things {
			
			let rect = NSRect(x: thing.origin.x-16, y: thing.origin.y-16, width: 32, height: 32)
			let thingrect = convert(rect, from: superview)
			
			if !showAllThingImages {
				if !visrect.contains(thingrect) {
					continue
				}
			}
			
			let imageView = NSImageView(frame: thingrect)
			imageView.image = thing.def.image
			addSubview(imageView)
		}
		
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
			COLOR_BKG.setFill()
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
			if currentMode != .thing {
				NSBezierPath.strokeLine(from: newMidPt, to: newNormPt)	// line normal 'tick'
			}
		}
	}
	
	///  Draw all world things
	private func drawThings(in rect: NSRect) {

		for thing in things {
			if thing.selected == -1 {
				continue
			}
			var origin = convert(thing.origin, from: superview)
			let size = NSSize(width: 32, height: 32)
			origin.x -= 16
			origin.y -= 16
			let rect = NSRect(x: origin.x-DRAWOFFSET, y: origin.y-DRAWOFFSET, width: size.width, height: size.height)
			
			thing.def.color.set()
			if thing.selected == 1 {
				NSColor.red.set()
			}
			if currentMode == .line {
				NSColor.black.withAlphaComponent(0.1).set()
			}
			if currentMode != .thing {
				NSBezierPath.fill(rect)
			}
			if currentMode != .line || currentMode != .thing {
				COLOR_THINGINFO.setStroke()
				NSBezierPath.defaultLineWidth = 2.0
				strokeEasyMarker(thing, relativeTo: rect)
				strokeMediumMarker(thing, relativeTo: rect)
				strokeHardMarker(thing, relativeTo: rect)
				strokeNetworkMarker(thing, relativeTo: rect)
				strokeAmbushMarker(thing, relativeTo: rect)
			}
			
			// FIXME: Make this just a rotation
			if thing.def.hasDirection && (currentMode != .line || currentMode != .thing) {
				let path = thingArrow(in: rect, direction: thing.angle)
				COLOR_THINGINFO.set()
				path.stroke()
			}
			
			if currentMode == .thing {
				NSColor.black.setStroke()
				var origin = convert(thing.origin, from: superview)
				let originx = Int(origin.x)-(thing.def.size/2)
				let originy = Int(origin.y)-(thing.def.size/2)
				NSBezierPath.stroke(NSRect(x: originx, y: originy, width: thing.def.size, height: thing.def.size))
			}
		}
	}

	func strokeEasyMarker(_ thing: Thing, relativeTo rect: NSRect) {
		
		if thing.options & SKILL_EASY != 0 {
			let p1 = NSPoint(x: rect.minX+3+DRAWOFFSET, y: rect.minY+8+DRAWOFFSET)
			let p2 = NSPoint(x: rect.minX+3+DRAWOFFSET, y: rect.maxY-8-DRAWOFFSET)
			NSBezierPath.strokeLine(from: p1, to: p2)
		}
	}

	func strokeMediumMarker(_ thing: Thing, relativeTo rect: NSRect) {

		if thing.options & SKILL_NORMAL != 0 {
			let p1 = NSPoint(x: rect.minX+8+DRAWOFFSET, y: rect.maxY-3-DRAWOFFSET)
			let p2 = NSPoint(x: rect.maxX-8-DRAWOFFSET, y: rect.maxY-3-DRAWOFFSET)
			NSBezierPath.strokeLine(from: p1, to: p2)
		}
	}
	
	func strokeHardMarker(_ thing: Thing, relativeTo rect: NSRect) {
		
		if thing.options & SKILL_HARD != 0 {
			let p1 = NSPoint(x: rect.maxX-3-DRAWOFFSET, y: rect.minY+8+DRAWOFFSET)
			let p2 = NSPoint(x: rect.maxX-3-DRAWOFFSET, y: rect.maxY-8-DRAWOFFSET)
			NSBezierPath.strokeLine(from: p1, to: p2)
		}
	}

	func strokeNetworkMarker(_ thing: Thing, relativeTo rect: NSRect) {
		
		if thing.options & NETWORK != 0 {
			let p1 = NSPoint(x: rect.minX+8+DRAWOFFSET, y: rect.minY+3+DRAWOFFSET)
			let p2 = NSPoint(x: rect.maxX-8-DRAWOFFSET, y: rect.minY+3+DRAWOFFSET)
			NSBezierPath.strokeLine(from: p1, to: p2)
		}
	}
	
	func strokeAmbushMarker(_ thing: Thing, relativeTo rect: NSRect) {
		
		if thing.options & AMBUSH != 0 {
			
			var path = NSBezierPath()
			let ul1 = NSPoint(x: rect.minX+3+DRAWOFFSET, y: rect.maxY-6-DRAWOFFSET)
			let ul2 = NSPoint(x: rect.minX+3+DRAWOFFSET, y: rect.maxY-3-DRAWOFFSET)
			let ul3 = NSPoint(x: rect.minX+6+DRAWOFFSET, y: rect.maxY-3-DRAWOFFSET)
			path.move(to: ul1); path.line(to: ul2); path.line(to: ul3)
			path.stroke()
			
			let ur1 = NSPoint(x: rect.maxX-6-DRAWOFFSET, y: rect.maxY-3-DRAWOFFSET)
			let ur2 = NSPoint(x: rect.maxX-3-DRAWOFFSET, y: rect.maxY-3-DRAWOFFSET)
			let ur3 = NSPoint(x: rect.maxX-3-DRAWOFFSET, y: rect.maxY-6-DRAWOFFSET)
			path.move(to: ur1); path.line(to: ur2); path.line(to: ur3)
			path.stroke()

			let lr1 = NSPoint(x: rect.maxX-6-DRAWOFFSET, y: rect.minY+3+DRAWOFFSET)
			let lr2 = NSPoint(x: rect.maxX-3-DRAWOFFSET, y: rect.minY+3+DRAWOFFSET)
			let lr3 = NSPoint(x: rect.maxX-3-DRAWOFFSET, y: rect.minY+6+DRAWOFFSET)
			path.move(to: lr1); path.line(to: lr2); path.line(to: lr3)
			path.stroke()
			
			let ll1 = NSPoint(x: rect.minX+6+DRAWOFFSET, y: rect.minY+3+DRAWOFFSET)
			let ll2 = NSPoint(x: rect.minX+3+DRAWOFFSET, y: rect.minY+3+DRAWOFFSET)
			let ll3 = NSPoint(x: rect.minX+3+DRAWOFFSET, y: rect.minY+6+DRAWOFFSET)
			path.move(to: ll1); path.line(to: ll2); path.line(to: ll3)
			path.stroke()
		}
	}

	
	///  Draw all world points
	private func drawPoints(in rect: NSRect) {
		
		for i in 0..<points.count {
			let point = points[i]
			
			if point.selected == -1 {
				continue
			}
			
			var origin = convert(point.coord, from: superview)
			origin.x -= 3.0
			origin.y -= 3.0
			
			//let offset: CGFloat = 0//2.5
			let size = NSSize(width: 4, height: 4)
			let rect = NSRect(x: origin.x, y: origin.y, width: size.width, height: size.height)

			if point.selected == 1 {
				NSColor.red.set()
				NSBezierPath.fill(rect)
			} else {
				COLOR_LINE_ONESIDED.set()
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







