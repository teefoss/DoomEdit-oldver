//
//  LineSpecialWindow.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/12/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

class LineSpecialWindow: NSWindowController {

	
	var root: [String] = ["Ceiling",
						  "Doors",
						  "Locked Doors",
						  "Effects",
						  "Exits",
						  "Floors",
						  "Lifts",
						  "Lights",
						  "Stairs",
						  "Teleports"]
	
	
	override var windowNibName: NSNib.Name? {
		return NSNib.Name(rawValue: "LineSpecialWindow")
	}
	
	override func windowDidLoad() {
        super.windowDidLoad()
		window?.title = "Line Specials"
    }
	
	
}

extension LineSpecialWindow: NSTableViewDataSource {
	
	
}
