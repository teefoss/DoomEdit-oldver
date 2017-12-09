//
//  ThingWindow.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/9/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

class ThingWindowController: NSWindowController {

	var thing: Thing?
	
	@IBOutlet weak var typeLabel: NSTextField!
	@IBOutlet weak var angleLabel: NSTextField!
	@IBOutlet weak var easyButton: NSButton!
	@IBOutlet weak var normalButton: NSButton!
	@IBOutlet weak var hardButton: NSButton!

	override var windowNibName: NSNib.Name? {
		return NSNib.Name(rawValue: "ThingWindow")
	}

    override func windowDidLoad() {
        super.windowDidLoad()

		if let thing = thing {
//		typeLabel.stringValue = "\(thing.type)"
//		angleLabel.stringValue = "\(thing.angle)"
		
		if thing.options & SKILL_EASY == SKILL_EASY {
			easyButton.state = .on
		} else {
			easyButton.state = .off
		}
		
		if thing.options & SKILL_NORMAL == SKILL_NORMAL {
			normalButton.state = .on
		} else {
			easyButton.state = .off
		}
		
		if thing.options & SKILL_HARD == SKILL_HARD {
			hardButton.state = .on
		} else {
			hardButton.state = .off
		}
		}
    }
	
	
	
	
}
