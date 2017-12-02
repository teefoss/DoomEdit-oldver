//
//  MapView.swift
//  DoomEdit
//
//  Created by Thomas Foster on 9/16/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa


/**
View that displays the map
*/
class MapView: NSView {

	var delegate: MapViewDelegate?
	var trackingArea: NSTrackingArea?
	var closestPoint: Point? {
		didSet{
			self.setNeedsDisplay(bounds)
		}
	}
	
	var gridSize: Int = 8
	var scale: CGFloat = 1.0
	
	// for line drawing
	var shapeLayer: CAShapeLayer!
	var shapeLayerIndex: Int!
	var startPoint: NSPoint!
	var endPoint: NSPoint!
	var didDragLine: Bool = false
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		
		let trackingArea = NSTrackingArea(rect: bounds,
										  options: [.activeInKeyWindow, .inVisibleRect, .mouseMoved],
										  owner: self,
										  userInfo: nil)
		self.trackingArea = trackingArea
		addTrackingArea(trackingArea)
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
