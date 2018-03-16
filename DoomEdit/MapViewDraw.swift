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
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		/*
		var rects: UnsafePointer<NSRect>?
		var count: Int = 0
		
		getRectsBeingDrawn(&rects, count: &count)
		*/
		
		drawGrid(in: dirtyRect)

		if currentMode == .thing {
			drawLines(in: dirtyRect)
			drawThings(in: dirtyRect)
		} else {
			drawThings(in: dirtyRect)
			drawLines(in: dirtyRect)
			drawPoints(in: dirtyRect)
			if overlappingPointIndices.count > 0 {
				drawOverlappingPointBox(for: overlappingPointIndices)
			}
		}
		
//		displayTestingRect(editWorld.dirtyRect)
//		displayTestingRect(testingRect)

	}

	func drawOverlappingPointBox(for pointIndices: [Int]) {

		let boxsize = NSSize(width: 12.0, height: 12.0)

		for index in pointIndices {
			var coord = convert(points[index].coord, from: superview)
			coord.x -= boxsize.width/2+DRAWOFFSET
			coord.y -= boxsize.width/2+DRAWOFFSET
			NSBezierPath.defaultLineWidth = 2.0
			NSColor.red.setStroke()
			NSBezierPath.stroke(NSRect(origin: coord, size: boxsize))
		}
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
		displayIfNeeded()
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
		
		NSBezierPath.defaultLineWidth = LINE_WIDTH
		
		//draw horizontal lines
		for i in bottom...top {
			if i % 64 == 0 {
				let current_y = CGFloat(i) - DRAWOFFSET
				tileColor.set()
				NSBezierPath.strokeLine(from: CGPoint(x: CGFloat(left), y: current_y), to: CGPoint(x: CGFloat(right), y: current_y))
			} else if i % gridSize == 0 {
				let current_y = CGFloat(i) - DRAWOFFSET
				gridColor.set()
				NSBezierPath.strokeLine(from: CGPoint(x: CGFloat(left), y: current_y), to: CGPoint(x: CGFloat(right), y: current_y))
			}
		}
		
		//draw verticle lines
		
		for i in left...right {
			if i % 64 == 0 {
				let current_x = CGFloat(i) - DRAWOFFSET
				tileColor.set()
				NSBezierPath.strokeLine(from: CGPoint(x: current_x, y: CGFloat(bottom)), to: CGPoint(x: current_x, y: CGFloat(top)))
			} else if i % gridSize == 0 {
				let current_x = CGFloat(i) - DRAWOFFSET
				gridColor.set()
				NSBezierPath.strokeLine(from: CGPoint(x: current_x, y: CGFloat(bottom)), to: CGPoint(x: current_x, y: CGFloat(top)))
			}
		}
		
	}

	///  Draw all world lines
	private func drawLines(in rect: NSRect) {
				
		for i in 0..<lines.count {
			
			if lines[i].selected == -1 {
				continue
			}
			
			let line = lines[i]
			
			// test
//			let p1 = convertedPoints[line.pt1].coord
//			let p2 = convertedPoints[line.pt2].coord
			
			// drawing will be in view coord, i.e. origin = (0, 0)...
			// so convert from superview coord system  (same as world coord)
//			var p1 = convert(points[line.pt1].coord, from: superview)
//			var p2 = convert(points[line.pt2].coord, from: superview)
//			var midPt = convert(line.midpoint, from: superview)
//			var normPt = convert(line.normal, from: superview)

			var p1 = points[line.pt1].coord
			var p2 = points[line.pt2].coord
			var midPt = line.midpoint
			var normPt = line.normal

			p1.x -= DRAWOFFSET
			p1.y -= DRAWOFFSET
			p2.x -= DRAWOFFSET
			p2.y -= DRAWOFFSET
			midPt.x -= DRAWOFFSET
			midPt.y -= DRAWOFFSET
			normPt.x -= DRAWOFFSET
			normPt.y  -= DRAWOFFSET
			
			if lines[i].selected > 0 {
				NSColor.red.set()
			} else {
				lines[i].color.set()
			}
			NSBezierPath.defaultLineWidth = LINE_WIDTH
			NSBezierPath.strokeLine(from: p1, to: p2)			// line
			if currentMode != .thing {
				if lines[i].length != 0 {
					NSBezierPath.strokeLine(from: midPt, to: normPt) // line normal 'tick'
				}
			}
		}
	}
	
	func convertAllPoints() {
		
		convertedPoints = []
		for i in 0..<points.count {
			print("=====")
			print("point coord = \(points[i].coord)")
			var newPoint = points[i]
			newPoint.coord = convert(points[i].coord, from: superview)
			print("converted coord = \(newPoint.coord)")
			convertedPoints.append(newPoint)
		}
	}
	
	///  Draw all world things
	private func drawThings(in dirtyRect: NSRect) {

		thingLoop: for thing in things {
			if thing.selected == -1 {
				continue
			}
			
//			var origin = convert(thing.origin, from: superview)
			var origin = thing.origin
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
//				NSColor.lightGray.set()
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
				let origin = convert(thing.origin, from: superview)
				let originx = Int(origin.x)-(thing.def.size/2)
				let originy = Int(origin.y)-(thing.def.size/2)
				NSBezierPath.stroke(NSRect(x: originx, y: originy, width: thing.def.size, height: thing.def.size))
			}
		}
	}

	// NSRectFillList and similar are extensions on Collection of NSRect: e.g. [rectA, rectB].fill().
	///  Draw all world points
	private func drawPoints(in rect: NSRect) {
		
		var unselected, selected: [NSRect]
		var left,right,bottom,top: CGFloat
		var offset: CGFloat
		var origin = NSPoint()
		var rect = NSRect()
		
		offset = CGFloat(POINT_DRAW_SIZE)
		
		left = rect.origin.x - offset
		right = rect.origin.x + rect.size.width + offset
		bottom = rect.origin.y - offset
		top = rect.origin.y + rect.size.height + offset
		
		unselected = []; selected = []
		

		for i in 0..<points.count {
			let point = points[i]
//			origin = convert(point.coord, from: superview)
			origin = point.coord
			
			if point.selected == -1 {
				continue
			}
			
//			if !visibleRect.contains(origin) {
//				continue
//			}

//			if origin.x < left || origin.x > right || origin.y > top || origin.y < bottom {
//				continue
//			}
			
			if point.selected == 1 {
				rect = NSRect(x: origin.x-offset/2, y: origin.y-offset/2, width: offset, height: offset)
				selected.append(rect)
			} else {
				rect = NSRect(x: origin.x-offset/2, y: origin.y-offset/2, width: offset, height: offset)
				unselected.append(rect)
			}
		}
		
		if unselected.count != 0 {
			COLOR_LINE_ONESIDED.set()
			unselected.fill()
		}
		
		if selected.count != 0 {
			NSColor.red.set()
			selected.fill()
		}
	}
	
	
	// =================================
	// MARK: - Thing Property Indicators
	// =================================
	
	/// Arrow indicating thing direction. Only on things where it matters
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
	
	/// Set up the path for the arrow to be drawn
	func makeArrowPath(_ path: inout NSBezierPath, p1: NSPoint, p2: NSPoint, p3: NSPoint, p4: NSPoint) {
		path.move(to: p1); path.line(to: p2); path.line(to: p3); path.move(to: p4); path.line(to: p2)
		path.lineJoinStyle = .roundLineJoinStyle
		path.lineWidth = 2.0
	}
	
	/// Make left side indicator - Present if thing is flagged EASY
	func strokeEasyMarker(_ thing: Thing, relativeTo rect: NSRect) {
		
		if thing.options & SKILL_EASY != 0 {
			let p1 = NSPoint(x: rect.minX+3+DRAWOFFSET, y: rect.minY+8+DRAWOFFSET)
			let p2 = NSPoint(x: rect.minX+3+DRAWOFFSET, y: rect.maxY-8-DRAWOFFSET)
			NSBezierPath.strokeLine(from: p1, to: p2)
		}
	}

	/// Make top indicator - Present if thing is flagged MEDIUM
	func strokeMediumMarker(_ thing: Thing, relativeTo rect: NSRect) {
		
		if thing.options & SKILL_NORMAL != 0 {
			let p1 = NSPoint(x: rect.minX+8+DRAWOFFSET, y: rect.maxY-3-DRAWOFFSET)
			let p2 = NSPoint(x: rect.maxX-8-DRAWOFFSET, y: rect.maxY-3-DRAWOFFSET)
			NSBezierPath.strokeLine(from: p1, to: p2)
		}
	}
	
	/// Make right side indicator - Present if thing is flagged HARD
	func strokeHardMarker(_ thing: Thing, relativeTo rect: NSRect) {
		
		if thing.options & SKILL_HARD != 0 {
			let p1 = NSPoint(x: rect.maxX-3-DRAWOFFSET, y: rect.minY+8+DRAWOFFSET)
			let p2 = NSPoint(x: rect.maxX-3-DRAWOFFSET, y: rect.maxY-8-DRAWOFFSET)
			NSBezierPath.strokeLine(from: p1, to: p2)
		}
	}
	
	/// Make lower indicator - Present if thing is flagged NETWORK
	func strokeNetworkMarker(_ thing: Thing, relativeTo rect: NSRect) {
		
		if thing.options & NETWORK != 0 {
			let p1 = NSPoint(x: rect.minX+8+DRAWOFFSET, y: rect.minY+3+DRAWOFFSET)
			let p2 = NSPoint(x: rect.maxX-8-DRAWOFFSET, y: rect.minY+3+DRAWOFFSET)
			NSBezierPath.strokeLine(from: p1, to: p2)
		}
	}
	
	/// Make 4 corners indicators - Present if thing is flagged AMBUSH
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
}







