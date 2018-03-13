//
//  PatchWindow.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/18/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//
//  Just for testing, delete this at some point

import Cocoa

class PatchWindow: NSWindowController {
	
	@IBOutlet weak var imageView: NSImageView!
	
	override var windowNibName: NSNib.Name? {
		return NSNib.Name("PatchWindow")
	}
	
    override func windowDidLoad() {
        super.windowDidLoad()
		
		//imageView.image = wad.sprites[0].image
    }

	func createTextureImage(for index: Int) -> Texture {
		
		var texture = Texture()
		var size = NSSize()
		
		size.width = CGFloat(wad.maptextures[index].width)
		size.height = CGFloat(wad.maptextures[index].height)

		texture.rect = NSRect.zero
		texture.rect.size = size
		// TODO: Wad index
		texture.name = wad.maptextures[index].name
		texture.patchCount = Int(wad.maptextures[index].patchcount)
		texture.image = NSImage(size: size)
		texture.image.lockFocus()
		
		let color = NSColor(calibratedRed: 1, green: 0, blue: 0, alpha: 1)
		color.set()
		texture.rect.fill()
		
		for i in 0..<Int(wad.maptextures[index].patchcount) {
			
			var p = TexPatch()
			
			p.info = wad.maptextures[index].patches[i]
			if let ptch = getPatchImage(for: Int(p.info.patchIndex)) {
				p.patch = ptch
			} else {
				fatalError("Error! While building texture \(i), I couldn't find the '\(p.info.name)' patch!")
			}
						
			p.rect.origin.x = CGFloat(p.info.originx)
			p.rect.origin.y = CGFloat(wad.maptextures[index].height) - p.patch.size.height - CGFloat(p.info.originy)
			p.rect.size.width = p.patch.rect.size.width
			p.rect.size.height = p.patch.rect.size.height
			p.patch.image.draw(at: p.rect.origin, from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
		}
		texture.image.unlockFocus()
		
		return texture
	}
	
	func getPatchImage(for index: Int) -> Patch? {
		
		let patchName = wad.pnames[index]
		
		
		for i in 0..<wad.patches.count {
			if patchName.uppercased() == wad.patches[i].name.uppercased() {
				return wad.patches[i]
			}
		}
		return nil
	}

    
}
