//
//  MapViewDraw.swift
//  DoomEdit
//
//  Created by Thomas Foster on .
//  Copyright © 2017 Thomas Foster. All rights reserved.
//
//  World data
//

import Foundation

fileprivate let BOUNDSBORDER = 128


/// Global instance of current map
var world = World()

class World {
	
	var loaded: Bool = false
	var bounds: NSRect = CGRect(x: 0, y: 0, width: 100, height: 100)
	var dirty: Bool = true
	var boundsDirty: Bool = false
	var dirtyRect: NSRect = NSRect.zero
	var dirtyPoints: Bool = false
	
	// TODO: change this to [Point] and [Line] eventually
	var points: [TestPoint] = []
	var lines: [TestLine] = []
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

	
	
	// ===========================
	// MARK: - New Data Allocation
	// ===========================

	/// Adds a new point to the `points` storage array
	private func newPoint(_ point: NSPoint) {
		
		boundsDirty = true
		dirtyPoints = true
		
		let roundedPtx = Int(point.x)
		let roundedPty = Int(point.y)

		let newPoint = TestPoint(coord: NSPoint(x: roundedPtx, y: roundedPty))
		
		// TODO: ref
		//var highestRef: Int = -1
		/* reference count not implemented yet
		for pt in points {
			if pt.ref > highestRef {
				highestRef = pt.ref
			}
		}
		*/
		
		//newPoint.ref = highestRef + 1
		
		points.append(newPoint)
	}
	
	/// Adds a new line to 'lines' storage array
	func newLine(from pt1: NSPoint, to pt2: NSPoint) {
		
		newPoint(pt1)
		newPoint(pt2)
		
		let newPt1 = TestPoint(coord: pt1)
		let newPt2 = TestPoint(coord: pt2)

		lines.append(TestLine(pt1: newPt1, pt2: newPt2))
		
		dirtyPoints = true
	}

	
	
	// ========================
	// MARK: - Saving & Loading
	// ========================

	// TODO: stores thing data in world.things
	// TODO: store sidedef data, sector data
	/// Reads data from a `.dwd` file and stores it in `world.lines` and `world.points`
	func loadWorldFile() {
		
		boundsDirty = true
		
		var fileContents: String?		// to store the entire file
		var linesData = [String]()		// to store lines of the file (only ones with line data for now)
		
		// get file contents and put it in fileContents
		if let filepath = Bundle.main.path(forResource: "e4m1", ofType: "dwd") {
			do {
				fileContents = try String(contentsOfFile: filepath)
			} catch {
				// contents could not be loaded
			}
		}
		
		// every line of the file separated
		guard let dataSeparated = fileContents?.components(separatedBy: CharacterSet.newlines) else { return }
		
		// filter out only lines with line data and put in linesData
		for line in dataSeparated {
			if line.first == "t" { break }
			if line.first == "(" {
				linesData.append(line)
			}
		}
		
		// Add all the data to storage arrays
		for line in linesData {
			
			var pt1x: Int = 0
			var pt1y: Int = 0
			var pt2x: Int = 0
			var pt2y: Int = 0
			
			scanDWD(data: line, pt1x: &pt1x, pt1y: &pt1y, pt2x: &pt2x, pt2y: &pt2y)
			
			let pt1 = TestPoint(coord: NSPoint(x: pt1x, y: pt1y))
			let pt2 = TestPoint(coord: NSPoint(x: pt2x, y: pt2y))
			let newLine = TestLine(pt1: pt1, pt2: pt2)
			
			world.points.append(pt1)
			world.points.append(pt2)
			world.lines.append(newLine)
		}
	}
	
	/// Reads a .dwd file and stores the data.
	/// - note: Currently only reads line data in format:
	/// `(1088,-3680) to (1024,-3680) : 1 : 0 : 0`
	private func scanDWD(data: String, pt1x: inout Int, pt1y: inout Int, pt2x: inout Int, pt2y: inout Int) {
		let scanner = Scanner(string: data)
		
		scanner.scanString("(", into: nil)
		scanner.scanInt(&pt1x)
		scanner.scanString(",", into: nil)
		scanner.scanInt(&pt1y)
		scanner.scanString(") to (", into: nil)
		scanner.scanInt(&pt2x)
		scanner.scanString(",", into: nil)
		scanner.scanInt(&pt2y)
	}
	
}
