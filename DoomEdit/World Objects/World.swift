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
var world = World()
var numLines = 0

class World {
	
	var loaded: Bool = false
	var currentMode: Mode = .edit
	var bounds: NSRect = CGRect(x: 0, y: 0, width: 100, height: 100)
	var dirty: Bool = true
	var boundsDirty: Bool = false
	var dirtyRect: NSRect = NSRect.zero
	var dirtyPoints: Bool = false

	
	var linePoints: [Point] {
		var array: [Point] = []
		var shouldAppendPt1: Bool = true
		var shouldAppendPt2: Bool = true
		for i in 0..<lines.count {
			let line = lines[i]
			for pt in array {
				if (line.pt1.coord.x == pt.coord.x && line.pt1.coord.y == pt.coord.y) {
					shouldAppendPt1 = false
				}
				if (line.pt2.coord.x == pt.coord.x && line.pt2.coord.y == pt.coord.y) {
					shouldAppendPt2 = false
				}
			}
			if shouldAppendPt1 {
				array.append(line.pt1)
			}
			if shouldAppendPt2 {
				array.append(line.pt2)
			}
		}
		return array
	}
	
	var points: [Point] = []
	var lines: [Line] = []
	var sectors: [Sector] = []
	var things: [Thing] = []
	
	var copiedLines: [Line] = []
	var copiedSectors: [Sector] = []
	var copiedThings: [Thing] = []

	enum Mode {
		case edit
		case draw
	}
	
	
	// ================
	// MARK: - Geometry
	// ================
	
	/// Go through all the points and adjust the world bounds to encompass them
	func updateBounds() -> NSRect {
		
		var right, left, top, bottom: CGFloat
		
		if boundsDirty {
			right = -CGFloat.greatestFiniteMagnitude
			top = -CGFloat.greatestFiniteMagnitude
			left = CGFloat.greatestFiniteMagnitude
			bottom = CGFloat.greatestFiniteMagnitude
			
			for p in 0..<world.points.count {
				
				let x = CGFloat(world.points[p].coord.x)
				let y = CGFloat(world.points[p].coord.y)
				
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


	/*
	func closestPoint(to point: NSPoint) -> Point? {
		
		var minDistance = CGFloat.greatestFiniteMagnitude
		var closestPt: Point?
		
		for i in 0..<self.points.count {
			let pt = self.points[i]
			let distance = point <-> pt.coord
			
			if distance < selectionRadius && distance < minDistance {
				minDistance = distance
				closestPt = pt
				self.points[i].hovering = true
			} else {
				self.points[i].hovering = false
			}
		}
		return closestPt
	}
	*/
	
	
	// ===========================
	// MARK: - New Data Allocation
	// ===========================

	
	/// Adds a new point to the `points` storage array
	private func newPoint(_ point: NSPoint, with ref: Int) {
		
		boundsDirty = true
		dirtyPoints = true
		
		let roundedPtx = CGFloat(Int(point.x))
		let roundedPty = CGFloat(Int(point.y))

		var newPoint = Point()
		newPoint.coord.x = roundedPtx
		newPoint.coord.y = roundedPty
		newPoint.ref.append(ref)

		// check if the point exists already and just add the new ref if needed
		for i in 0..<points.count {
			let pt = points[i]
			if newPoint.coord.x == pt.coord.x && newPoint.coord.y == pt.coord.y {
				if points[i].ref.contains(ref) {
					return
				} else {
					points[i].ref.append(ref)
				}
				return
			}
		}
		
		points.append(newPoint)
	}

	
	/// Adds a new line to 'lines' storage array
	func newLine(line: inout Line) {

		numLines += 1
		let ref = numLines
		line.ref = ref

		lines.append(line)
		
		newPoint(line.pt1.coord, with: ref)
		newPoint(line.pt2.coord, with: ref)

		dirtyPoints = true
		boundsDirty = true // added
	}
	
	func newThing(_ thing: Thing) {
		things.append(thing)
	}
	
	
	// =========================
	// MARK: - Selection Methods
	// =========================

	func selectPoint(_ i: Int) {
		points[i].isSelected = true
	}
	
	func deselectPoint(_ i: Int) {
		points[i].isSelected = false
	}
	
	func deselectAllPoints() {
		for i in 0..<world.points.count {
			points[i].isSelected = false
		}
	}
	
	func selectLine(_ i: Int) {
		lines[i].isSelected = true
		
		// also select its points
		let ref = lines[i].ref
		for j in 0..<points.count {
			if points[j].ref.contains(ref) {
				points[j].isSelected = true
			}
		}
	}
	
	func deselectLine(_ i: Int) {
		lines[i].isSelected = false
		
		// also deselect its points
		let ref = lines[i].ref
		for j in 0..<points.count {
			if points[j].ref.contains(ref) {
				points[j].isSelected = false
			}
		}
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
