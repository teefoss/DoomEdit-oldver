//
//  LineViewController.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/10/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

protocol TexturePanelDelegate {
	func updateTextureLabels()
	func updateOffsets()
	func updateImages()
}

class LinePanel: NSViewController, TexturePanelDelegate, NSTabViewDelegate {

	// The selected line
	var line = Line()
	var lineIndex: Int = 0
	
	@IBOutlet weak var tabView: NSTabView!
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
	@IBOutlet weak var frontMiddleLabel: NSTextField!
	@IBOutlet weak var frontLowerLabel: NSTextField!
	@IBOutlet weak var frontXOffsetTextField: NSTextField!
	@IBOutlet weak var frontYOffsetTextField: NSTextField!
	@IBOutlet weak var backUpperLabel: NSTextField!
	@IBOutlet weak var backLowerLabel: NSTextField!
	@IBOutlet weak var backXOffset: NSTextField!
	@IBOutlet weak var backYOffset: NSTextField!
	@IBOutlet weak var frontUpperImageView: TextureImageView!
	@IBOutlet weak var frontMiddleImageView: TextureImageView!
	@IBOutlet weak var frontLowerImageView: TextureImageView!
	@IBOutlet weak var backUpperImageView: TextureImageView!
	@IBOutlet weak var backMiddleImageView: TextureImageView!
	@IBOutlet weak var backLowerImageView: TextureImageView!
	@IBOutlet weak var backMiddleLabel: NSTextField!
	@IBOutlet weak var specialsPopUpButton: NSPopUpButton!
	@IBOutlet weak var specialLabel: NSTextField!
	
	
	var flagButtons: [NSButton] = []
	
	

	// =======================
	// MARK: - View Life Cycle
	// =======================
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		tabView.delegate = self
		
		// TODO: Use an init
		
		frontUpperImageView.texturePanel.delegate = self
		frontMiddleImageView.texturePanel.delegate = self
		frontLowerImageView.texturePanel.delegate = self
		backUpperImageView.texturePanel.delegate = self
		backMiddleImageView.texturePanel.delegate = self
		backLowerImageView.texturePanel.delegate = self
		
		frontUpperImageView.texturePosition = 3
		frontMiddleImageView.texturePosition = 2
		frontLowerImageView.texturePosition = 1
		backUpperImageView.texturePosition = -3
		backMiddleImageView.texturePosition = -2
		backLowerImageView.texturePosition = -1
		
		flagButtons.append(blocksAllButton)
		flagButtons.append(blocksMonstersButton)
		flagButtons.append(twoSidedButton)
		flagButtons.append(upperUnpeggedButton)
		flagButtons.append(lowerUnpeggedButton)
		flagButtons.append(secretButton)
		flagButtons.append(blocksSoundButton)
		flagButtons.append(notOnMapButton)
		flagButtons.append(onMapButton)

		let manualMenu = NSMenu()
		let buttonMenu = NSMenu()
		let switchMenu = NSMenu()
		let triggerMenu = NSMenu()
		let retriggerMenu = NSMenu()
		let effectMenu = NSMenu()
		let impactMenu = NSMenu()

		let noneMenuItem = NSMenuItem(title: "None", action: #selector(clearSpecial(sender:)), keyEquivalent: "")
		let manualMenuItem = NSMenuItem(title: "Manual", action: nil, keyEquivalent: "")
		let buttonMenuItem = NSMenuItem(title: "Button", action: nil, keyEquivalent: "")
		let switchMenuItem = NSMenuItem(title: "Switch", action: nil, keyEquivalent: "")
		let triggerMenuItem = NSMenuItem(title: "Trigger", action: nil, keyEquivalent: "")
		let retriggerMenuItem = NSMenuItem(title: "Retrigger", action: nil, keyEquivalent: "")
		let effectMenuItem = NSMenuItem(title: "Effect", action: nil, keyEquivalent: "")
		let impactMenuItem = NSMenuItem(title: "Impact", action: nil, keyEquivalent: "")


		manualMenu.setSubmenu(manualMenu, for: manualMenuItem)
		buttonMenu.setSubmenu(buttonMenu, for: buttonMenuItem)
		switchMenu.setSubmenu(switchMenu, for: switchMenuItem)
		triggerMenu.setSubmenu(triggerMenu, for: triggerMenuItem)
		retriggerMenu.setSubmenu(retriggerMenu, for: retriggerMenuItem)
		effectMenu.setSubmenu(effectMenu, for: effectMenuItem)
		impactMenu.setSubmenu(impactMenu, for: impactMenuItem)
		
		for special in doomData.doom1LineSpecials {
			
			switch special.type {
			case "Manual":
				addSpecial(special, to: manualMenu)
			case "Button":
				addSpecial(special, to: buttonMenu)
			case "Switch":
				addSpecial(special, to: switchMenu)
			case "Trigger":
				addSpecial(special, to: triggerMenu)
			case "Retrigger":
				addSpecial(special, to: retriggerMenu)
			case "Effect":
				addSpecial(special, to: effectMenu)
			case "Impact":
				addSpecial(special, to: impactMenu)
			default:
				print("error loading special menu with special \(special.index):\(special.type)\(special.name)")
				continue
			}
		}
				
		specialsPopUpButton.menu?.removeAllItems()
		specialsPopUpButton.menu?.addItem(noneMenuItem)
		specialsPopUpButton.menu?.addItem(NSMenuItem.separator())
		specialsPopUpButton.menu?.addItem(manualMenuItem)
		specialsPopUpButton.menu?.addItem(buttonMenuItem)
		specialsPopUpButton.menu?.addItem(switchMenuItem)
		specialsPopUpButton.menu?.addItem(triggerMenuItem)
		specialsPopUpButton.menu?.addItem(retriggerMenuItem)
		specialsPopUpButton.menu?.addItem(impactMenuItem)
		specialsPopUpButton.menu?.addItem(effectMenuItem)
		
    }
	
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		titleLabel.stringValue = "Line \(lineIndex) Properties"
		
		// Set the options buttons
		for i in 0..<flagButtons.count {
			line.flags & (1 << i) == (1 << i) ? (flagButtons[i].state = .on) : (flagButtons[i].state = .off)
		}
		
		if flagButtons[2].state == .off {
			
		}
		
		// Set the tag number
		line.tag == 0 ? (tagTextField.stringValue = "") : (tagTextField.integerValue = line.tag)
		
		// Display the line information
		updateTextureLabels()
		updateOffsets()
		updateImages()
		
		// Set the line index so the Texture Panel can update this line's texture
		frontUpperImageView.lineIndex = lineIndex
		frontMiddleImageView.lineIndex = lineIndex
		frontLowerImageView.lineIndex = lineIndex
		backUpperImageView.lineIndex = lineIndex
		backMiddleImageView.lineIndex = lineIndex
		backLowerImageView.lineIndex = lineIndex
		
		// TODO: set up the rest
		updateSpecialLabel(for: line.special)
		updateSpecialButton(for: line.special)
	}
	
	override func viewWillDisappear() {
		super.viewWillDisappear()
		
		lines[lineIndex].tag = tagTextField.integerValue
	}
	
	/// For setting up the specials menu
	func addSpecial(_ special: LineSpecial, to menu: NSMenu) {
		let item = NSMenuItem()
		item.title = special.name
		item.tag = special.index
		item.target = self
		item.action = #selector(setSpecial(sender:))
		menu.addItem(item)
	}


	
	
	
	// =================
	// MARK: - Update UI
	// =================
	
	/// Set the current line's special from the menu selection
	@objc func setSpecial(sender: NSMenuItem) {
		lines[lineIndex].special = sender.tag
		updateSpecialLabel(for: sender.tag)
		updateSpecialButton(for: sender.tag)
	}
	
	@objc func clearSpecial(sender: NSMenuItem) {
		lines[lineIndex].special = 0
		updateSpecialLabel(for: 0)
		updateSpecialLabel(for: 0)
	}

	func updateSpecialLabel(for tag: Int) {
		
		for special in doomData.doom1LineSpecials {
			if lines[lineIndex].special == special.index {
				specialLabel.stringValue = special.name
				break
			} else {
				specialLabel.stringValue = "--"
			}
		}
	}
	
	func updateSpecialButton(for tag: Int) {
		
		for special in doomData.doom1LineSpecials {
			if tag == special.index {
				specialsPopUpButton.selectItem(withTitle: special.type)
				break
			} else {
				specialsPopUpButton.selectItem(withTitle: "None")
			}
		}
	}

	func updateTextureLabels() {

		frontUpperLabel.stringValue = lines[lineIndex].side[0]?.upperTexture ?? "—"
		frontMiddleLabel.stringValue = lines[lineIndex].side[0]?.middleTexture ?? "—"
		frontLowerLabel.stringValue = lines[lineIndex].side[0]?.lowerTexture ?? "—"
		backUpperLabel.stringValue = lines[lineIndex].side[1]?.upperTexture ?? "-"
		backMiddleLabel.stringValue = lines[lineIndex].side[1]?.middleTexture ?? "-"
		backLowerLabel.stringValue = lines[lineIndex].side[1]?.lowerTexture ?? "-"
	}
	
	func updateOffsets() {
		
		frontXOffsetTextField.integerValue = line.side[0]!.x_offset
		frontYOffsetTextField.integerValue = line.side[0]!.y_offset
		backXOffset.integerValue = line.side[1]?.x_offset ?? 0
		backYOffset.integerValue = line.side[1]?.y_offset ?? 0
	}
	
	func updateImages() {

		var frontUpper, frontMiddle, frontLower: String
		var backUpper, backMiddle, backLower: String

		frontUpper = (lines[lineIndex].side[0]?.upperTexture)!
		frontMiddle = (lines[lineIndex].side[0]?.middleTexture)!
		frontLower = (lines[lineIndex].side[0]?.lowerTexture)!
		
		if let backSide = lines[lineIndex].side[1] {
			backUpper = backSide.upperTexture!
			backMiddle = backSide.middleTexture!
			backLower = backSide.lowerTexture!
		} else {
			backUpper = "-"
			backMiddle = "-"
			backLower = "-"
		}

		// TODO: Clean this up
		
		// Set the images and send the texture's index to the imageview
		
		if frontUpper != "-" {
			frontUpperImageView.image = imageForTexture(named: frontUpper)
			frontUpperImageView.textureIndex = indexForTexture(named: frontUpper)
		} else {
			frontUpperImageView.image = nil
			frontUpperImageView.textureIndex = -1
		}
		
		if frontMiddle != "-" {
			frontMiddleImageView.image = imageForTexture(named: frontMiddle)
			frontMiddleImageView.textureIndex = indexForTexture(named: frontMiddle)
		} else {
			frontMiddleImageView.image = nil
			frontMiddleImageView.textureIndex = -1
		}
		
		if frontLower != "-" {
			frontLowerImageView.image = imageForTexture(named: frontLower)
			frontLowerImageView.textureIndex = indexForTexture(named: frontLower)
		} else {
			frontLowerImageView.image = nil
			frontLowerImageView.textureIndex = -1
		}
		
		if backUpper != "-" {
			backUpperImageView.image = imageForTexture(named: backUpper)
			backUpperImageView.textureIndex = indexForTexture(named: backUpper)
		} else {
			backUpperImageView.image = nil
			backUpperImageView.textureIndex = -1
		}
		
		if backMiddle != "-" {
			backMiddleImageView.image = imageForTexture(named: backMiddle)
			backMiddleImageView.textureIndex = indexForTexture(named: backMiddle)
		} else {
			backMiddleImageView.image = nil
			backMiddleImageView.textureIndex = -1
		}
		
		if backLower != "-" {
			backLowerImageView.image = imageForTexture(named: backLower)
			backLowerImageView.textureIndex = indexForTexture(named: backLower)
		} else {
			backLowerImageView.image = nil
			backLowerImageView.textureIndex = -1
		}

		
	}
	
	func imageForTexture(named name: String) -> NSImage? {
		
		for texture in wad.textures {
			if texture.name.uppercased() == name.uppercased() {
				return texture.image
			}
		}
		return nil
	}
	
	func indexForTexture(named name: String) -> Int {
		
		for i in 0..<wad.textures.count {
			if wad.textures[i].name.uppercased() == name.uppercased() {
				return i
			}
		}
		return -1
	}
	
	@IBAction func changeOption(_ sender: NSButton) {

		if sender.state == .on {
			lines[lineIndex].flags += sender.tag
		} else {
			lines[lineIndex].flags -= sender.tag
		}
	}
	
	/// Suggest the next unused tag number
	@IBAction func suggestTagClicked(_ sender: NSButton) {
		
		var maxTag: Int = 0
		for line in lines {
			if line.tag > maxTag {
				maxTag = line.tag
			}
		}
		tagTextField.integerValue = maxTag + 1
	}
	
	
	func tabView(_ tabView: NSTabView, shouldSelect tabViewItem: NSTabViewItem?) -> Bool {
		if tabViewItem == tabView.tabViewItem(at: 0) {
			return true
		} else {
			return flagButtons[2].state == .on
		}
	}
}
