//
//  MapView.swift
//  DoomEdit
//
//  Created by Thomas Foster on 9/16/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//
//  View that display the map
//

import Cocoa

class MapView: NSView {

	var delegate: MapViewDelegate?
	
	var gridSize: Int = 32
	var scale: CGFloat = 1.0
	
	// for line drawing
	var shapeLayer: CAShapeLayer!
	var startPoint: NSPoint!
	var endPoint: NSPoint!
	
	// get the grid point closet to the mouse click
	func getGridPoint(from event: NSEvent) -> NSPoint {
		
		var point = convert(event.locationInWindow, from: nil)
		
		point.x = CGFloat(Int(point.x / CGFloat(gridSize) + 0.5 * (point.x < 0 ? -1 : 1)))
		point.y = CGFloat(Int(point.y / CGFloat(gridSize) + 0.5 * (point.y < 0 ? -1 : 1)))
		point.x *= CGFloat(gridSize)
		point.y *= CGFloat(gridSize)
		
		return point
	}

	func currentOrigin() -> NSPoint {
		let global = convert((superview?.bounds.origin)!, from: superview)
		return global
	}
	
	func currentWorldOriginInWindow() -> NSPoint {

		// fuck everything
		let corner = convert((window?.contentView?.bounds.origin)!, to: superview)
		return corner
		
//		return convert(self.visibleRect.origin, to: superview)
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
		
		map = world.updateBounds()
		
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
