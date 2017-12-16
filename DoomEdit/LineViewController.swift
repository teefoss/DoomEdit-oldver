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
	@IBOutlet weak var backUpperLabel: NSTextField!
	@IBOutlet weak var backLowerLabel: NSTextField!
	@IBOutlet weak var backXOffset: NSTextField!
	@IBOutlet weak var backYOffset: NSTextField!
	@IBOutlet weak var frontUpperImageView: NSImageView!
	@IBOutlet weak var frontMiddleImageView: NSImageView!
	@IBOutlet weak var frontLowerImageView: NSImageView!
	@IBOutlet weak var backUpperImageView: NSImageView!
	@IBOutlet weak var backMiddleImageView: NSImageView!
	@IBOutlet weak var backLowerImageView: NSImageView!
	@IBOutlet weak var backMiddleLabel: NSTextField!
	
	
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
		
		frontUpperLabel.stringValue = line.side[0]?.upperTexture ?? "—"
		frontMiddle.stringValue = line.side[0]?.middleTexture ?? "—"
		frontLowerLabel.stringValue = line.side[0]?.lowerTexture ?? "—"
		frontXOffsetTextField.integerValue = (line.side[0]?.x_offset)!
		frontYOffsetTextField.integerValue = (line.side[0]?.y_offset)!
		backUpperLabel.stringValue = line.side[1]?.upperTexture ?? "-"
		backMiddleLabel.stringValue = line.side[1]?.middleTexture ?? "-"
		backLowerLabel.stringValue = line.side[1]?.lowerTexture ?? "-"
		backXOffset.integerValue = line.side[1]?.x_offset ?? 0
		backYOffset.integerValue = line.side[1]?.y_offset ?? 0
		
		// Set the texture image views
		if let frontUpper = line.side[0]?.upperTexture {
			frontUpperImageView.image = NSImage(named: NSImage.Name(rawValue: frontUpper))
		}
		if let frontMiddle = line.side[0]?.middleTexture {
			frontMiddleImageView.image = NSImage(named: NSImage.Name(rawValue: frontMiddle))
		}
		if let frontLower = line.side[0]?.lowerTexture {
			frontLowerImageView.image = NSImage(named: NSImage.Name(rawValue: frontLower))
		}
		if let frontLower = line.side[0]?.lowerTexture {
			frontLowerImageView.image = NSImage(named: NSImage.Name(rawValue: frontLower))
		}
		if let backUpper = line.side[1]?.upperTexture {
			backUpperImageView.image = NSImage(named: NSImage.Name(rawValue: backUpper))
		}
		if let backLower = line.side[1]?.lowerTexture {
			backLowerImageView.image = NSImage(named: NSImage.Name(rawValue: backLower))
		}
		if let backMiddle = line.side[1]?.middleTexture {
			backMiddleImageView.image = NSImage(named: NSImage.Name(rawValue: backMiddle))
		}

		
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
