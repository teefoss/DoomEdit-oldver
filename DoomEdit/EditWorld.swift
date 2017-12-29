//
//  MapViewDraw.swift
//  DoomEdit
//
//  Created by Thomas Foster on 9/18/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//
//  World data
//

import Foundation

fileprivate let BOUNDSBORDER = 128
fileprivate let selectionRadius: CGFloat = 16

var editWorld = EditWorld()

var points: [Point] = []
var lines: [Line] = []
var things: [Thing] = []

var numPoints = 0
var numLines = 0
var numThings = 0

class EditWorld {
	
	var loaded: Bool = false
	var bounds: NSRect = CGRect(x: 0, y: 0, width: 100, height: 100)
	var dirty: Bool = true
	var boundsDirty: Bool = false
	var dirtyRect: NSRect = NSRect.zero
	var dirtyPoints: Bool = false

	var sectors: [Sector] = []
	
	var copiedLines: [Line] = []
	var copiedSectors: [Sector] = []
	var copiedThings: [Thing] = []

	
	
	// ================
	// MARK: - Geometry
	// ================
	
	/// Goes through all the points and adjusts the world bounds to encompass them. Returns the new bounds.
	@discardableResult
	func getBounds() -> NSRect {
		
		var right, left, top, bottom: CGFloat
		
		if boundsDirty {
			right = -CGFloat.greatestFiniteMagnitude
			top = -CGFloat.greatestFiniteMagnitude
			left = CGFloat.greatestFiniteMagnitude
			bottom = CGFloat.greatestFiniteMagnitude
			
			for p in 0..<points.count {
				
				let x = CGFloat(points[p].coord.x)
				let y = CGFloat(points[p].coord.y)
				
				if x < left { left = x }
				if x > right { right = x }
				if y < bottom { bottom = y }
				if y > top { top = y }
			}
			
			bounds.origin.x = left - CGFloat(BOUNDSBORDER)
			bounds.origin.y = bottom - CGFloat(BOUNDSBORDER)
			bounds.size.width = right - left + CGFloat(BOUNDSBORDER*2)
			bounds.size.height = top - bottom + CGFloat(BOUNDSBORDER*2)

			boundsDirty = false
		}
		
		if bounds.size.width < 0 {
			bounds = CGRect.zero
		}
		
		return bounds
	}

	func updateLineNormal(_ num: Int) {
		
		let p1 = points[lines[num].pt1].coord
		let p2 = points[lines[num].pt2].coord
		
		let dx = p2.x - p1.x
		let dy = p2.y - p1.y
		let length = sqrt(dx*dx + dy*dy)/CGFloat(LINE_NORMAL_LENGTH)

		lines[num].midpoint.x = p1.x + dx/2
		lines[num].midpoint.y = p1.y + dy/2
		lines[num].normal.x = lines[num].midpoint.x + dy/length
		lines[num].normal.y = lines[num].midpoint.y - dx/length
	}
	
	
	
	// ===========================
	// MARK: - New Data Allocation
	// ===========================

	
	/// Adds a new point to the `points` storage array. Return the index of the new point.
	private func allocatePoint(_ coord: NSPoint) -> Int {
		
		var newPoint = Point()
		newPoint.coord = coord
		
		// set default values
		newPoint.refcount = 1
		newPoint.selected = 0

		points.append(newPoint)
		
		numPoints += 1
		dirtyPoints = true
		
		return numPoints-1
	}
	
	private func newPoint(_ coord: NSPoint) -> Int {
		
		boundsDirty = true
		dirtyPoints = true
		
		let roundedPtx = CGFloat(Int(coord.x))
		let roundedPty = CGFloat(Int(coord.y))

		var roundedPt = Point()
		roundedPt.coord.x = roundedPtx
		roundedPt.coord.y = roundedPty

		// use an existing point if equal. increment its refcount
		for i in 0..<points.count {
			let pt = points[i]
			if pt.selected != -1 && pt.coord.x == roundedPt.coord.x && pt.coord.y == roundedPt.coord.y {
				points[i].refcount += 1
				return i
			}
		}
		return allocatePoint(roundedPt.coord)
	}
	
	/// Decrements a point's reference count. If unused (i.e. refcount is 0), remove it.
	func dropRefCount(for point: Int) {
		if (points[point].refcount - 1) > 0 {
			points[point].refcount -= 1
			return
		}
		points[point].selected = -1
		return
	}

	
	/// Adds a new line to the `lines` array and returns the index it was put in.
	@discardableResult
	func newLine(line: inout Line, from p1: NSPoint, to p2: NSPoint) -> Int {

		numLines += 1

		line.pt1 = newPoint(p1)
		line.pt2 = newPoint(p2)

		lines.append(line)
		//changeLine(numLines-1, to: &line)

		dirtyPoints = true
		boundsDirty = true // added
		
		updateLineNormal(numLines-1)
		
		return numLines - 1
	}
	
	func newThing(_ thing: Thing) {
		things.append(thing)
	}
	
	func changePoint(_ num: Int, to newPoint: Point) {
		var moved: Bool = false
		
		boundsDirty = true
		
		if num < numPoints {
			if newPoint.coord.x == points[num].coord.x && newPoint.coord.y == points[num].coord.y {
				// point's position didn't change
				// TODO: make this happen
				//self.addToDirtRect
				moved = false
			} else {
				//the dirty rect encloses all the lines that use the point, both before and after the move
				// TODO: same
				moved = true
			}
		}
		
		if num >= numPoints {
			fatalError("Error. Sent point \(num) with numPoints \(numPoints)!")
		}
		
		points[num] = newPoint
		
		if moved {
			dirtyPoints = true
			for i in 0..<lines.count {
				if lines[i].selected != -1 && (lines[i].pt1 == num || lines[i].pt2 == num) {
					// TODO: add to dirty rect p1 and p2
					updateLineNormal(i)
				}
			}
		}
	}
	
	func changeLine(_ num: Int, to data: inout Line) {
		
		boundsDirty = true
		
		if num >= numLines {
			fatalError("Error. Sent line \(num) with numLines \(numLines)!")
		}
		
		// TODO: Add to dirty rect
		// Mark the old position of the line as dirty

		// change the line
		
		//if it's a new addition, it must be appended
		if data.selected != 1 {
			// TODO: mark the new position of the line as dirty
			updateLineNormal(num)
		} else {
			dropRefCount(for: lines[num].pt1)
			dropRefCount(for: lines[num].pt2)
		}
	}
	
	func changeThing(_ num: Int, to newThing: Thing) {
		// TODO: changeThing
	}

	
	
	// =======================
	// MARK: - Selection Methods
	// =======================

	func selectPoint(_ i: Int) {
		points[i].selected = 1
	}
	
	func deselectPoint(_ i: Int) {
		points[i].selected = 0
	}
	
	func deselectAllPoints() {
		for i in 0..<points.count {
			if points[i].selected == 1 {
				points[i].selected = 0
			}
		}
	}
	
	func selectLine(_ i: Int) {
		lines[i].selected = 1
		
		// also select its points
		points[lines[i].pt1].selected = 1
		points[lines[i].pt2].selected = 1
	}
	
	func deselectLine(_ i: Int) {
		lines[i].selected = 0
		
		// also deselect its points
		points[lines[i].pt1].selected = 0
		points[lines[i].pt2].selected = 0
	}
	
	func deselectAllLines() {
		for i in 0..<lines.count {
			lines[i].selected = 0
		}
	}
	
	func selectThing(_ i: Int) {
		things[i].isSelected = true
	}
	
	func deselectThing(_ i: Int) {
		things[i].isSelected = false
	}
	
	func deselectAllThings() {
		for i in 0..<things.count {
			things[i].isSelected = false
		}
	}
	
	func deselectAll() {
		deselectAllPoints()
		deselectAllLines()
		deselectAllThings()
	}

	
	
	// ======================================
	// MARK: - Selection Modification Methods
	// ======================================
	
	func flipSelectedLines() {
		
	}
	
	func fusePoints() {

		var p1, p2: NSPoint
		var line: Line
		
		for i in 0..<points.count-1 {
			
			if points[i].selected != 1 {
				continue
			}
			p1 = points[i].coord
			
			// find any points that are on the same spot as point i
			for j in 0..<points.count-1 {
				
				if points[j].selected == -1 || j == i {
					continue
				}
				
				p2 = points[j].coord
				if p1.x != p2.x || p1.y != p2.y {
					continue
				}
				
				// find all lines that use point j
				for k in 0..<lines.count {
					line = lines[k]
					if line.selected == -1 {
						continue
					}
					if line.pt1 == j {
						lines[k].pt1 = i
					} else if line.pt2 == j {
						lines[k].pt2 = i
					}
				}
				points[j].selected = -1
			}
		}
	}
	
	/// All selected points that have a refcount greater than one will have clones made
	func separatePoints() {
		
		var line: Line
		
		for i in 0..<points.count-1 {
			
			if points[i].selected != 1 { continue }
			if points[i].refcount < 2 { continue }
			
			for k in 0..<lines.count {
				
				line = lines[k]
				if line.selected == -1 { continue }
				
				if line.pt1 == i {
					if points[i].refcount == 1 { break }  // all the other uses have been separated
					lines[k].pt1 = allocatePoint(points[i].coord)
					points[i].refcount -= 1
				} else if line.pt2 == i {
					if points[i].refcount == 1 { break }
					lines[k].pt2 = allocatePoint(points[i].coord)
					points[i].refcount -= 1
				}
			}
		}
		
		// TODO: Update windows
	}
	
	

	
	
	
	
	
	
	
	
	
	
	
}
