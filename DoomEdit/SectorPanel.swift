//
//  SectorPanel.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/15/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

class SectorPanel: NSViewController {

	var def = SectorDef()
	
	
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
		ceilingLabel.stringValue = def.ceilingFlat
		floorLabel.stringValue = def.floorFlat

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
    
}
