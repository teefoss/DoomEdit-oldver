//
//  FlatImageView.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/13/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

/**
The view that displays a sector's flats in the Sector Panel
Displays the Flat Panel when clicked
*/

class FlatImageView: NSImageView, NSPopoverDelegate {

	var flatPosition = 0	// 0 = floor, 1 = ceiling
	var selectedFlatIndex = -1
//	var selectedFlatName = ""
	
	var flatPanel = FlatPanel()
	
	override func mouseDown(with event: NSEvent) {
		flatPanel.flatPosition = self.flatPosition
		flatPanel.selectedFlatIndex = self.selectedFlatIndex
//		flatPanel.selectedFlatName = self.selectedFlatName
		displayFlatPopover(at: self)
	}
	
	func initPopover(_ popover: inout NSPopover, with viewController: NSViewController) {
		popover = NSPopover.init()
		popover.contentViewController = viewController
		popover.appearance = (THEME == .light) ? NSAppearance(named: .vibrantLight) : NSAppearance(named: .vibrantDark)
		popover.animates = false
		popover.behavior = .semitransient
		popover.delegate = self
	}
	
	func displayFlatPopover(at view: NSView) {
		var flatPopover = NSPopover()
		initPopover(&flatPopover, with: flatPanel)
		flatPopover.show(relativeTo: view.bounds, of: view, preferredEdge: .minX)
	}

	
}
