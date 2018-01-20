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

	var allTextures: [Texture] = []
	
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
		
		createAllTextureImages()
		
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
		
		frontUpperImageView.texturePanel.allTextures = allTextures
		frontMiddleImageView.texturePanel.allTextures = allTextures
		frontLowerImageView.texturePanel.allTextures = allTextures
		backUpperImageView.texturePanel.allTextures = allTextures
		backMiddleImageView.texturePanel.allTextures = allTextures
		backLowerImageView.texturePanel.allTextures = allTextures
		
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
	
	
	
	func createAllTextureImages() {
		
		allTextures = []
		
		for i in 0..<wad.maptextures.count {
			var t = createTextureImage(for: i)
			t.index = i
			allTextures.append(t)
		}
	}
	
	func createTextureImage(for index: Int) -> Texture {
		
		var texture = Texture()
		var size = NSSize()
		
		size.width = CGFloat(wad.maptextures[index].width)
		size.height = CGFloat(wad.maptextures[index].height)
		
		texture.width = Int(size.width)
		texture.height = Int(size.height)
		texture.name = wad.maptextures[index].name
		texture.patchCount = Int(wad.maptextures[index].patchcount)
		texture.image = NSImage(size: size)
		texture.image.lockFocus()
		
		let color = NSColor(calibratedRed: 1, green: 0, blue: 0, alpha: 1)
		color.set()
		texture.rect.fill()
		
		for i in 0..<Int(wad.maptextures[index].patchcount) {
			
			var p = TexPatch()
			
			p.info = wad.maptextures[index].patches[i]	//
			if let ptch = getPatchImage(for: Int(p.info.patchIndex)) {
				p.patch = ptch
			} else {
				fatalError("Error! While building texture \(i), I couldn't find the '\(p.info.name)' patch!")
			}
			
			p.rect.origin.x = CGFloat(p.info.originx)
			p.rect.origin.y = CGFloat(wad.maptextures[index].height) - p.patch.size.height - CGFloat(p.info.originy)
			p.rect.size.width = p.patch.rect.size.width
			p.rect.size.height = p.patch.rect.size.height
			p.patch.image.draw(at: p.rect.origin, from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
		}
		texture.image.unlockFocus()
		
		return texture
	}
	
	func getPatchImage(for index: Int) -> Patch? {
		
		let patchName = wad.pnames[index]
		
		
		for i in 0..<wad.patches.count {
			if patchName.uppercased() == wad.patches[i].name.uppercased() {
				return wad.patches[i]
			}
		}
		return nil
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
		
		for texture in allTextures {
			if texture.name.uppercased() == name.uppercased() {
				return texture.image
			}
		}
		return nil
	}
	
	func indexForTexture(named name: String) -> Int {
		
		for i in 0..<allTextures.count {
			if allTextures[i].name.uppercased() == name.uppercased() {
				return i
			}
		}
		return -1
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
