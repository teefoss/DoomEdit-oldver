//
//  MapView.swift
//  DoomEdit
//
//  Created by Thomas Foster on 9/16/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

protocol EditWorldDelegate {
	func redisplay(_ dirtyRect: NSRect)
}


/**
View that displays the map
*/
class MapView: NSView, NSPopoverDelegate {

	var thingViewController = ThingPanel()
	var linePanel = LinePanel()
	var sectorPanel = SectorPanel()
	
	var delegate: MapViewDelegate?
	var trackingArea: NSTrackingArea?
	var closestPoint: Point? {
		didSet{
			self.setNeedsDisplay(bounds)
		}
	}
	
	var shouldDragSelectionBox: Bool = false
	var didDragSelectionBox: Bool = false
	var selectionBox = NSRect()
	var didDragObject = false
	
	var gridSize: Int = 8
	var scale: CGFloat = 1.0
	
	// dragging objects
	
	
	// for line drawing
	var inDrawMode: Bool = false
	var shapeLayer: CAShapeLayer!
	var shapeLayerIndex: Int!
	var startPoint: NSPoint!
	var endPoint: NSPoint!
	var didDragLine: Bool = false
	
	var didClickThing = false
	var selectedThing = Thing()
	var selectedThingIndex: Int = 0
	
	var didClickLine = false
	var selectedLine = Line()
	var selectedLineIndex: Int = 0
	
	var didClickSector = false
	var selectedDef = SectorDef()
	var selectedSides: [Int] = []
	

	
	func toggleDrawMode() {
		inDrawMode = !inDrawMode
		if inDrawMode {
			currentMode = .draw
			// FIXME: This stopped working?
			NSCursor.crosshair.set()
		} else {
			currentMode = .edit
			NSCursor.arrow.set()
		}
	}
	
	var currentMode: Mode = .edit {
		didSet{
			switch currentMode {
			case .edit:
				window?.title = "\(fullFileName) : Edit Mode"
			case .draw:
				window?.title = "\(fullFileName) : Draw Mode"
			}
		}
	}

	enum Mode {
		case edit
		case draw
	}
	

	
	// ============
	// MARK: - Init
	// ============
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		
		let trackingArea = NSTrackingArea(rect: bounds,
										  options: [.activeInKeyWindow, .inVisibleRect, .mouseMoved],
										  owner: self,
										  userInfo: nil)
		self.trackingArea = trackingArea
		addTrackingArea(trackingArea)

		editWorld.delegate = self
		
//		thingViewController = ThingViewController.init(nibName: NSNib.Name(rawValue: "ThingViewController"), bundle: nil)
	}

	func initPopover(_ popover: inout NSPopover, with viewController: NSViewController) {
		popover = NSPopover.init()
		popover.contentViewController = viewController
		popover.appearance = NSAppearance.init(named: .vibrantLight)
		popover.animates = false
		popover.behavior = .transient
		popover.delegate = self
	}
	
	func displayThingPopover(at thing: NSView) {
		var thingPopover = NSPopover()
		initPopover(&thingPopover, with: thingViewController)
		thingViewController.thing = selectedThing
		thingViewController.thingIndex = selectedThingIndex
		thingPopover.show(relativeTo: thing.bounds, of: thing, preferredEdge: .maxX)
	}
	
	func displayLinePopover(at line: NSView) {
		var linePopover = NSPopover()
		initPopover(&linePopover, with: linePanel)
		linePanel.line = selectedLine
		linePanel.lineIndex = selectedLineIndex
		linePopover.show(relativeTo: line.bounds, of: line, preferredEdge: .maxX)
	}
	
	func displaySectorPanel(at pointRect: NSView) {
		var sectorPanel = NSPopover()
		initPopover(&sectorPanel, with: self.sectorPanel)
		self.sectorPanel.def = selectedDef
		self.sectorPanel.selectedSides = selectedSides
		//sectorPanel.lineIndex = selectedLineIndex
		sectorPanel.show(relativeTo: pointRect.bounds, of: pointRect, preferredEdge: .maxX)
	}

	required init?(coder decoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func updateTrackingAreas() {
		guard var trackingArea = self.trackingArea else {
			return super.updateTrackingAreas()
		}
		removeTrackingArea(trackingArea)
		trackingArea = NSTrackingArea(rect: self.bounds, options: [NSTrackingArea.Options.activeInKeyWindow, NSTrackingArea.Options.inVisibleRect, NSTrackingArea.Options.mouseMoved], owner: self, userInfo: nil)
		self.trackingArea = trackingArea
		addTrackingArea(trackingArea)
	}
	
	
	
	
	// ================================
	// MARK: - View & Coordinate System
	// ================================

	func displayDirty(dirtyrect: NSRect) {
		var rect = NSRect()
		var adjust: CGFloat
		
		adjust = CGFloat(POINT_DRAW_SIZE)
		if adjust <= CGFloat(LINE_NORMAL_LENGTH) {
			adjust = CGFloat(LINE_NORMAL_LENGTH)+1
		}
		
		rect.origin.x = dirtyrect.origin.x - adjust
		rect.origin.y = dirtyrect.origin.y - adjust
		rect.size.width = dirtyrect.size.width + adjust*2
		rect.size.height = dirtyrect.size.height + adjust*2
		
		NSIntegralRect(rect)
		
		self.display(rect)
		
	}
	
	///  Convert a point to the world coordinate system
	///- parameter point: A point in the view coordinate system
	func worldCoord(for point: NSPoint) -> NSPoint {
		
		let pt = convert(point, from: nil)
		
		let xOffset = bounds.origin.x - frame.origin.x
		let yOffset = bounds.origin.y - frame.origin.y
		
		let x = pt.x - xOffset + 1
		let y = pt.y - yOffset + 1
		
		return NSPoint(x: x, y: y)
	}

	///  Convert a point to the view coordinate system
	///- parameter point: A point in the world coordinate system
	func viewCoord(for point: NSPoint) -> NSPoint {
		
		let pt = convert(point, to: nil)
		
		let xOffset = frame.origin.x - bounds.origin.x
		let yOffset = frame.origin.y - bounds.origin.y
		
		let x = pt.x - xOffset - 1
		let y = pt.y - yOffset - 1
		
		return NSPoint(x: x, y: y)
	}
	
	///  Get the grid point closest to the mouse click in world coordinates
	func getWorldGridPoint(from point: NSPoint) -> NSPoint {
		
		var point = worldCoord(for: point)

		point.x = CGFloat(Int(point.x / CGFloat(gridSize) + 0.5 * (point.x < 0 ? -1 : 1)))
		point.y = CGFloat(Int(point.y / CGFloat(gridSize) + 0.5 * (point.y < 0 ? -1 : 1)))
		point.x *= CGFloat(gridSize)
		point.y *= CGFloat(gridSize)
		
		return point
	}
	
	///  Get the grid point closest to the mouse click in view coordinates
	func getViewGridPoint(from point: NSPoint) -> NSPoint {
		
		var point = convert(point, from: nil)
		
		point.x = CGFloat(Int(point.x / CGFloat(gridSize) + 0.5 * (point.x < 0 ? -1 : 1)))
		point.y = CGFloat(Int(point.y / CGFloat(gridSize) + 0.5 * (point.y < 0 ? -1 : 1)))
		point.x *= CGFloat(gridSize)
		point.y *= CGFloat(gridSize)
		
		return point

	}
	
	/**  Returns the current origin of the visible rect in world coordinates  */
	func currentOrigin() -> NSPoint {
		return worldCoord(for: visibleRect.origin)
	}
	
	func setOrigin(for origin: NSPoint) {
		setOrigin(for: origin, with: scale)
	}
	
	func setOrigin(for origin: NSPoint, with scale: CGFloat) {
		adjustFrame(for: origin, with: scale)
	}
	
	
	func adjustFrame(for origin: NSPoint, with scale: CGFloat) {
		
		var map = NSRect()
		var newBounds = NSRect()
		
		if scale != self.scale {
			// FIXME: ???
		}
		
		newBounds = (superview?.bounds)!
		newBounds = convert(newBounds, from: superview)
		newBounds.origin = convert(origin, from: superview)
		
		map = editWorld.getBounds()
		
		newBounds = NSUnionRect(map, newBounds)
		
		if newBounds.size.width != bounds.size.width || newBounds.size.height != bounds.size.height {
			setFrameSize(NSSize(width: newBounds.size.width*CGFloat(scale), height: newBounds.size.height*CGFloat(scale)))
		}

		if newBounds.origin.x != bounds.origin.x || newBounds.origin.y != bounds.origin.y {
			setFrameOrigin(newBounds.origin)
		}		
	}

	/*
	func zoom(from origin: NSPoint, to newScale: Float) {
		
		var currentOrigin = NSPoint()
		var newOrigin = NSPoint()
		
		needsDisplay = false
		
		// find where the point is now
		newOrigin = convert(origin, to: nil)
		
		// change the scale
		let newSize = NSSize(width: frame.size.width/CGFloat(newScale), height: frame.size.height/CGFloat(newScale))
		setBoundsSize(newSize)
		self.scale = newScale

		// convert the point back
		newOrigin = convert(newOrigin, from: nil)
		currentOrigin = self.currentOrigin()
		currentOrigin.x = origin.x - newOrigin.x
		currentOrigin.y = origin.y - newOrigin.y
		setOrigin(for: currentOrigin)
		
		needsDisplay = true
		superview?.display()
	}
	*/
	
	
	
	
	
}
