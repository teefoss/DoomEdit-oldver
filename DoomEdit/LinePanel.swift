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

class LinePanel: NSViewController, TexturePanelDelegate {

	// The selected line
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
	
	
	var flagButtons: [NSButton] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
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

		let manualMenuItem = NSMenuItem(title: "Manual", action: nil, keyEquivalent: "")
		let buttonMenuItem = NSMenuItem(title: "Button", action: nil, keyEquivalent: "")

		manualMenu.setSubmenu(manualMenu, for: manualMenuItem)
		buttonMenu.setSubmenu(buttonMenu, for: buttonMenuItem)
		
		for special in doomData.doom1LineSpecials {

			switch special.type {
			case "Manual":
				let item = NSMenuItem()
				item.title = special.name
				item.action = #selector(setSpecial)
				item.tag = special.index
				manualMenu.addItem(item)
			case "Button":
				buttonMenu.addItem(withTitle: special.name, action: #selector(setSpecial), keyEquivalent: "")
			default:
				continue
			}
		}
		
		var menuItems: [NSMenuItem] = []
		
		specialsPopUpButton.menu?.removeAllItems()
		specialsPopUpButton.menu?.addItem(manualMenuItem)
		specialsPopUpButton.menu?.addItem(buttonMenuItem)
//		for item in menuItems {
//			specialsPopUpButton.menu?.addItem(item)
//		}
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

		// Set the images and send the texture's index to the imageview
		
		if frontUpper != "-" {
			frontUpperImageView.image = NSImage(named: NSImage.Name(rawValue: frontUpper))
			for i in 0..<doomData.doom1Textures.count {
				let texture = doomData.doom1Textures[i]
				if frontUpper == texture.name {
					frontUpperImageView.textureIndex = i
					break
				}
			}
		} else {
			frontUpperImageView.image = nil
			frontUpperImageView.textureIndex = -1
		}
		
		if frontMiddle != "-" {
			frontMiddleImageView.image = NSImage(named: NSImage.Name(rawValue: frontMiddle))
			for i in 0..<doomData.doom1Textures.count {
				let texture = doomData.doom1Textures[i]
				if frontMiddle == texture.name {
					frontMiddleImageView.textureIndex = i
					break
				}
			}
		} else {
			frontMiddleImageView.image = nil
			frontMiddleImageView.textureIndex = -1
		}
		
		if frontLower != "-" {
			frontLowerImageView.image = NSImage(named: NSImage.Name(rawValue: frontLower))
			for i in 0..<doomData.doom1Textures.count {
				let texture = doomData.doom1Textures[i]
				if frontLower == texture.name {
					frontLowerImageView.textureIndex = i
					break
				}
			}
		} else {
			frontLowerImageView.image = nil
			frontLowerImageView.textureIndex = -1
		}
		
		if backUpper != "-" {
			backUpperImageView.image = NSImage(named: NSImage.Name(rawValue: backUpper))
			for i in 0..<doomData.doom1Textures.count {
				let texture = doomData.doom1Textures[i]
				if backUpper == texture.name {
					backUpperImageView.textureIndex = i
					break
				}
			}
		} else {
			backUpperImageView.image = nil
			backUpperImageView.textureIndex = -1
		}
		
		if backMiddle != "-" {
			backMiddleImageView.image = NSImage(named: NSImage.Name(rawValue: backMiddle))
			for i in 0..<doomData.doom1Textures.count {
				let texture = doomData.doom1Textures[i]
				if backMiddle == texture.name {
					backMiddleImageView.textureIndex = i
					break
				}
			}
		} else {
			backMiddleImageView.image = nil
			backMiddleImageView.textureIndex = -1
		}
		
		if backLower != "-" {
			backLowerImageView.image = NSImage(named: NSImage.Name(rawValue: backLower))
			for i in 0..<doomData.doom1Textures.count {
				let texture = doomData.doom1Textures[i]
				if backLower == texture.name {
					backLowerImageView.textureIndex = i
					break
				}
			}
		} else {
			backLowerImageView.image = nil
			backLowerImageView.textureIndex = -1
		}

		
	}
	
	@objc func setSpecial() {
		lines[lineIndex].special = specialsPopUpButton.selectedTag()
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
