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
var numPoints = 0
var numLines = 0

class World {
	
	var loaded: Bool = false
	var bounds: NSRect = CGRect(x: 0, y: 0, width: 100, height: 100)
	var dirty: Bool = true
	var boundsDirty: Bool = false
	var dirtyRect: NSRect = NSRect.zero
	var dirtyPoints: Bool = false

	var points: [Point] = []
	var lines: [Line] = []
	var sectors: [Sector] = []
	var things: [Thing] = []
	
	var copiedLines: [Line] = []
	var copiedSectors: [Sector] = []
	var copiedThings: [Thing] = []

	
	
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
	private func newPoint(_ point: NSPoint) -> Int {
		
		boundsDirty = true
		dirtyPoints = true
		
		let roundedPtx = CGFloat(Int(point.x))
		let roundedPty = CGFloat(Int(point.y))

		var newPoint = Point()
		newPoint.coord.x = roundedPtx
		newPoint.coord.y = roundedPty

		// check if the point exists already and just add the new ref if needed
		
		for i in 0..<world.points.count {
			let pt = world.points[i]
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
	}
	
	func newThing(_ thing: Thing) {
		things.append(thing)
	}
	
	

}
