//
//  ProgressWindowController.swift
//  DoomEdit
//
//  Created by Thomas Foster on 4/5/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

class ProgressWindowController: NSWindowController {

	@IBOutlet weak var progressBar: NSProgressIndicator!
	@IBOutlet weak var label: NSTextField!
	
	override var windowNibName: NSNib.Name? {
		return NSNib.Name("ProgressWindowController")
	}
	
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
}
