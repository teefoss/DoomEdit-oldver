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
	var patchWindow: PatchWindow?
	
	var delegate: MapViewDelegate?
	
	var levelInfo: String
	var gridSize: Int
	var scale: CGFloat
	
	var overlappingPointIndices: [Int] = []
	
	// dragging objects
	var testingRect = NSRect()
	
	// for line drawing
	var lineCross: [[Bool]] = Array(repeating: Array(repeating: false, count: 9), count: 9)
	
	var didClickThing = false
	var selectedThing = Thing()
	var selectedThingIndex: Int = 0
	
	var didClickLine = false
	var selectedLineIndex = -1
	
	var didClickSector = false
	var selectedDef = SectorDef()
	var selectedSides: [Int] = []
	
	
	
	// ==================
	// MARK: - Mode Stuff
	// ==================
	
	var showAllLineLabels: Bool = false
	var showAllThingImages: Bool = false
	
	var currentMode: Mode = .edit {
		didSet{
			switch currentMode {
			case .edit:
				window?.title = levelInfo + ": Edit Mode"
				for view in subviews {
					view.removeFromSuperview()
				}
				showAllLineLabels = false
			case .draw:
				window?.title = levelInfo + ": Create Mode"
			case .line:
				window?.title = levelInfo + ": Line View"
				addLengthLabels()
			case .thing:
				window?.title = levelInfo + ": Thing View"
				addThingImages()
			}
			needsDisplay = true
		}
	}
	
	func setMode(_ mode: Mode) {
		if currentMode != mode {
			currentMode = mode
		}
		setModeCursor()
	}

	enum Mode {
		case edit
		case draw
		case line
		case thing
	}

	
	func setModeCursor() {
		if currentMode == .draw {
			DispatchQueue.main.async {
				NSCursor.crosshair.set()
			}
		} else {
			DispatchQueue.main.async {
				NSCursor.arrow.set()
			}
		}
	}
	

	
	// ============
	// MARK: - Init
	// ============
	
	
	init() {

		levelInfo = "\(doomProject.openMap?.name ?? "") (\(doomProject.openMap?.level ?? "")) "
		gridSize = 8
		scale = 1

		let rect = NSRect(x: 0.0, y: 0.0, width: 100, height: 100)
		super.init(frame: rect)

		if !editWorld.loaded {
			runAlertPanel(title: "Error", message: "MapView inited with NULL world")
			return
		}
		
		editWorld.delegate = self
		initLineCross()
		
		if let currentContext = NSGraphicsContext.current {
			currentContext.shouldAntialias = false
		} else {
			print("no graphics context!")
		}


//		NotificationCenter.default.addObserver(self,
//											   selector: #selector(redrawVisibleRect),
//											   name: NSScrollView.didLiveScrollNotification,
//											   object: nil)
	}
	

	
	@objc func redrawVisibleRect() {
		print("called")
		//setNeedsDisplay(visibleRect)
		displayIfNeeded()
	}

	func initLineCross() {
		for x1 in 0..<3 {
			for y1 in 0..<3 {
				for x2 in 0..<3 {
					for y2 in 0..<3 {
						if (((x1<=1 && x2>=1) || (x1>=1 && x2<=1))
							&& ((y1<=1 && y2>=1) || (y1>=1 && y2<=1)))
						{
							lineCross[y1*3+x1][y2*3+x2] = true
						} else {
							lineCross[y1*3+x1][y2*3+x2] = false
						}
					}
				}
			}
		}
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
	
	/*
	override func updateTrackingAreas() {
		guard var trackingArea = self.trackingArea else {
			return super.updateTrackingAreas()
		}
		removeTrackingArea(trackingArea)
		trackingArea = NSTrackingArea(rect: self.bounds, options: [NSTrackingArea.Options.activeInKeyWindow, NSTrackingArea.Options.inVisibleRect, NSTrackingArea.Options.mouseMoved], owner: self, userInfo: nil)
		self.trackingArea = trackingArea
		addTrackingArea(trackingArea)
	}
	*/
	
	
	
	// ================================
	// MARK: - View & Coordinate System
	// ================================

	func displayDirty(dirtyrect: NSRect) {
		
		var rect = NSRect()
		var adjust: CGFloat
		
		// TODO: Adjust for zoom
		adjust = CGFloat(POINT_DRAW_SIZE)
		if adjust <= CGFloat(LINE_NORMAL_LENGTH) {
			adjust = CGFloat(LINE_NORMAL_LENGTH)+1
		}
		
		rect.origin.x = dirtyrect.origin.x - adjust
		rect.origin.y = dirtyrect.origin.y - adjust
		rect.size.width = dirtyrect.size.width + adjust*2
		rect.size.height = dirtyrect.size.height + adjust*2
		
		NSIntegralRect(rect)
		
		display(rect)
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
		//return worldCoord(for: visibleRect.origin)
		var global = NSRect()
		global = (superview?.bounds)!
		global.origin = convert(global.origin, from: superview)
		
		return global.origin
	}
	
	func setOrigin(for origin: NSPoint) {
		setOrigin(for: origin, withScale: self.scale)
	}
	
	func setOrigin(for origin: NSPoint, withScale scale: CGFloat) {
		adjustFrame(for: origin, with: scale)
		scroll(origin)
	}
	
	func adjustFrame(for origin: NSPoint, with scale: CGFloat) {
		
		var map = NSRect()
		var newBounds = NSRect()
		
		if scale != self.scale {
			// FIXME: ???
		}
		
		newBounds = visibleRect
		newBounds = convert(newBounds, from: superview)
		newBounds.origin = origin

		map = editWorld.getBounds()
		
		newBounds = NSUnionRect(map, newBounds)
		
		if newBounds.size.width != bounds.size.width || newBounds.size.height != bounds.size.height
		{
			// TODO: Adjust for scale
			setBoundsSize(NSSize(width: newBounds.size.width, height: newBounds.size.height))
		}

		if newBounds.origin.x != bounds.origin.x || newBounds.origin.y != bounds.origin.y {
			setBoundsOrigin(newBounds.origin)
		}		
	}
	
	@IBAction func cut(_ sender: Any) {
		editWorld.cut()
	}

	@IBAction func copy(_ sender: Any) {
		editWorld.copy()
	}
	
	@IBAction func paste(_ sender: Any) {
		editWorld.paste()
	}

	@IBAction func delete(_ sender: Any) {
		editWorld.delete()
	}
	
	
	@IBAction func flipLine(_ sender: Any) {
		editWorld.flipSelectedLines()
	}
	
	@IBAction func fusePoint(_ sender: Any) {
		editWorld.fusePoints()
	}
	
	@IBAction func separatePoint(_ sender: Any) {
		editWorld.separatePoints()
	}
	
	@IBAction func increaseGrid(_ sender: Any) {
		self.increaseGrid()
	}
	
	@IBAction func decreaseGrid(_ sender: Any) {
		self.decreaseGrid()
	}
	
	@IBAction func zoomIn(_ sender: Any) {
		let event = NSEvent()
		zoomIn(to: event)
	}
	
	@IBAction func zoomOut(_ sender: Any) {
		let event = NSEvent()
		zoomOut(from: event)
	}
	
	override func cancelOperation(_ sender: Any?) {
		setMode(.edit)
	}
	
	@IBAction func setEditMode(_ sender: Any) {
		setMode(.edit)
	}
	
	@IBAction func setDrawMode(_ sender: Any) {

		if currentMode == .draw {
			setMode(.edit)
		} else {
			setMode(.draw)
		}
		setModeCursor()

	}
	
	@IBAction func setLineMode(_ sender: Any) {
		showAllLineLabels = true
		setMode(.line)
	}
	
	
	@IBAction func saveMap(_ sender: Any) {
		editWorld.saveWorld()
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
