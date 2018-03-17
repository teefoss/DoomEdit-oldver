//
//  MapViewDraw.swift
//  DoomEdit
//
//  Created by Thomas Foster on 9/18/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//
//  World data
//

import Cocoa

fileprivate let BOUNDSBORDER = 128
fileprivate let selectionRadius: CGFloat = 16

var editWorld = EditWorld()

var points: [Point] = []
var lines: [Line] = []
var things: [Thing] = []

struct CopyLine {
	var line = Line()
	var p1 = NSPoint()
	var p2 = NSPoint()
}

class EditWorld {
	
	var loaded: Bool = false
	var bounds: NSRect = CGRect(x: 0, y: 0, width: 100, height: 100)
	var dirty: Bool = true
	var boundsDirty: Bool = false
	var dirtyRect: NSRect = NSRect.zero
	var dirtyPoints: Bool = false
	var copyLines: [CopyLine] = []
	var copyThings: [Thing] = []
	var copyLoaded: Bool = false
	var copyCoord = NSPoint()
	
	var delegate: EditWorldDelegate?
	
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
		
		if length == 0 {
			return
		}

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
	
	func updateWindows() {
		if dirtyRect.size.width == 0 {
			return
		}
//		dirtyRect.origin.x += 0.5
//		dirtyRect.origin.x += 0.5
		delegate?.redisplay(dirtyRect)
		dirtyRect = NSRect.zero
	}
	
	
	
	// ====================================
	// MARK: - Data Allocation / Alteration
	// ====================================

	/// Adds a new point to the `points` storage array. Return the index of the new point.
	private func allocatePoint(_ coord: NSPoint) -> Int {
		
		var newPoint = Point()
		newPoint.coord = coord
		
		// set default values
		newPoint.refcount = 1
		newPoint.selected = 0

		points.append(newPoint)
		
		dirtyPoints = true
		
		return points.count-1
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

		line.pt1 = newPoint(p1)
		line.pt2 = newPoint(p2)

		lines.append(line)
		changeLine(lines.count-1, to: &line)

		dirtyPoints = true
		boundsDirty = true // added
		
		updateLineNormal(lines.count-1)
		
		return lines.count - 1
	}
	
	/// Adds a new thing to the `things` array and returns the index it was put in.
	@discardableResult
	func newThing(_ thing: Thing) -> Int {
		
		var t = thing
		things.append(t)
		changeThing(things.count-1, to: &t) // call changeThing so the dirty rect is updated
		
		return things.count-1
	}
		
	func changePoint(_ num: Int, to newPoint: Point) {
		var moved: Bool = false
		
		boundsDirty = true
		
		if num < points.count {	// can't get a dirty rect from a single new point
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
		
		if num >= points.count {
			fatalError("Error. Sent point \(num) with numPoints \(points.count)!")
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
		
		if num >= lines.count {
			fatalError("Error. Sent line \(num) with numLines \(lines.count)!")
		}
		
		// Mark the old position of the line as dirty
		if lines[num].selected != -1 {
			addToDirtyRect(pt1: lines[num].pt1, pt2: lines[num].pt2)
		}

		// change the line
		lines[num] = data
		
		if data.selected != -1 {
			// mark the new position of the line as dirty
			addToDirtyRect(pt1: lines[num].pt1, pt2: lines[num].pt2)
			updateLineNormal(num)
		} else {
			dropRefCount(for: lines[num].pt1)
			dropRefCount(for: lines[num].pt2)
		}
	}
	
	func changeThing(_ num: Int, to data: inout Thing) {
		
		var drect: NSRect
		
		boundsDirty = true
		
		if num >= things.count {
			fatalError("Error. Sent thing \(num) with numthings \(things.count)")
		}
		
		// mark the old position as dirty
		if things[num].selected != -1 {
			drect = NSRect(x: data.origin.x - CGFloat(THING_DRAW_SIZE/2),
						   y: data.origin.y - CGFloat(THING_DRAW_SIZE/2),
						   width: CGFloat(THING_DRAW_SIZE),
						   height: CGFloat(THING_DRAW_SIZE))
			dirtyRect = NSUnionRect(drect, dirtyRect)
		}
		
		// change the thing
		things[num] = data
		
		// mark the new position as dirty
		if things[num].selected != -1 {
			drect = NSRect(x: data.origin.x - CGFloat(THING_DRAW_SIZE/2),
						   y: data.origin.y - CGFloat(THING_DRAW_SIZE/2),
						   width: CGFloat(THING_DRAW_SIZE),
						   height: CGFloat(THING_DRAW_SIZE))
			dirtyRect = NSUnionRect(drect, dirtyRect)
		}
		
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
		if num < 0 {  // blockWorld.sectorError may send -1
			return
		}
		data = lines[num]
		if data.selected == -1 {
			print("selectLine: deleted")
			return
		}
		data.selected = 1
		changeLine(num, to: &data)
//		points[lines[num].pt1].selected = 1
//		points[lines[num].pt2].selected = 1
//		selectPoint(lines[num].pt1)
//		selectPoint(lines[num].pt2)
		
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
		deselectPoint(lines[num].pt1)
		deselectPoint(lines[num].pt2)
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
	
	func selectThing(_ num: Int) {
		
		var data: Thing
		
		if num >= things.count {
			print("selectThing: num >= things.count")
		}
		data = things[num]
		if data.selected == -1 {
			print("selectThing: deleted")
			return
		}
		data.selected = 1
		changeThing(num, to: &data)
		// update thing panel
	}
	
	func deselectThing(_ num: Int) {
		
		var data: Thing
		
		if num >= things.count {
			print("deselectThing: num >= things.count")
		}
		data = things[num]
		if data.selected == -1 {
			print("deselectThing: deleted point")
			return
		}
		data.selected = 0
		changeThing(num, to: &data)
	}
	
	func deselectAllThings() {
		for i in 0..<things.count {
			if things[i].selected > 0 {
				var thing = things[i]
				thing.selected = 0
				changeThing(i, to: &thing)
			}
		}
	}
	

	
	
	// ======================================
	// MARK: - Selection Modification Methods
	// ======================================

	// FIXME: not working:
	func flipSelectedLines() {
		
		var line: Line
		var p1, p2: NSPoint
		
		for i in 0..<lines.count {
			if lines[i].selected == 1 {
				line = lines[i]
				p1 = points[line.pt1].coord
				p2 = points[line.pt2].coord
				
				// delete the old line
				line.selected = -1
				changeLine(i, to: &line)

				// deselect the line & add a new one
				line.selected = 0
				points[line.pt1].selected = 0
				points[line.pt2].selected = 0
				newLine(line: &line, from: p2, to: p1)
			}
		}
		updateWindows()
	}
	
	func fusePoints() {

		var p1, p2: NSPoint
		var line: Line
		
		for i in 0..<points.count {
			
			if points[i].selected != 1 {
				continue
			}
			p1 = points[i].coord
			
			// find any points that are on the same spot as point i
			for j in 0..<points.count {
				
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
						points[i].refcount += 1
					} else if line.pt2 == j {
						lines[k].pt2 = i
						points[i].refcount += 1
					}
				}
				points[j].selected = -1		// remove the duplicate point
			}
		}
		updateWindows()
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
		updateWindows()
	}
	
	
	
	// ====================
	// MARK: - Open / Close
	// ====================
	
	func loadWorldFile(_ dwd: String) {
		dirtyRect = .zero
		boundsDirty = false
		
		points = []; lines = []; things = []
		
		loadDWDFile(dwd)
		
		dirty = false
		dirtyPoints = true
		loaded = true
	}
	
	func closeWorld() {
		
		if doomProject.mapDirty {
			let val = runDialogPanel(question: "Hey!", text: "Your map has been modified! Save it?")
			if val {
				saveWorld()
			}
			doomProject.setDirtyMap(false)
		}
		
		points = []; lines = []; things = []
		let appd = NSApplication.shared.delegate as! AppDelegate
		appd.mapWindowController?.close()
		loaded = false
	}
	
	func saveWorld() {
		
		if !loaded {
			runAlertPanel(title: "Error!", message: "No world open")
			return
		}
		saveMap(sender: nil)
		doomProject.setDirtyMap(false)
	}
	

	
	// ====================
	// MARK: - Copy / Paste
	// ====================

	func storeCopies() {

		var cl = CopyLine()
		var r: NSRect
		
		r = NSApp.mainWindow!.contentView!.visibleRect
		copyCoord = r.origin
		copyThings = []
		copyLines = []
		
		for t in things {
			if t.selected == 1 {
				copyThings.append(t)
			}
		}
		for l in lines {
			if l.selected == 1 {
				cl.line = l
				cl.p1 = points[cl.line.pt1].coord
				cl.p2 = points[cl.line.pt2].coord
				copyLines.append(cl)
			}
		}
		copyLoaded = true
	}
	
	/// Deselect everything after copying
	func copyDeselect() {
		
		for i in 0..<things.count {
			if things[i].selected == 1 {
				deselectThing(i)
			}
		}
		for i in 0..<lines.count {
			if lines[i].selected == 1 {
				deselectLine(i)
			}
		}
		for i in 0..<points.count {
			if points[i].selected == 1 {
				deselectPoint(i)
			}
		}
	}
	
	func findMin(num0: CGFloat, num1: CGFloat) -> CGFloat {
		if num1 < num0 {
			return num1
		}
		return num0
	}

	func findMax(num0: CGFloat, num1: CGFloat) -> CGFloat {
		if num1 > num0 {
			return num1
		}
		return num0
	}

	/// Find center point of copied stuff
	func findCopyCenter() -> NSPoint {
		
		var p = NSPoint()
		var xmin: CGFloat = 0.0
		var ymin: CGFloat = 0.0
		var xmax: CGFloat = 0.0
		var ymax: CGFloat = 0.0
		
		for t in copyThings {
			xmin = findMin(num0: xmin, num1: t.origin.x)
			ymin = findMin(num0: ymin, num1: t.origin.y)
			xmax = findMax(num0: xmax, num1: t.origin.x)
			ymax = findMax(num0: ymax, num1: t.origin.y)
		}
		
		for l in copyLines {
			xmin = findMin(num0: xmin, num1: l.p1.x)
			ymin = findMin(num0: ymin, num1: l.p1.y)
			xmax = findMax(num0: xmax, num1: l.p1.x)
			ymax = findMax(num0: ymax, num1: l.p1.y)
			
			xmin = findMin(num0: xmin, num1: l.p2.x)
			ymin = findMin(num0: ymin, num1: l.p2.y)
			xmax = findMax(num0: xmax, num1: l.p2.x)
			ymax = findMax(num0: ymax, num1: l.p2.y)
		}
		
		p.x = (xmax + xmin) / 2
		p.y = (ymax + ymin) / 2
		return p
	}
	
	func cut() {
		storeCopies()
		delete()
		copyDeselect()
		updateWindows()
		doomProject.setDirtyMap(true)
	}
	
	func copy() {
		storeCopies()
		copyDeselect()
		updateWindows()
	}
	
	func paste() {
		
		var xadd, yadd, max, index: Int
		var r = NSRect()
		var p1 = NSPoint()
		var p2 = NSPoint()

		copyDeselect()
		if let mainWindow = NSApp.mainWindow {
			r = mainWindow.contentView!.visibleRect
			print(r)
		} else {
			print("no main window!")
		}

		if !copyLoaded {
			copyCoord = findCopyCenter()
			copyCoord.x -= r.size.width / 2
			copyCoord.y -= r.size.height / 2
			copyLoaded = true
		}
		
		xadd = Int(r.origin.x - copyCoord.x + 16) & -8
		yadd = Int(r.origin.y - copyCoord.y + 16) & -8

		for t in copyThings {
			var th = t
			th.origin.x += CGFloat(xadd)
			th.origin.y += CGFloat(yadd)
			index = newThing(th)
			selectThing(index)
		}
		
		for l in copyLines {
			var line = l
			p1 = l.p1
			p2 = l.p2
			p1.x += CGFloat(xadd)
			p1.y += CGFloat(yadd)
			p2.x += CGFloat(xadd)
			p2.y += CGFloat(yadd)
			index = newLine(line: &line.line, from: p1, to: p2)
			selectLine(index)
			selectPoint(lines[index].pt1)
			selectPoint(lines[index].pt2)
		}
		
		doomProject.setDirtyMap(true)
		updateWindows()
	}
	
	func delete() {
		
		var line: Line
		var thing: Thing
		
		// delete any lines that have both end points selected
		for i in 0..<lines.count {
			if lines[i].selected < 1 {
				continue }
			if points[lines[i].pt1].selected != 1 || points[lines[i].pt2].selected != 1 {
				continue }
			line = lines[i]
			line.selected = -1
			changeLine(i, to: &line)
		}
		
		// delete any selected things
		for i in 0..<things.count {
			if things[i].selected == 1 {
				thing = things[i]
				thing.selected = -1		// remove the thing
				changeThing(i, to: &thing)
			}
		}
		
		doomProject.setDirtyMap(true)
		updateWindows()
	}

}
