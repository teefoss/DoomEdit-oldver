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

	
	
	// ==============================
	// MARK: - Visual Related Methods
	// ==============================
	
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
	
	func addPointToDirtyRect(_ point: NSPoint) {
		enclosePoint(rect: &dirtyRect, point: point)
	}

	/// The rect around the two points is added to the dirty rect.
	func addToDirtyRect(pt1: Int, pt2: Int) {
		addPointToDirtyRect(points[pt1].coord)
		addPointToDirtyRect(points[pt2].coord)
	}
	
	// TODO: updateDisplay()
	
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
		
		if num < numPoints {	// can't get a dirty rect from a single new point
			if newPoint.coord.x == points[num].coord.x && newPoint.coord.y == points[num].coord.y {
				// point's position didn't change
				addToDirtyRect(pt1: num, pt2: num)
				moved = false
			} else {
				//the dirty rect encloses all the lines that use the point, both before and after the move
				for i in 0..<lines.count {
					if lines[i].pt1 == num || lines[i].pt2 == num {
						addToDirtyRect(pt1: lines[i].pt1, pt2: lines[i].pt2)
					}
				}
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
					addToDirtyRect(pt1: lines[i].pt1, pt2: lines[i].pt2)
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
		
		// Mark the old position of the line as dirty
		if lines[num].selected != -1 {
			addToDirtyRect(pt1: lines[num].pt1, pt2: lines[num].pt2)
		}

		// change the line
		lines[num] = data
		
		if data.selected != 1 {
			// mark the new position of the line as dirty
			addToDirtyRect(pt1: lines[num].pt1, pt2: lines[num].pt2)
			updateLineNormal(num)
		} else {
			dropRefCount(for: lines[num].pt1)
			dropRefCount(for: lines[num].pt2)
		}
	}
	
	func changeThing(_ num: Int, to newThing: Thing) {
		// TODO: changeThing
	}

	
	
	// =========================
	// MARK: - Selection Methods
	// =========================

	func deselectAll() {
		deselectAllPoints()
		deselectAllLines()
		deselectAllThings()
	}

	
	
	// MARK: Points
	
	func selectPoint(_ num: Int) {
		
		var data: Point
		
		if num >= points.count {
			print("selectPoint: num >= points.count")
			return
		}
		data = points[num]
		if data.selected == -1 {
			return
		}
		data.selected = 1
		changePoint(num, to: data)
	}
	
	func deselectPoint(_ num: Int) {
		
		var data: Point
		
		if num >= points.count {
			print("deselectPoint: num >= points.count")
			return
		}
		data = points[num]
		if data.selected == -1 {
			print("deselectPoint: deleted")
			return
		}
		data.selected = 0
		changePoint(num, to: data)
	}
	
	func deselectAllPoints() {
		for i in 0..<points.count {
			if points[i].selected > 0 {
				points[i].selected = 0
				changePoint(i, to: points[i])
			}
		}
	}
	
	
	
	// MARK: Lines
	
	// NB: Currently points are selected directly instead of calling changePoint (problem?)
	func selectLine(_ num: Int) {
		
		var data: Line

		if num >= lines.count {
			print("selectLine: num >= lines.count")
			return
		}
		data = lines[num]
		if data.selected == -1 {
			print("selectLine: deleted")
			return
		}
		data.selected = 1
		changeLine(num, to: &data)
		points[lines[num].pt1].selected = 1
		points[lines[num].pt2].selected = 1
	}
	
	func deselectLine(_ num: Int) {
		
		var data: Line
		
		if num >= lines.count {
			print("deselectLines: num >= numliness")
			return
		}
		data = lines[num]
		if data.selected == -1 {
			print("deselectLine: deleted point")
			return
		}
		data.selected = 0
		changeLine(num, to: &data)
	}
	
	func deselectAllLines() {
		for i in 0..<lines.count {
			if lines[i].selected > 0 {
				var line = lines[i]
				line.selected = 0
				changeLine(i, to: &line)
			}
		}
	}
	
	
	
	// MARK: Things
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
	

	
	
	// ======================================
	// MARK: - Selection Modification Methods
	// ======================================
	
	func flipSelectedLines() {
		
	}
	
	// FIXME: This does not work with points that have been separated
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
