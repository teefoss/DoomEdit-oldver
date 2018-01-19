//
//  PatchWindow.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/18/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

class PatchWindow: NSWindowController {
	
	@IBOutlet weak var imageView: NSImageView!
	
	override var windowNibName: NSNib.Name? {
		return NSNib.Name("PatchWindow")
	}
	
    override func windowDidLoad() {
        super.windowDidLoad()
		
		let wadfile = WadFile()
		let patch = wadfile.patches[60]
		
		
		imageView.image = patch.image

    }

	

    
}
