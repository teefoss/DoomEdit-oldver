//
//  MapWindowController.swift
//  DoomEdit
//
//  Created by Thomas Foster on 11/21/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

extension NSNib.Name {
	static let MapWindowController = NSNib.Name("MapWindowController")
}

protocol MapViewDelegate {
	func zoom(to point: NSPoint, with scale: CGFloat)
	func redisplay(_ dirtyrect: NSRect)
}

class MapWindowController: NSWindowController, MapViewDelegate {
	
	var mapView = MapView()
	var delegate: NSWindowDelegate?
	var oldScreenOrigin = NSPoint()
	var preResizeOrigin = NSPoint()
	let newSize = NSSize(width: 640.0, height: 640.0)
	
	@IBOutlet weak var scrollView: NSScrollView!
	@IBOutlet weak var clipView: NSClipView!
	
	override var windowNibName: NSNib.Name? {
		return .MapWindowController
	}
	
	override init(window: NSWindow?) {
		super.init(window: window)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		shouldCascadeWindows = false
	}
	
	override func windowDidLoad() {
        super.windowDidLoad()

		
		window?.title = "\(doomProject.openMap?.name ?? "") (\(doomProject.openMap?.level ?? "")) : Edit Mode"
		
		positionWindowTopLeft(leftOffset: 50, topOffset: 50)
		delegate = self

		
		mapView.delegate = self
		mapView.frame = editWorld.getBounds()
		
		// Set up the scroll view
		scrollView.documentView = mapView
		scrollView.allowsMagnification = true
		scrollView.autoresizingMask = [.width, .height]
		
		// FIXME: scroll to center of map on load
		let mapBounds = editWorld.getBounds()
		var origin = NSPoint()
		origin.x = mapBounds.origin.x + (mapBounds.size.width / 2) - (newSize.width / 2)
		origin.y = mapBounds.origin.y + (mapBounds.size.height / 2) - (newSize.width / 2)
		origin = mapView.convert(origin, to: window!.contentView)
		mapView.setOrigin(for: origin, withScale: 1.0)
		
		window?.makeFirstResponder(mapView)
    }
	
	// TODO: Animate zooming
	func zoom(to point: NSPoint, with scale: CGFloat) {
		scrollView.setMagnification(CGFloat(scale), centeredAt: point)
	}
	
	func redisplay(_ dirtyrect: NSRect) {
		print("mapView.setneedsdisplay called")
		let newRect = mapView.convert(dirtyrect, from: self.window?.contentView)
		mapView.setNeedsDisplay(newRect)
		mapView.displayIfNeeded()
	}
}



// ================================
// MARK: - NSWindowDelegate Methods
// ================================

// TODO: Get all this working

extension MapWindowController: NSWindowDelegate {
	
	/// Note the origin so it can be kept in the same place after resize
	func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
		
		oldScreenOrigin = NSPoint.zero
		window!.convertBaseToScreen(&oldScreenOrigin)
		preResizeOrigin = mapView.currentOrigin()
		
		return frameSize
	}
	
	/// Adjust world bounds for the new frame
	func windowDidResize(_ notification: Notification) {
		
		let scale = mapView.scale
		var newScreenOrigin = NSPoint.zero
		window!.convertBaseToScreen(&newScreenOrigin)
		
		preResizeOrigin.x += (newScreenOrigin.x - oldScreenOrigin.x)// / CGFloat(scale)
		preResizeOrigin.y += (newScreenOrigin.y - oldScreenOrigin.y)// / CGFloat(scale)
		mapView.setOrigin(for: preResizeOrigin)
	}
	
	
	// FIXME: Put everything in editworld save/close and just call from here
	func windowWillClose(_ notification: Notification) {
		if doomProject.mapDirty {
			let val = runDialogPanel(question: "Hey!", text: "Your map has been modified! Save it?")
			if val {
				editWorld.saveWorld()
				doomProject.openMap = nil
				editWorld.loaded = false
			}
		}
		
		let appDelegate = NSApplication.shared.delegate as! AppDelegate
		appDelegate.mapWindowController = nil
		appDelegate.runMapMenuItem.isEnabled = false
	}
}

