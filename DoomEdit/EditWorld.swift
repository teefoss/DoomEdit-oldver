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

	
	/// Adds a new point to the `points` storage array
	private func newPoint(_ point: NSPoint) -> Int {
		
		boundsDirty = true
		dirtyPoints = true
		
		let roundedPtx = CGFloat(Int(point.x))
		let roundedPty = CGFloat(Int(point.y))

		var newPoint = Point()
		newPoint.coord.x = roundedPtx
		newPoint.coord.y = roundedPty

		// check if the point exists already and just add the new ref if needed
		
		for i in 0..<points.count {
			let pt = points[i]
			if pt.coord.x == newPoint.coord.x && pt.coord.y == newPoint.coord.y {
				return i
			}
		}
		
		points.append(newPoint)
		numPoints += 1
		
		return numPoints-1
	}

	
	/// Adds a new line to 'lines' storage array
	func newLine(line: inout Line) {

		numLines += 1

		line.pt1 = newPoint(line.end1.coord)
		line.pt2 = newPoint(line.end2.coord)

		lines.append(line)

		dirtyPoints = true
		boundsDirty = true // added
		
		updateLineNormal(numLines-1)
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
				if lines[i].pt1 == num || lines[i].pt2 == num {
					// TODO: add to dirty rect p1 and p2
					// TODO: update line normal for line i
				}
			}
		}
	}
	
	func changeLine(_ num: Int, to newLine: Line) {
		
		boundsDirty = true
		
		if num >= numLines {
			fatalError("Error. Sent line \(num) with numLines \(numLines)!")
		}
		
		// TODO: Add to dirty rect
		
		// change the line
		lines[num] = newLine
		updateLineNormal(num)
		
	}

	
	
	// =======================
	// MARK: Selection Methods
	// =======================

	func selectPoint(_ i: Int) {
		points[i].isSelected = true
	}
	
	func deselectPoint(_ i: Int) {
		points[i].isSelected = false
	}
	
	func deselectAllPoints() {
		for i in 0..<points.count {
			points[i].isSelected = false
		}
	}
	
	func selectLine(_ i: Int) {
		lines[i].isSelected = true
		
		
		// also select its points
		points[lines[i].pt1].isSelected = true
		points[lines[i].pt2].isSelected = true
	}
	
	func deselectLine(_ i: Int) {
		lines[i].isSelected = false
		
		// also deselect its points
		points[lines[i].pt1].isSelected = false
		points[lines[i].pt2].isSelected = false
		
	}
	
	func deselectAllLines() {
		for i in 0..<lines.count {
			lines[i].isSelected = false
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

	
	
	
	
}
