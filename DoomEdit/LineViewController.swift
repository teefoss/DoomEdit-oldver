//
//  LineViewController.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/10/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

class LineViewController: NSViewController {

	var line = Line()
	var lineIndex: Int = 0
	
	@IBOutlet weak var titleLabel: NSTextField!
	
	
	@IBOutlet weak var blocksAllButton: NSButton!
	@IBOutlet weak var blocksMonstersButton: NSButton!
	@IBOutlet weak var blocksSoundButton: NSButton!
	@IBOutlet weak var twoSidedButton: NSButton!
	@IBOutlet weak var upperUnpeggedButton: NSButton!
	@IBOutlet weak var lowerUnpeggedButton: NSButton!
	@IBOutlet weak var onMapButton: NSButton!
	@IBOutlet weak var notOnMapButton: NSButton!
	@IBOutlet weak var secretButton: NSButton!
	@IBOutlet weak var tagTextField: NSTextField!
	
	@IBOutlet weak var frontUpperLabel: NSTextField!
	@IBOutlet weak var frontMiddle: NSTextField!
	@IBOutlet weak var frontLowerLabel: NSTextField!
	@IBOutlet weak var frontXOffsetTextField: NSTextField!
	@IBOutlet weak var frontYOffsetTextField: NSTextField!
	
	
	var flagButtons: [NSButton] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		flagButtons.append(blocksAllButton)
		flagButtons.append(blocksMonstersButton)
		flagButtons.append(twoSidedButton)
		flagButtons.append(upperUnpeggedButton)
		flagButtons.append(lowerUnpeggedButton)
		flagButtons.append(secretButton)
		flagButtons.append(blocksSoundButton)
		flagButtons.append(notOnMapButton)
		flagButtons.append(onMapButton)
    }
	
	override func viewWillAppear() {
		super.viewWillAppear()

		titleLabel.stringValue = "Line \(lineIndex) Properties"
		
		// Set the options buttons
		for i in 0..<flagButtons.count {
			line.flags & (1 << i) == (1 << i) ? (flagButtons[i].state = .on) : (flagButtons[i].state = .off)
		}
		
		// Set the tag number
		line.tag == 0 ? (tagTextField.stringValue = "") : (tagTextField.integerValue = line.tag)
		
		frontUpperLabel.stringValue = line.front.upperTexture ?? "—"
		frontMiddle.stringValue = line.front.middleTexture ?? "—"
		frontLowerLabel.stringValue = line.front.lowerTexture ?? "—"
		frontXOffsetTextField.integerValue = line.front.x_offset
		frontYOffsetTextField.integerValue = line.front.y_offset
		
		
		// TODO: set up the rest
		
	}
	
	@IBAction func suggestTagClicked(_ sender: NSButton) {
		var maxTag: Int = 0
		for line in lines {
			if line.tag > maxTag {
				maxTag = line.tag
			}
		}
		
		if maxTag == 0 {
			tagTextField.integerValue = 1
		} else {
			tagTextField.integerValue = maxTag + 1
		}
	}
	
}
