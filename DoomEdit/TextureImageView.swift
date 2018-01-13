//
//  TextureImageView.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/1/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

/**
The view that displays a line's textures in the Line Panel.
Displays the Texture Panel when clicked.
*/

class TextureImageView: NSImageView, NSPopoverDelegate {
	
	var textureIndex: Int = -1
	var lineIndex: Int = 0
	var texturePosition: Int = 0	// 1,2,3 lower, middle, upper: front
									// -1,-2,-3 lower, middle, upper: back
	
	var texturePanel = TexturePanel()
	
	override func mouseDown(with event: NSEvent) {
		texturePanel.lineIndex = self.lineIndex
		texturePanel.selectedTextureIndex = self.textureIndex
		texturePanel.texturePosition = self.texturePosition
		displayTexturePopover(at: self)
	}
	
	func initPopover(_ popover: inout NSPopover, with viewController: NSViewController) {
		popover = NSPopover.init()
		popover.contentViewController = viewController
		popover.appearance = NSAppearance.init(named: .vibrantLight)
		popover.animates = false
		popover.behavior = .semitransient
		popover.delegate = self
	}
	
	func displayTexturePopover(at view: NSView) {
		var texturePopover = NSPopover()
		initPopover(&texturePopover, with: texturePanel)
		texturePopover.show(relativeTo: view.bounds, of: view, preferredEdge: .minX)
	}

}
