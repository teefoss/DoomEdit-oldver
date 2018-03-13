//
//  MapViewResp.swift
//  DoomEdit
//
//  Created by Thomas Foster on 11/12/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//
//  MapView Responder Methods
//

import Cocoa

// Dragging Objects
/*
fileprivate var cursor = NSPoint.zero
fileprivate var oldDragRect = NSRect.zero
fileprivate var fixedRect = NSRect.zero
fileprivate var dragRect = NSRect.zero
fileprivate var currentDragRect = NSRect.zero
fileprivate var updateRect = NSRect.zero
fileprivate var lineList: [Int] = []
fileprivate var pointList: [Int] = []
fileprivate var thingList:[Int] = []
fileprivate var lineCount: Int = 0
fileprivate var lastPoint: Int = 0
fileprivate var pointCount: Int = 0
fileprivate var totalMoved = NSPoint.zero
fileprivate var moved = NSPoint.zero
*/

/**
MapView Responder Methods
*/

extension MapView {
	
	override var acceptsFirstResponder: Bool {
		return true
	}
	override func becomeFirstResponder() -> Bool {
		return true
	}
	override func resignFirstResponder() -> Bool {
		return true
	}
	
	
	
	
	// ===================
	// MARK: - Key Presses
	// ===================
	
	override func keyDown(with event: NSEvent) {
		
		if event.isARepeat {
			return
		}
		
		switch event.keyCode {
		case Keycode.minus:
			zoomOut(from: event)
			return
		case Keycode.equals:
			zoomIn(to: event)
			return
		case Keycode.l:
			showAllLineLabels = false
			setMode(.line)
			return
		case Keycode.t:
			showAllThingImages = false
			setMode(.thing)
			return
		case Keycode.space:
			if currentMode == .draw {
				setMode(.edit)
			} else {
				setMode(.draw)
			}
			return
		default:
			break
		}
		super.keyDown(with: event)
	}
	
	override func keyUp(with event: NSEvent) {
		switch event.keyCode {
		case Keycode.l:
			setMode(.edit)
		case Keycode.t:
			setMode(.edit)
		default:
			break
		}
	}
	
	
	/// Grid lines get farther apart
	func increaseGrid() {
		if gridSize < 64 {
			gridSize *= 2
			print("grid size = \(gridSize)")
			needsDisplay = true
		}
	}
	
	/// Grid lines get closer together
	func decreaseGrid() {
		if gridSize > 1 {
			gridSize /= 2
			print("grid size = \(gridSize)")
			needsDisplay = true
		}
	}
	
	// FIXME: When mouse is outside window?
	/// Zooms in on mouse location
	func zoomIn(to event: NSEvent) {
		if scale < 4 {
			scale *= 2
			print("scale = \(scale*100)%")
			let mouseLoc = worldCoord(for: event.locationInWindow)
			delegate?.zoom(to: mouseLoc, with: scale)
			frame = editWorld.getBounds()
		} else {
			NSSound.beep()
		}
	}
	
	/// Zooms out from mouse location
	func zoomOut(from event: NSEvent) {
		if scale > 0.125 {
			scale /= 2
			print("scale = \(scale*100)%")
			let mouseLoc = worldCoord(for: event.locationInWindow)
			delegate?.zoom(to: mouseLoc, with: scale)
			frame = editWorld.getBounds()
		} else {
			NSSound.beep()
		}
	}
	
	
	
	
	// ===========================
	// MARK: - Testing Information
	// ===========================
	
	func printCoordInfo() {
		print("frame: \(frame)")
		print("frame.origin.x: \(frame.origin.x)")
		print("bounds: \(bounds)")
		print("visibleRect: \(visibleRect)")
		let converted = convert(visibleRect.origin, from: nil)
		print("viz rect origin converted: \(converted)")
	}
	
	
	
	
	// =====================
	// MARK: - Mouse Actions
	// =====================
	
	override func mouseDown(with event: NSEvent) {
		
		switch currentMode {
		case .edit, .line:
			selectObject(at: event, shouldDrag: true)
		case .draw:
			dragLine(event)
			//drawLine_LMDown(with: event)
		case .thing:
			return
		}
		editWorld.updateWindows()
	}
	
	override func mouseDragged(with event: NSEvent) {
		
		switch currentMode {
		case .edit, .line:
			print("To do")
		case .draw:
			print("To do")
			//drawLine_LMDragged(with: event)
		case .thing:
			return
		}
	}
	
	override func mouseUp(with event: NSEvent) {
		
		needsDisplay = true
		
		switch currentMode {
		case .edit, .line:
			print("To do")
		case .draw:
//			if didDragLine {
//				drawLine_LMUp()
//			}
			print("Todo")
		case .thing:
			return
		}
	}
	
	override func rightMouseDown(with event: NSEvent) {
		
		if currentMode == .draw {
			placeThing(at: event)
			editWorld.updateWindows()
			return
		}
		
		selectObject(at: event, shouldDrag: false)
		if didClickThing {
			let thingRect = NSRect(x: selectedThing.origin.x-16, y: selectedThing.origin.y-16, width: 32, height: 32)
			let newThingRect = convert(thingRect, from: superview)
			let thingView = NSView(frame: newThingRect)
			self.addSubview(thingView)
			displayThingPopover(at: thingView)
			didClickThing = false
		} else if didClickLine {
			let lineRect = NSRect(x: lines[selectedLineIndex].midpoint.x-16, y: lines[selectedLineIndex].midpoint.y-16, width: 32, height: 32)
			let newLineRect = convert(lineRect, from: superview)
			let lineView = NSView(frame: newLineRect)
			self.addSubview(lineView)
			//editWorld.selectLine(selectedLineIndex)
			//editWorld.updateWindows()
			displayLinePopover(at: lineView)
			didClickLine = false
		} else if didClickSector {
			if !event.modifierFlags.contains(.shift) {
				let pointRect = NSRect(x: event.locationInWindow.x-16, y: event.locationInWindow.y-16, width: 32, height: 32)
				let newPointRect = convert(pointRect, from: nil)
				let pointView = NSView(frame: newPointRect)
				self.addSubview(pointView)
				let clickpoint = worldCoord(for: event.locationInWindow)
				blockWorld.floodFillSector(from: clickpoint)
				setCurrentSector()
				displaySectorPanel(at: pointView)
				selectedSides = []
				didClickSector = false
				setNeedsDisplay(self.bounds)
			} else {
				let clickpoint = worldCoord(for: event.locationInWindow)
				blockWorld.floodFillSector(from: clickpoint)
				setCurrentSector()
				selectedSides = []
				didClickSector = false
				setNeedsDisplay(self.bounds)
			}
		}
		editWorld.updateWindows()
	}
	
	
	
	// =========================
	// MARK: - Selection Methods
	// =========================
	
	// https://stackoverflow.com/questions/33158513/checking-keydown-event-modifierflags-yields-error
	/// Selects a point at the mouse location. If no point is present, selects a line or thing.
	func selectObject(at event: NSEvent, shouldDrag: Bool) {
		
		var pointIndex: Int = -1
		var thingIndex: Int = -1
		var pt = Point()
		var left, right, top, bottom: CGFloat  // For a box around the click point
		var clickPoint: NSPoint
		
		clickPoint = worldCoord(for: event.locationInWindow)
		
		//
		// see if the click hit a point
		//
		
		// TODO: adjust this after zooming fixed
		// set up a box around the click point
		left = clickPoint.x - POINT_SIZE/scale/CGFloat(2)
		right = clickPoint.x + POINT_SIZE/scale/CGFloat(2)
		bottom = clickPoint.y - POINT_SIZE/scale/CGFloat(2)
		top = clickPoint.y + POINT_SIZE/scale/CGFloat(2)
		
		for i in 0..<points.count {
			pt = points[i]
			if pt.selected == -1 {
				continue }	// deleted point
			// if the point is inside the box
			if pt.coord.x > left && pt.coord.x < right &&
				pt.coord.y < top && pt.coord.y > bottom {
				pointIndex = i
				break	// got one, move on
			}
		}
		
		
		// clicked a point
		if pointIndex >= 0 && pointIndex < points.count {
			
			// if the point is already selected
			if points[pointIndex].selected == 1 {
				if !event.modifierFlags.contains(.shift) {
					if shouldDrag {
						dragObjects(with: event)
					}
					return
				} else {
					editWorld.deselectPoint(pointIndex)
					return
				}
				// point is not already selected
			} else {
				// shift is not being held
				if !event.modifierFlags.contains(.shift) {
					editWorld.deselectAll()
					editWorld.selectPoint(pointIndex)
					if shouldDrag {
						dragObjects(with: event)
					}
					return
				} else {
					editWorld.selectPoint(pointIndex)
					if shouldDrag {
						dragObjects(with: event)
					}
					return
				}
			}
		}
		
		//
		// didn't hit a point, check for a line
		//
		
		for i in 0..<lines.count {
			
			if lines[i].selected == -1 {
				continue
			}
			
			let p1 = points[lines[i].pt1].coord
			let p2 = points[lines[i].pt2].coord
			
			if (p1.x < left && p2.x < left)
				|| (p1.x > right && p2.x > right)		// DoomEd p2.x > left, mistake?
				|| (p1.y > top && p2.y > top)
				|| (p1.y < bottom && p2.y < bottom)
			{
				continue
			}
			
			
			let layer = CAShapeLayer()
			layer.lineWidth = 32.0
			let path = CGMutablePath()
			path.move(to: p1)
			path.addLine(to: p2)
			layer.path = path
			
			let newPath = path.copy(strokingWithWidth: 32.0, lineCap: .butt, lineJoin: .miter, miterLimit: 1.0)
			
			// Clicked on a line
			if newPath.contains(clickPoint) {
				// line is already selected
				if lines[i].selected > 0 {
					if !event.modifierFlags.contains(.shift) {
						if shouldDrag {
							dragObjects(with: event)
						}
						didClickLine = true
						selectedLineIndex = i
						return
					} else {
						editWorld.deselectLine(i)
						return
					}
					// line is not already selected
				} else {
					// shift if not held
					if !event.modifierFlags.contains(.shift) {
						editWorld.deselectAll()
						editWorld.selectLine(i)
						if shouldDrag {
							dragObjects(with: event)
						}
						didClickLine = true
						selectedLineIndex = i
						return
						// shift is held
					} else {
						editWorld.selectLine(i)
						if shouldDrag {
							dragObjects(with: event)
						}
						didClickLine = true
						selectedLineIndex = i
						return
					}
				}
			}
			
		}
		
		
		//
		// didn't hit a line, check for a thing
		//
		if currentMode == .line {
			if !event.modifierFlags.contains(.shift) {
				editWorld.deselectAll()
			}
			if shouldDrag {
				dragSelectionBox(event)
			}
			return
		}
		
		left = clickPoint.x - CGFloat(THING_DRAW_SIZE/2)
		right = clickPoint.x + CGFloat(THING_DRAW_SIZE/2)
		bottom = clickPoint.y - CGFloat(THING_DRAW_SIZE/2)
		top = clickPoint.y +  CGFloat(THING_DRAW_SIZE/2)
		
		for i in 0..<things.count {
			
			let thing = things[i]
			
			if thing.selected == -1 {
				continue
			}
			if thing.origin.x > left && thing.origin.x < right
				&& thing.origin.y < top && thing.origin.y > bottom {
				thingIndex = i
				break
			}
		}
		
		if thingIndex >= 0 && thingIndex < things.count {
			
			// Thing is already selected
			if things[thingIndex].selected == 1 {
				if !event.modifierFlags.contains(.shift) {
					if shouldDrag {
						dragObjects(with: event)
					}
					didClickThing = true
					selectedThing = things[thingIndex]
					selectedThingIndex = thingIndex
					return
				} else {
					editWorld.deselectThing(thingIndex)
					return
				}
				// Thing is not already selected
			} else if things[thingIndex].selected == 0 {
				if !event.modifierFlags.contains(.shift) {
					editWorld.deselectAll()
					editWorld.selectThing(thingIndex)
					if shouldDrag {
						dragObjects(with: event)
					}
					didClickThing = true
					selectedThing = things[thingIndex]
					selectedThingIndex = thingIndex
					print(things[thingIndex].type)
					
					return
				} else {
					editWorld.selectThing(thingIndex)
					if shouldDrag {
						dragObjects(with: event)
					}
					didClickThing = true
					selectedThing = things[thingIndex]
					selectedThingIndex = thingIndex
					return
				}
			}
		}
		
		//
		//  Hit nothing, drag a selection box & get the sector def
		//
		if !event.modifierFlags.contains(.shift) {
			editWorld.deselectAll()
			didClickSector = true
			if let def = getSector(from: event.locationInWindow) {
				selectedDef = def
			} else {
				didClickSector = false
			}
		}
		if shouldDrag {
			dragSelectionBox(event)
		}
	}
	
	
	
	// Selection box:
	// https://stackoverflow.com/questions/20357960/drawing-selection-box-rubberbanding-marching-ants-in-cocoa-objectivec
	// Mouse-tracking loop:
	// https://stackoverflow.com/questions/22389685/nsbutton-mousedown-mouseup-behaving-differently-on-enabled/27216356#27216356
	
	/// Drag a selection box, select lines and things
	func dragSelectionBox(_ event: NSEvent) {
		
		var theEvent: NSEvent?
		let startPoint = convert(event.locationInWindow, from: nil)
		var dragPoint = NSPoint()
		var selectionBox = NSRect()
		
		var shapeLayer = CAShapeLayer()
		shapeLayer.lineWidth = SELECTION_BOX_WIDTH
		shapeLayer.fillColor = NSColor.clear.cgColor
		shapeLayer.strokeColor = NSColor.gray.cgColor
		layer?.addSublayer(shapeLayer)
		
		repeat {
			
			theEvent = window?.nextEvent(matching: NSEvent.EventTypeMask.leftMouseUp.union(.leftMouseDragged))
			
			dragPoint = convert((theEvent?.locationInWindow)!, from: nil)
			
			let path = CGMutablePath()
			path.move(to: NSPoint(x: startPoint.x, y: startPoint.y))
			path.addLine(to: NSPoint(x: dragPoint.x, y: startPoint.y))
			path.addLine(to: NSPoint(x: dragPoint.x, y: dragPoint.y))
			path.addLine(to: NSPoint(x: startPoint.x, y: dragPoint.y))
			path.closeSubpath()
			let pt1 = convert(startPoint, to: superview)
			let pt2 = convert(dragPoint, to: superview)
			makeRect(&selectionBox, with: pt1, and: pt2)
			shapeLayer.path = path
			
			print("loop")
			
		} while theEvent?.type != .leftMouseUp
		
		shapeLayer.removeFromSuperlayer()
		
		var box1 = Box()	// the selection box
		var box2 = Box()	// a box around a line
		
		// get points in the selection box
		for i in 0..<points.count {
			let pt = points[i].coord
			if NSPointInRect(pt, selectionBox) {
				editWorld.selectPoint(i)
			}
		}
		
		// get lines in the selection box
		makeBox(&box1, from: selectionBox)
		for i in 0..<lines.count {
			
			var p1 = points[lines[i].pt1].coord
			var p2 = points[lines[i].pt2].coord
			
			makeBox(&box2, with: p1, and: p2)
			
			if box1.right < box2.left || box1.left > box2.right ||
				box1.top < box2.bottom || box1.bottom > box2.top {
				continue
			}
			
			if lineInRect(x0: &p1.x, y0: &p1.y, x1: &p2.x, y1: &p2.y, rect: selectionBox) {
				editWorld.selectLine(i)
			}
		}
		
		// get things in the selection box
		if currentMode == .line {
			return
		}
		for i in 0..<things.count {
			let org = things[i].origin
			if NSPointInRect(org, selectionBox) {
				editWorld.selectThing(i)
			}
		}
	}
	
	
	
	// ========================
	// dragObjects(with event:)
	// ========================
	
	func dragObjects(with event: NSEvent) {
		
		var cursor, moved, totalMoved: NSPoint
		
		var oldDragRect = NSRect()
		var fixedRect = NSRect()
		var dragRect = NSRect()
		var currentDragRect = NSRect()
		var updateRect = NSRect()
		
		var lineList: [Int] = []
		var pointList: [Int] = []
		var thingList: [Int] = []
		
		var lineCount = 0
		var lastPoint = 0
		var pointCount = 0
		
		
		cursor = getWorldGridPoint(from: event.locationInWindow)
		
		// set up negative rects
		fixedRect.origin.x = CGFloat.greatestFiniteMagnitude/4
		fixedRect.origin.y = CGFloat.greatestFiniteMagnitude/4
		fixedRect.size.width = -CGFloat.greatestFiniteMagnitude/2
		fixedRect.size.height = -CGFloat.greatestFiniteMagnitude/2
		dragRect = fixedRect
		
		// if only one endpoint of a line is selected, the other end will contribute to the fixedrect
		for i in 0..<lines.count {
			
			if lines[i].selected == -1 {
				continue
			}
			
			let pt1selected = points[lines[i].pt1].selected == 1
			let pt2selected = points[lines[i].pt2].selected == 1
			
			if pt1selected || pt2selected {
				lineList.append(i)
			}
			
			if pt1selected && !pt2selected {
				enclosePoint(rect: &fixedRect, point: points[lines[i].pt2].coord)  // pt2 is fixed
			} else if pt2selected && !pt1selected {
				enclosePoint(rect: &fixedRect, point: points[lines[i].pt1].coord)  // pt1 is fixed
			}
		}
		
		lineCount = lineList.count
		
		//
		// the dragrect encloses all selected points
		//
		let offset = CGFloat((THING_DRAW_SIZE/2) + 2)
		
		for i in 0..<points.count {
			if points[i].selected == 1 {
				pointCount += 1
				lastPoint = i
				pointList.append(i)
				enclosePoint(rect: &dragRect, point: points[i].coord)
			}
		}
		
		for i in 0..<things.count {
			if things[i].selected == 1 {
				var pt: NSPoint
				
				pt = things[i].origin
				pt.x -= offset
				pt.y -= offset
				enclosePoint(rect: &dragRect, point: pt)
				pt.x = things[i].origin.x + offset
				pt.y = things[i].origin.y + offset
				enclosePoint(rect: &dragRect, point: pt)
				
				thingList.append(i)
			}
		}
		
		oldDragRect = dragRect		// absolute coordinates
		
		dragRect.origin.x -= cursor.x	// relative to cursor
		dragRect.origin.y -= cursor.y
		
		//
		// Mouse-tracking loop
		//
		moved = cursor
		totalMoved = cursor
		var theEvent: NSEvent?
		
		repeat {
			
			theEvent = window?.nextEvent(matching: NSEvent.EventTypeMask.leftMouseDragged.union(.leftMouseUp))
			if theEvent?.type == .leftMouseUp {
				break
			}
			
			// calculate new rectangle
			cursor = getWorldGridPoint(from: (theEvent?.locationInWindow)!) // handle grid and such
			
			// move all selected points
			if pointCount == 1 {
				if points[lastPoint].coord.x == cursor.x && points[lastPoint].coord.y == cursor.y {
					continue
				}
				points[lastPoint].coord = cursor
			} else {
				if cursor.x == moved.x && cursor.y == moved.y {
					continue
				}
				
				moved.x = cursor.x - moved.x
				moved.y = cursor.y - moved.y
				
				for i in 0..<points.count {
					if points[i].selected == 1 {
						points[i].coord.x += moved.x
						points[i].coord.y += moved.y
					}
				}
				
				for i in 0..<things.count {
					if things[i].selected == 1 {
						things[i].origin.x += moved.x
						things[i].origin.y += moved.y
					}
				}
				
				if moved.x != 0 || moved.y != 0 {
					print("dirty map")
					doomProject.setDirtyMap(true)
				}
				
				moved = cursor
			}
			
			// update line normals
			for i in 0..<lineCount {
				editWorld.updateLineNormal(lineList[i])
			}
			
			// redraw new frame
			currentDragRect = dragRect
			currentDragRect.origin.x += cursor.x
			currentDragRect.origin.y += cursor.y
			updateRect = currentDragRect
			updateRect = NSUnionRect(oldDragRect, updateRect)
			updateRect = NSUnionRect(fixedRect, updateRect)
			oldDragRect = currentDragRect;
			var viewUpdateRect = convert(updateRect, from: superview)
			
			// extend to include any line normals and point edges
			viewUpdateRect.origin.x -= CGFloat(LINE_NORMAL_LENGTH+1)
			viewUpdateRect.origin.y -= CGFloat(LINE_NORMAL_LENGTH+1)
			viewUpdateRect.size.width += CGFloat(LINE_NORMAL_LENGTH*2+1)
			viewUpdateRect.size.height += CGFloat(LINE_NORMAL_LENGTH*2+1)

			var testingRect = viewUpdateRect
			testingRect.origin.x += 1
			testingRect.origin.y += 1
			testingRect.size.width -= 2
			testingRect.size.height -= 2
			self.testingRect = testingRect
			
			print(viewUpdateRect)
			setNeedsDisplay(viewUpdateRect)
			
		} while true
		
		// tell the world about the changes
		// the points have to be set back to their original positions before sending
		// the new point to the server so the dirty rect will contain everything touched
		// by the old and new positions
		
		totalMoved.x = cursor.x - totalMoved.x;
		totalMoved.y = cursor.y - totalMoved.y;
		
		print("totalMoved = \(totalMoved)")
		
		for i in 0..<points.count {
			if points[i].selected == 1 {
				let newPoint = points[i]
				points[i].coord.x -= totalMoved.x
				points[i].coord.y -= totalMoved.y
				editWorld.changePoint(i, to: newPoint)
				
				if (totalMoved.x != 0 || totalMoved.y != 0) {
					print("map dirty!")
					doomProject.setDirtyMap(true)
				}
			}
		}
	}
	
	
	
	// =====================
	// MARK: - Line Drawing
	// =====================
	
	func dragLine(_ event: NSEvent) {
		// TODO: Draw the 'tick' mark while adding a line
		
		var fixedPoint, dragPoint: NSPoint
		var shapeLayer = CAShapeLayer()
		var shapeLayerIndex: Int?

		editWorld.deselectAll()

		// animated drawing is done in view coord system
		fixedPoint = getViewGridPoint(from: event.locationInWindow)
		dragPoint = fixedPoint
		shapeLayer.lineWidth = 1.0
		shapeLayer.fillColor = NSColor.clear.cgColor
		shapeLayer.strokeColor = NSColor.black.cgColor
		layer?.addSublayer(shapeLayer)
		shapeLayerIndex = layer?.sublayers?.index(of: shapeLayer)
		
		//
		// Mouse-tracking loop
		//
		var nextEvent: NSEvent?
		repeat {
			
			nextEvent = window?.nextEvent(matching: NSEvent.EventTypeMask.leftMouseDragged.union(.leftMouseUp))
			dragPoint = getViewGridPoint(from: (nextEvent?.locationInWindow)!)
			
			let path = CGMutablePath()
			path.move(to: fixedPoint)
			path.addLine(to: dragPoint)
			shapeLayer.path = path
			
		} while nextEvent?.type != .leftMouseUp
		
		var line = Line()
		line.side[0] = lines.last?.side[0]
		
		if let i = shapeLayerIndex {
			layer?.sublayers?.remove(at: i)
		}
		
		// convert startPoint to world coord
		let pt1 = convert(fixedPoint, to: superview)
		
		// convert endPoint to world coord
		let pt2 = convert(dragPoint, to: superview)
		// if line didn't end where it started
		if pt1.x == pt2.x && pt1.y == pt2.y {
			return
		}
		editWorld.deselectAll()
		editWorld.newLine(line: &line, from: pt1, to: pt2)
//		editWorld.selectLine(lines.count-1)
		frame = editWorld.getBounds()
		var updateRect = NSRect()
		makeRect(&updateRect, with: pt1, and: pt2)
		setNeedsDisplay(bounds)
		

		doomProject.mapDirty = true

		
	}
	
	/*
	func drawLine_LMDown(with event: NSEvent) {

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
	*/
	
	
	
	// ====================
	// MARK: - Sector Stuff
	// ====================
	
	func lineByPoint(point: NSPoint, side: inout Int) -> Int {
		
		var pt = point
		var bestDistance: CGFloat = CGFloat.greatestFiniteMagnitude
		var p1, p2: NSPoint
		var frac, xIntercept, distance: CGFloat
		var bestLine: Int = -1
		
		pt.x += 0.5
		pt.y += 0.5
		
		// find the closest line to the given point
		for l in 0..<lines.count {
			
			if lines[l].selected == -1 {
				continue
			}
			
			p1 = points[lines[l].pt1].coord
			p2 = points[lines[l].pt2].coord
			
			if p1.y == p2.y {
				continue
			}
			
			if p1.y < p2.y {
				frac = (pt.y - p1.y) / (p2.y - p1.y)
				if frac < 0 || frac > 1 {
					continue
				}
				xIntercept = p1.x + frac*(p2.x - p1.x)
			}
				
			else {
				frac = (pt.y - p2.y) / (p1.y - p2.y)
				if frac < 0 || frac > 1 {
					continue
				}
				xIntercept = p2.x + frac*(p1.x - p2.x)
			}
			
			distance = abs(xIntercept - pt.x)
			if distance < bestDistance {
				bestDistance = distance
				bestLine = l
			}
		}
		
		// if no line is intercepted, the point was outside all areas
		if bestDistance == CGFloat.greatestFiniteMagnitude {
			side = 0
			return -1
		}
		side = lineSideToPoint(lines[bestLine], to: pt)
		return bestLine
	}
	
	func lineSideToPoint(_ line: Line, to point: NSPoint) -> Int {
		
		var p1, p2: NSPoint
		var slope, yintercept: CGFloat
		var direction, test: Int
		
		p1 = points[line.pt1].coord
		p2 = points[line.pt2].coord
		
		if p1.y == p2.y {
			var r1, r2: Int
			p1.x < p2.x ? (r1 = 1) : (r1 = 0)
			point.y < p1.y ? (r2 = 1) : (r2 = 0)
			return r1 ^ r2
		}
		if p1.x == p2.x {
			var r1, r2: Int
			p1.y < p2.y ? (r1 = 1) : (r1 = 0)
			point.x > p1.x ? (r2 = 1) : (r2 = 0)
			return r1 ^ r2
		}
		
		slope = (p2.y - p1.y) / (p2.x - p1.x)
		yintercept = p1.y - slope*p1.x
		
		// for y > mx+b, substitute in the normal point, which is on the front
		if line.normal.y > slope*line.normal.x + yintercept {
			direction = 1
		} else {
			direction = 0
		}
		if point.y > slope*point.x + yintercept {
			test = 1
		} else {
			test = 0
		}
		if direction == test {
			return 0	// front side
		}
		return 1		// back side
	}
	
	func getSector(from point: NSPoint) -> SectorDef? {
		
		var pt: NSPoint
		var line: Int
		var side: Int = 0
		
		pt = worldCoord(for: point)
		line = lineByPoint(point: pt, side: &side)
		
		if let def = lines[line].side[side]?.ends {
			return def
		}
		return nil
	}
	
	func setCurrentSector() {
		for i in 0..<lines.count {
			if lines[i].selected < 1 {
				continue
			} else if lines[i].selected == 1 {
				selectedSides.append(i)
			} else if lines[i].selected == 2 {
				selectedSides.append(i | SIDE_BIT)
			}
		}
		print(selectedSides)
	}
	
	
	
	// Mark: -
	
	func placeThing(at event: NSEvent) {
		
		//let loc = worldCoord(for: event.locationInWindow)
		let loc = getWorldGridPoint(from: event.locationInWindow)
		
		var newThing = Thing(selected: 0, origin: loc, angle: things[things.count-1].angle, type: things[things.count-1].type, options: things[things.count-1].options)
		things.append(newThing)
		editWorld.changeThing(things.count-1, to: &newThing)
		doomProject.setDirtyMap(true)
	}
	
	
	
}
