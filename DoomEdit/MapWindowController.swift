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
}



class MapWindowController: NSWindowController, MapViewDelegate {

	var mapView = MapView()
	var delegate: NSWindowDelegate?
	var oldScreenOrigin = NSPoint()
	var preResizeOrigin = NSPoint()

	@IBOutlet weak var scrollView: NSScrollView!
	
	override var windowNibName: NSNib.Name? {
		return .MapWindowController
	}
	
    override func windowDidLoad() {
        super.windowDidLoad()
		delegate = self
		mapView.delegate = self

		// Load world and set up the map view
		world.loadWorldFile()
		
		for line in world.lines {
			print("(\(line.pt1.coord)) to (\(line.pt2.coord))")
		}
		
		mapView.frame = world.updateBounds()
		// Set up the scroll view
		scrollView.documentView = mapView
		scrollView.allowsMagnification = true
		// FIXME: scroll to center of map on load
		let centerx = scrollView.documentVisibleRect.maxX / 2
		let centery = scrollView.documentVisibleRect.maxY / 2
		scrollView.scroll(NSPoint(x: centerx, y: centery))
		zoom(to: NSPoint.zero, with: 1.0)
    }
	
	// TODO: Animate zooming
	func zoom(to point: NSPoint, with scale: CGFloat) {
		scrollView.setMagnification(CGFloat(scale), centeredAt: point)
	}
	
}



// ================================
// MARK: - NSWindowDelegate Methods
// ================================

// TODO: Get all this working

extension MapWindowController: NSWindowDelegate {
	
	/// Note the origin so it can be kept in the same place after resize
	func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
		
		if let windowFrame = window?.frame {
			let wFrameConv = window?.convertToScreen(windowFrame)
			if let origin = wFrameConv?.origin {
				self.oldScreenOrigin = origin
				preResizeOrigin = mapView.currentOrigin()
			}
		}
		return frameSize
	}
	
	/// Adjust world bounds for the new frame
	func windowDidResize(_ notification: Notification) {
		
		let scale = mapView.scale
		var newScreenOrigin = NSPoint.zero
		
		if let wframe = window?.frame {
			if let wframeConv = window?.convertToScreen(wframe) {
				newScreenOrigin = wframeConv.origin
			}
		}
		
		preResizeOrigin.x += (newScreenOrigin.x - oldScreenOrigin.x) / CGFloat(scale)
		preResizeOrigin.y += (newScreenOrigin.y - oldScreenOrigin.y) / CGFloat(scale)
		
		mapView.setOrigin(for: preResizeOrigin)
	}
}


