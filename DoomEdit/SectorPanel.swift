//
//  SectorPanel.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/15/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

class SectorPanel: NSViewController, NSTextDelegate {

	var def = SectorDef()
	var selectedSides: [Int] = []
	var newDef = SectorDef()
	
	
	@IBOutlet weak var sectorLabel: NSTextField!
	@IBOutlet weak var ceilingHeightTextField: NSTextField!
	@IBOutlet weak var floorHeightTextField: NSTextField!
	@IBOutlet weak var heightLabel: NSTextField!
	@IBOutlet weak var tagTextField: NSTextField!
	@IBOutlet weak var lightTextField: NSTextField!
	@IBOutlet weak var lightSlider: NSSlider!
	@IBOutlet weak var ceilingImageView: NSImageView!
	@IBOutlet weak var floorImageView: NSImageView!
	@IBOutlet weak var ceilingLabel: NSTextField!
	@IBOutlet weak var floorLabel: NSTextField!
	@IBOutlet weak var specialButton: NSPopUpButton!
	@IBOutlet weak var specialTextField: NSTextField!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		// TODO: Get the sector number
		sectorLabel.stringValue = "Sector ? Properties"
		ceilingHeightTextField.integerValue = def.ceilingHeight
		floorHeightTextField.integerValue = def.floorHeight
		heightLabel.integerValue = def.ceilingHeight - def.floorHeight
		tagTextField.integerValue = def.tag
		lightTextField.integerValue = def.lightLevel
		lightSlider.integerValue = def.lightLevel
		ceilingLabel.stringValue = def.ceilingFlat
		floorLabel.stringValue = def.floorFlat
		specialTextField.integerValue = def.special
		
		specialButton.selectItem(withTag: def.special)

		// Because doom texture and flat have the same name. Flat STEP1 changed to STEP1_FL etc
		if def.ceilingFlat == "STEP1" {
			ceilingImageView.image = NSImage(named: NSImage.Name(rawValue: "STEP1_FL"))
		} else if def.ceilingFlat == "STEP2" {
			ceilingImageView.image = NSImage(named: NSImage.Name(rawValue: "STEP2_FL"))
		} else {
			ceilingImageView.image = NSImage(named: NSImage.Name(rawValue: def.ceilingFlat))
		}
		
		if def.floorFlat == "STEP1" {
			floorImageView.image = NSImage(named: NSImage.Name(rawValue: "STEP1_FL"))
		} else if def.floorFlat == "STEP2" {
			floorImageView.image = NSImage(named: NSImage.Name(rawValue: "STEP2_FL"))
		} else {
			floorImageView.image = NSImage(named: NSImage.Name(rawValue: def.floorFlat))
		}
	}
	
	override func viewWillDisappear() {
		super.viewWillDisappear()
		
		print("viewWillDisappear")
		
		newDef.ceilingHeight = ceilingHeightTextField.integerValue
		newDef.floorHeight = floorHeightTextField.integerValue
		newDef.tag = tagTextField.integerValue
		newDef.lightLevel = lightTextField.integerValue
		newDef.special = specialTextField.integerValue

		fillSector(with: newDef)
		
		
	}
	
	func fillSector(with def: SectorDef) {
		for i in 0..<selectedSides.count {
			if selectedSides[i] & SIDE_BIT == SIDE_BIT {
				var line = selectedSides[i]
				line &= ~SIDE_BIT
				lines[line].side[1]?.ends = def
			} else {
				let line = selectedSides[i]
				lines[line].side[0]?.ends = def
			}
		}
	}

	
	@IBAction func suggestTagClicked(_ sender: NSButton) {

		var maxTag = 0
		
		for line in lines {
			for side in line.side {
				if let tag = side?.ends.tag {
					if tag > maxTag {
						maxTag = tag
					}
				}
			}
		}
		
		tagTextField.integerValue = maxTag + 1
		newDef.tag = tagTextField.integerValue
	}
	
	
	
	@IBAction func specialChanged(_ sender: NSPopUpButton) {
		specialTextField.integerValue = sender.selectedItem?.tag ?? 0
	}
	
}
