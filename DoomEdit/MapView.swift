//
//  MapView.swift
//  DoomEdit
//
//  Created by Thomas Foster on 9/16/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

protocol MapViewDelegate {
	func zoom(to point: NSPoint, with scale: CGFloat)
	func updateHelpText(for mode: Mode)
}

enum Mode {
	case edit
	case draw
	case line
	case thing
	case test
	case sector
	case point
}


/**
View that displays the map
*/
class MapView: NSView, EditWorldDelegate, NSPopoverDelegate {

	var delegate: MapViewDelegate?
	
	var levelInfo: String
	var gridSize: Int
	var scale: CGFloat

	// Popovers
	var linePopover = NSPopover()
	var thingPopover = NSPopover()
	var sectorPopover = NSPopover()
	
	// View Controllers for popovers
	var thingViewController = ThingViewController()
	var lineViewController = LineViewController()
	var sectorViewController = SectorViewController()
	
	// Windows for detached popovers
	var lineWindow = NSPanel()
	var thingWindow = NSPanel()
	var sectorWindow = NSPanel()
	
	var overlappingPointIndices: [Int] = []
	
	// for line drawing
	var lineCross: [[Bool]] = Array(repeating: Array(repeating: false, count: 9), count: 9)
	
	// selection
	var selectedThing = Thing()
	var selectedThingIndex: Int = 0
	var selectedLineIndex = -1
	var selectedDef = SectorDef()
	var selectedSides: [Int] = []
	
	// testing
	var patchWindow: PatchWindow?
	var testingRect = NSRect()

	
	
	// =============
	// MARK: - Modes
	// =============
	
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
			case .test:
				window?.title = levelInfo + ": Launch at Point"
			case .sector:
				window?.title = levelInfo + ": Sector Mode"
			case .point:
				window?.title = levelInfo + ": Point Mode"
			}
			needsDisplay = true
		}
	}
	var previousMode: Mode = .edit
	
	func setMode(_ mode: Mode) {
		if currentMode != mode {
			currentMode = mode
			delegate?.updateHelpText(for: mode)
		}
		setModeCursor()
	}
	
	func setModeCursor() {
		if currentMode == .draw {
			DispatchQueue.main.async {
				NSCursor.crosshair.set()
			}
		} else if currentMode == .test {
			DispatchQueue.main.async {
				NSCursor.pointingHand.set()
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
		
		// Set up the popovers and link their windows
		initPopover(&linePopover, with: lineViewController, and: &lineWindow)
		initPopover(&thingPopover, with: thingViewController, and: &thingWindow)
		initPopover(&sectorPopover, with: sectorViewController, and: &sectorWindow)
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
	
	required init?(coder decoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	
	
	// ======================================
	// MARK: - Line, Sector, and Thing Panels
	// ======================================

	func popoverShouldDetach(_ popover: NSPopover) -> Bool {
		return true
	}

	func initPopover(_ popover: inout NSPopover, with viewController: NSViewController, and window: inout NSPanel) {
		popover = NSPopover.init()
		popover.contentViewController = viewController
		//popover.appearance = (currentStyle.index == 1) ? (NSAppearance(named: .vibrantLight)) :(NSAppearance(named: .vibrantDark))
		popover.appearance = NSAppearance(named: .aqua)
		popover.animates = false
		popover.behavior = .transient
		popover.delegate = self
		
		let frame = viewController.view.bounds
		let style: NSWindow.StyleMask = [.titled, .closable, .hudWindow, .utilityWindow]
		let contentRect = NSWindow.contentRect(forFrameRect: frame, styleMask: style)
		window = NSPanel(contentRect: contentRect, styleMask: style, backing: .buffered, defer: true)
		window.contentViewController = viewController
		window.isReleasedWhenClosed = false
	}

	func openLinePanel(atLine index: Int) {
		
		let lineRect = NSRect(x: lines[index].midpoint.x-16,
							  y: lines[index].midpoint.y-16,
							  width: 32,
							  height: 32)
		let lineView = NSView(frame: lineRect)
		self.addSubview(lineView)
		linePopover.show(relativeTo: lineView.bounds, of: lineView, preferredEdge: .maxX)
	}
	
	func openThingPanel(atThing index: Int) {
		let thingRect = NSRect(x: things[index].origin.x-16,
							   y: things[index].origin.y-16,
							   width: 32,
							   height: 32)
		let thingView = NSView(frame: thingRect)
		self.addSubview(thingView)
		thingViewController.thing = selectedThing
		thingViewController.thingIndex = index
		thingPopover.show(relativeTo: thingView.bounds, of: thingView, preferredEdge: .maxX)
	}
	
	func openSectorPanel(at event: NSEvent) {
		
		guard let def = getSectorDef(from: event) else { return }
		
		var pointRect = NSRect(x: event.locationInWindow.x-16, y: event.locationInWindow.y-16, width: 32, height: 32)
		pointRect = convert(pointRect, from: nil)
		let pointView = NSView(frame: pointRect)
		self.addSubview(pointView)
		
		copySector(at: event)
		self.sectorViewController.def = def
		
		sectorPopover.show(relativeTo: pointView.bounds, of: pointView, preferredEdge: .maxX)
	}
	
	func updatePanels() {
		
		// FIXME: Only update if detached panel is visible
		
		if let line = lineWindow.contentViewController as? LineViewController {
			line.updatePanel()
		}
		if let thing = thingWindow.contentViewController as? ThingViewController {
			thing.updatePanel()
		}
		if let sector = sectorWindow.contentViewController as? SectorViewController {
			sector.updatePanel()
		}
	}
	
	
	// ================================
	// MARK: - View & Coordinate System
	// ================================

	/// Tells the Map View to redraw the given rect. Adds a margin to cover point edges and line ticks.
	func displayDirty(_ dirtyrect: NSRect) {
		
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
	
	func redisplay(_ rect: NSRect) {
		
		setNeedsDisplay(rect)
	}
	
	@objc func redrawVisibleRect() {
		setNeedsDisplay(visibleRect)
		displayIfNeeded()
	}
	
	/// Get the mouse click location in view coordinates
	func getPoint(from event: NSEvent) -> NSPoint {
		
		var point = event.locationInWindow
		point = convert(point, from: nil)
		
		return point
	}

	/// Get the nearest grid point to the mouse click, in view coordinates.
	func getGridPoint(from event: NSEvent) -> NSPoint {
		
		var point = getPoint(from: event)
		
		point.x = CGFloat(Int(point.x / CGFloat(gridSize) + 0.5 * (point.x < 0 ? -1 : 1)))
		point.y = CGFloat(Int(point.y / CGFloat(gridSize) + 0.5 * (point.y < 0 ? -1 : 1)))
		point.x *= CGFloat(gridSize)
		point.y *= CGFloat(gridSize)

		return point
	}
	
	///  Returns the current origin of the visible rect in world coordinates
	func currentOrigin() -> NSPoint {

		var global = (superview?.bounds)!
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
		
		newBounds = (superview?.visibleRect)!
		newBounds = convert(newBounds, from: superview)
		newBounds.origin = origin

		map = editWorld.getBounds()
		
		newBounds = NSUnionRect(map, newBounds)
		
		if newBounds.size.width != bounds.size.width || newBounds.size.height != bounds.size.height
		{
			// TODO: Adjust for scale
			setFrameSize(NSSize(width: newBounds.size.width, height: newBounds.size.height))
			setBoundsSize(NSSize(width: newBounds.size.width, height: newBounds.size.height))
		}

		if newBounds.origin.x != bounds.origin.x || newBounds.origin.y != bounds.origin.y {
			setFrameOrigin(newBounds.origin)
			setBoundsOrigin(newBounds.origin)
		}		
	}
	
	func updateFrame() {
		frame = editWorld.getBounds()
	}
	
	
	
	
	// =========================
	// MARK: - Main Menu Actions
	// =========================
	
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
		checkPoints()
	}
	
	@IBAction func separatePoint(_ sender: Any) {
		editWorld.separatePoints()
		checkPoints()
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
	
	@IBAction func runMap(_ sender: Any) {
		editWorld.processBSPandLaunch()
	}
	
	@IBAction func setRunMode(_ sender: Any) {
		setMode(.test)
	}
	
	@IBAction func setSectorMode(_ sender: Any) {
		setMode(.sector)
	}
	
	@IBAction func copyLineProperties(_ sender: Any) {
		editWorld.storeLineProperties()
	}
	
	@IBAction func pasteLineProperties(_ sender: Any) {
		editWorld.pasteLineProperties()
	}
	
	// MARK: - Tools Menu
	
	@IBAction func buildSectors(_ sender: Any) {
		if blockWorld.connectSectors() {
			runAlertPanel(title: "Build Sectors", message: "Success!")
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
