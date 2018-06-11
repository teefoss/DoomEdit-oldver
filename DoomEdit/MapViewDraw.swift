//
//  MapViewDraw.swift
//  DoomEdit
//
//  Created by Thomas Foster on 10/22/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

let DRAWOFFSET: CGFloat = 0.5

// Visual Sizes
let POINT_SELECT_SIZE: CGFloat = 14 // Area around point for detecting click
let POINT_DRAW_SIZE = 4
let THING_DRAW_SIZE = 32
let LINE_WIDTH: CGFloat = 0.0	// minimum so lines are still thin on zoom
let LINE_NORMAL_LENGTH = 6
let SELECTION_BOX_WIDTH: CGFloat = 4.0

/**
MapView Drawing-related Methods
*/

extension MapView {
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		NSGraphicsContext.current?.shouldAntialias = false

		/*
		var rects: UnsafePointer<NSRect>?
		var count: Int = 0
		getRectsBeingDrawn(&rects, count: &count)
		*/
		
		drawGrid(in: dirtyRect)
		
		if currentMode == .thing {
			drawLines(in: dirtyRect)
			drawThings(in: dirtyRect)
		} else if currentMode == .sector {
			drawLines(in: dirtyRect)
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
			var coord = points[index].coord
			coord.x -= boxsize.width/2
			coord.y -= boxsize.width/2
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
					label.textColor = currentStyle.textColor
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
	
	
	private func drawGrid(in rect: NSRect) {
		
		if let context = NSGraphicsContext.current?.cgContext {
			currentStyle.background.setFill()
			context.fill(rect)
			context.flush()
		}

		var x,y,stopx,stopy: Int
		var top,bottom,right,left: CGFloat
		
		left = rect.origin.x-1
		bottom = rect.origin.y-1
		right = rect.origin.x+rect.size.width+2
		top = rect.origin.y+rect.size.height+2
		
		let gridSize_f = CGFloat(gridSize)
		
		//
		// grid
		//
		
		if gridSize_f*scale >= 4 {
			
			// define the limits for the loop
			y = Int(bottom/gridSize_f)
			stopy = Int(top/gridSize_f)
			x = Int(left/gridSize_f)
			stopx = Int(right/gridSize_f)
			
			y *= gridSize
			stopy *= gridSize
			x *= gridSize
			stopx *= gridSize
			
			// adjust if starting or ending x, y is not inside rect
			if CGFloat(y) < bottom {
				y += gridSize }
			if CGFloat(x) < left {
				x += gridSize }
			if CGFloat(stopx) >= right {
				stopx -= gridSize }
			if CGFloat(stopy) >= top {
				stopy -= gridSize }
			
			let gridPath = NSBezierPath()
			
			while y <= stopy {
				if y&63 != 0 {
					addLineToPath(gridPath, Int(left), y, Int(right), y) }
				y += gridSize
			}
			
			while x <= stopx {
				if x&63 != 0 {
					addLineToPath(gridPath, x, Int(top), x, Int(bottom)) }
				x += gridSize
			}
			
			currentStyle.grid.setStroke()
			gridPath.lineWidth = LINE_WIDTH
			gridPath.stroke()
		}
		
		//
		// 64 x 64 tiles
		//
		if scale > 4.0/64 {
			y = Int(bottom/64)
			stopy = Int(top/64)
			x = Int(left/64)
			stopx = Int(right/64)
			
			y *= 64
			stopy *= 64
			x *= 64
			stopx *= 64
			if CGFloat(y) < bottom {
				y += 64 }
			if CGFloat(x) < left {
				x += 64 }
			if CGFloat(stopx) >= right {
				stopx -= 64 }
			if CGFloat(stopy) >= top {
				stopy -= 64 }
			
			let tilePath = NSBezierPath()
			
			while y <= stopy {
				addLineToPath(tilePath, Int(left), y, Int(right), y)
				y += 64
			}
			
			while x <= stopx {
				addLineToPath(tilePath, x, Int(top), x, Int(bottom))
				x += 64
			}
			
			currentStyle.tile.setStroke()
			tilePath.lineWidth = LINE_WIDTH
			tilePath.stroke()
		}
	}
	

	
	/**
	Draw all world lines
	*/
	func drawLines(in rect: NSRect) {
		
		var xc = 0; var yc = 0
		var clippoint: [Int] = Array(repeating: 0, count: points.count)
		
		let left = rect.origin.x-1
		let bottom = rect.origin.y-1
		let right = rect.origin.x + rect.size.width+2
		let top = rect.origin.y + rect.size.height+2
		
		for p in 0..<points.count {
			if points[p].selected == -1 {
				continue }
			
			if points[p].coord.x < left {
				xc = 0 }
			else if points[p].coord.x > right {
				xc = 2 }
			else {
				xc = 1 }
			
			if points[p].coord.y < bottom {
				yc = 0 }
			else if points[p].coord.y > top {
				yc = 2 }
			else {
				yc = 1 }
			
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
			
			if currentMode != .sector && line.selected > 0 {
				NSColor.red.set()
			} else if currentMode == .sector && line.sectorCopy {
				NSColor.blue.set()
			} else if currentMode == .sector && line.sectorPaste {
				NSColor.cyan.set()
			} else {
				line.color.set()
			}
			
			if points[line.pt1].coord.x != points[line.pt2].coord.x ||
				points[line.pt1].coord.y != points[line.pt2].coord.y
			{
				NSBezierPath.defaultLineWidth = LINE_WIDTH
				NSBezierPath.strokeLine(from: points[line.pt1].coord, to: points[line.pt2].coord)			// line
				NSBezierPath.strokeLine(from: line.midpoint, to: line.normal)	// line normal 'tick'
			}
		}
	}
	
	
	
	/**
	Draw all world things
	*/
	private func drawThings(in rect: NSRect) {

		var r = NSRect()
		var left,right,top,bottom: CGFloat
		let offset = CGFloat(THING_DRAW_SIZE)
		
		left = rect.origin.x - offset
		right = rect.origin.x + rect.size.width + offset
		bottom = rect.origin.y - offset
		top = rect.origin.y + rect.size.height + offset
		
		for thing in things {
			
			if thing.selected == -1 {
				continue
			}

			if thing.origin.x < left ||
				thing.origin.x > right ||
				thing.origin.y > top ||
				thing.origin.y < bottom
			{
				continue
			}
			
			// TODO: Only draw selected difficulties
			
			// Set Color
			if thing.selected == 1 {
				NSColor.red.set()
			} else {
				thing.def.color.set()
			}
			
			if currentMode == .line {
				if currentStyle.index == 1 {
					NSColor.black.withAlphaComponent(0.1).set()
				} else if currentStyle.index == 2 {
					NSColor.white.withAlphaComponent(0.2).set()
				} else {
					NSColor.black.withAlphaComponent(0.1).set()
				}
			}
//			if currentMode != .thing {
//			}
			if currentMode != .line || currentMode != .thing {
				r.origin.x = thing.origin.x - offset/2
				r.origin.y = thing.origin.y - offset/2
				r.size.width = offset
				r.size.height = offset
				NSBezierPath.fill(r)

				drawThingMarks(thing, relativeTo: r)
				if thing.def.hasDirection {
					let path = thingArrow(in: r, direction: thing.angle)
					currentStyle.thingInfo.set()
					path.stroke()

				}
			} else if currentMode == .thing {
				NSColor.black.setStroke()
				let origin = thing.origin
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
		var r = NSRect()
		
		var drawsize: CGFloat
		
		if scale >= 1.0 {
			drawsize = CGFloat(POINT_DRAW_SIZE)/scale
		} else {
			drawsize = CGFloat(POINT_DRAW_SIZE)
		}

		
		offset = CGFloat(drawsize)
		
		left = rect.origin.x - offset
		right = rect.origin.x + rect.size.width + offset
		bottom = rect.origin.y - offset
		top = rect.origin.y + rect.size.height + offset
		
		unselected = []; selected = []

		for p in points {

			if p.selected == -1 {
				continue
			}
			
			if p.coord.x < left || p.coord.x > right || p.coord.y > top || p.coord.y < bottom {
				continue
			}
			
			if p.selected == 1 {
				r = NSRect(x: p.coord.x-offset/2, y: p.coord.y-offset/2, width: offset, height: offset)
				selected.append(r)
			} else {
				r = NSRect(x: p.coord.x-offset/2, y: p.coord.y-offset/2, width: offset, height: offset)
				unselected.append(r)
			}
		}
		
		if unselected.count != 0 {
			currentStyle.oneSidedLines.set()
			unselected.fill()
		}
		
		if selected.count != 0 {
			NSColor.red.set()
			selected.fill()
		}
	}
	
	
	// =======================================
	// MARK: - Thing Direction Arrow and Marks
	// =======================================
	
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
		case 0: makeArrowPath(&path, p1: degrees_180, p2: degrees_0, p3: degrees_45, p4: degrees_315)
		case 45: makeArrowPath(&path, p1: diagArrowEnd_225, p2: diagArrowEnd_45, p3: degrees_90, p4: degrees_0)
		case 90: makeArrowPath(&path, p1: degrees_270, p2: degrees_90, p3: degrees_135, p4: degrees_45)
		case 135: makeArrowPath(&path, p1: diagArrowEnd_315, p2: diagArrowEnd_135, p3: degrees_180, p4: degrees_90)
		case 180: makeArrowPath(&path, p1: degrees_0, p2: degrees_180, p3: degrees_225, p4: degrees_135)
		case 225: makeArrowPath(&path, p1: diagArrowEnd_45, p2: diagArrowEnd_225, p3: degrees_270, p4: degrees_180)
		case 270: makeArrowPath(&path, p1: degrees_90, p2: degrees_270, p3: degrees_315, p4: degrees_225)
		case 315: makeArrowPath(&path, p1: diagArrowEnd_135, p2: diagArrowEnd_315, p3: degrees_0, p4: degrees_270)
		default: break
		}
		
		return path
	}
	
	/// Set up the path for the arrow to be drawn
	func makeArrowPath(_ path: inout NSBezierPath, p1: NSPoint, p2: NSPoint, p3: NSPoint, p4: NSPoint) {
		path.move(to: p1); path.line(to: p2); path.line(to: p3); path.move(to: p4); path.line(to: p2)
		path.lineJoinStyle = .roundLineJoinStyle
		path.lineWidth = 2.0
	}
	
	
	func drawThingMarks(_ thing: Thing, relativeTo rect: NSRect) {
		
		currentStyle.thingInfo.setStroke()
		NSBezierPath.defaultLineWidth = 2.0
		
		if thing.hasOption(ThingFlags.skillEasy) {
			let p1 = NSPoint(x: rect.minX+3, y: rect.minY+8)
			let p2 = NSPoint(x: rect.minX+3, y: rect.maxY-8)
			NSBezierPath.strokeLine(from: p1, to: p2)
		}
		
		if thing.hasOption(ThingFlags.skillNormal) {
			let p1 = NSPoint(x: rect.minX+8, y: rect.maxY-3)
			let p2 = NSPoint(x: rect.maxX-8, y: rect.maxY-3)
			NSBezierPath.strokeLine(from: p1, to: p2)
		}
		
		if thing.hasOption(ThingFlags.skillHard) {
			let p1 = NSPoint(x: rect.maxX-3, y: rect.minY+8)
			let p2 = NSPoint(x: rect.maxX-3, y: rect.maxY-8)
			NSBezierPath.strokeLine(from: p1, to: p2)
		}
		
		if thing.hasOption(ThingFlags.network) {
			let p1 = NSPoint(x: rect.minX+8, y: rect.minY+3)
			let p2 = NSPoint(x: rect.maxX-8, y: rect.minY+3)
			NSBezierPath.strokeLine(from: p1, to: p2)
		}
		
		if thing.hasOption(ThingFlags.ambush) {
			let path = NSBezierPath()
			let ul1 = NSPoint(x: rect.minX+3, y: rect.maxY-6)
			let ul2 = NSPoint(x: rect.minX+3, y: rect.maxY-3)
			let ul3 = NSPoint(x: rect.minX+6, y: rect.maxY-3)
			path.move(to: ul1); path.line(to: ul2); path.line(to: ul3)
			
			let ur1 = NSPoint(x: rect.maxX-6, y: rect.maxY-3)
			let ur2 = NSPoint(x: rect.maxX-3, y: rect.maxY-3)
			let ur3 = NSPoint(x: rect.maxX-3, y: rect.maxY-6)
			path.move(to: ur1); path.line(to: ur2); path.line(to: ur3)
			
			let lr1 = NSPoint(x: rect.maxX-6, y: rect.minY+3)
			let lr2 = NSPoint(x: rect.maxX-3, y: rect.minY+3)
			let lr3 = NSPoint(x: rect.maxX-3, y: rect.minY+6)
			path.move(to: lr1); path.line(to: lr2); path.line(to: lr3)
			
			let ll1 = NSPoint(x: rect.minX+6, y: rect.minY+3)
			let ll2 = NSPoint(x: rect.minX+3, y: rect.minY+3)
			let ll3 = NSPoint(x: rect.minX+3, y: rect.minY+6)
			path.move(to: ll1); path.line(to: ll2); path.line(to: ll3)
			
			path.stroke()
		}
		
	}

}







