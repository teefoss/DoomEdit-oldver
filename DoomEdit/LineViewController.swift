//
//  LineViewController.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/10/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

protocol TexturePanelDelegate {
	func updateTextureLabelFromPanel(name: String, position: Int)
	func updateOffsets()
	func updateImageFromPanel(name: String, position: Int)
}

class LineViewController: NSViewController, TexturePanelDelegate, NSTabViewDelegate {

	// The selected line
	var lineIndex: Int = 0
	var selectedLineIndices: [Int] = []
	var baseline: Line
	
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
	@IBOutlet weak var suggestButton: NSButton!
	@IBOutlet weak var setAllTexturesButton: NSButton!
	
	var flagButtons: [NSButton] = []
	
	var frontUppers: [String] = []
	var frontMiddles: [String] = []
	var frontLowers: [String] = []
	var backUppers: [String] = []
	var backMiddles: [String] = []
	var backLowers: [String] = []

	init() {
		baseline = Line()
		baseline.flags = BLOCKS_ALL
		baseline.pt1 = -1
		baseline.pt2 = -1
		baseline.side[0]?.upperTexture = "-"
		baseline.side[0]?.lowerTexture = "-"
		baseline.side[0]?.middleTexture = "-"
		baseline.side[0] = Side()
		baseline.side[0]?.ends.floorHeight = 0
		baseline.side[0]?.ends.ceilingHeight = 80
		baseline.side[0]?.ends.floorFlat = "FLAT1"
		baseline.side[0]?.ends.ceilingFlat = "FLAT2"

		super.init(nibName: NSNib.Name(rawValue: "LinePanel"), bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
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

		setupSpecialMenu()
    }
	
	
	override func viewWillAppear() {
		super.viewWillAppear()

		updatePanel()
	}
	
	func hasMultiple<T: Equatable>(array: [T]) -> Bool {

		let first = array.first
		for element in array {
			if element != first {
				return true
			}
		}
		return false
	}
	
	
	override func viewWillDisappear() {
		super.viewWillDisappear()

		setTag()
		setOffsets()
		selectedLineIndices = []
	}
	
	
	
	// =================
	// MARK: - Update UI
	// =================
	
	func clearPanel() {

		titleLabel.stringValue = "Line Properties (No Selection)"
		for button in flagButtons {
			button.state = .off
		}
		updateSpecialButton(for: 0)
		tagTextField.stringValue = ""
		tabView.selectTabViewItem(at: 0)
		frontUpperImageView.image = nil
		frontUpperLabel.stringValue = "--"
		frontMiddleImageView.image = nil
		frontMiddleLabel.stringValue = "--"
		frontLowerImageView.image = nil
		frontLowerLabel.stringValue = "--"
		frontXOffsetTextField.stringValue = ""
		frontYOffsetTextField.stringValue = ""
	}
	
	func updatePanel() {
		
		initSelectedLines()  // Store indices of currently selected lines
		
		
		
		print("num selected lines: \(selectedLineIndices.count)")
		// Add an nsmenuitem if there are multiple specials
		if selectedLineIndices.count == 0 {
			clearPanel()
			return
		} else if selectedLineIndices.count == 1 {
			updateSpecialButton(for: lines[selectedLineIndices[0]].special)
			
			for i in 0..<flagButtons.count {
				lines[selectedLineIndices[0]].flags & (1 << i) == (1 << i) ? (flagButtons[i].state = .on) : (flagButtons[i].state = .off)
			}

			lines[selectedLineIndices[0]].tag == 0 ? (tagTextField.stringValue = "") : (tagTextField.integerValue = lines[selectedLineIndices[0]].tag)

		} else {
			let first = lines[selectedLineIndices[0]].special
			var next = -1
			loop: for i in 1..<selectedLineIndices.count {
				next = lines[selectedLineIndices[i]].special
				if next != first {
					break loop
				}
			}
			if next != first {
				let mult = NSMenuItem(title: "Multiple", action: nil, keyEquivalent: "")
				specialsPopUpButton.menu?.addItem(NSMenuItem.separator())
				specialsPopUpButton.menu?.addItem(mult)
				specialsPopUpButton.select(mult)
				specialLabel.stringValue = "--"
			} else {
				//updateSpecialLabel(for: first)
				updateSpecialButton(for: first)
			}
			
			setButtonState(&blocksAllButton, option: BLOCKS_ALL)
			setButtonState(&blocksMonstersButton, option: BLOCKS_MONSTERS)
			setButtonState(&blocksSoundButton, option: BLOCKS_SOUND)
			setButtonState(&twoSidedButton, option: TWO_SIDED)
			setButtonState(&upperUnpeggedButton, option: UPPER_UNPEGGED)
			setButtonState(&lowerUnpeggedButton, option: LOWER_UNPEGGED)
			setButtonState(&onMapButton, option: SHOW_ON_MAP)
			setButtonState(&notOnMapButton, option: NOT_ON_MAP)
			setButtonState(&secretButton, option: SECRET)

			let firsttag = lines[selectedLineIndices[0]].tag
			var nexttag = 0
			loop: for i in 1..<selectedLineIndices.count {
				nexttag = lines[selectedLineIndices[i]].tag
				if nexttag != firsttag {
					break loop
				}
			}
			if nexttag != firsttag {
				tagTextField.stringValue = ""
			} else {
				tagTextField.integerValue = firsttag
			}

		}
		
		setAllowedButtonState()
		setTitle()
		tabView.selectTabViewItem(at: 0)  // Open with front side tab selected
		
		if flagButtons[2].state == .off {
			tabView.tabViewItems[1].label = "-"
		} else {
			tabView.tabViewItems[1].label = "Back"
		}
		
		// Display the line information
		
		frontUppers = []; frontMiddles = []; frontLowers = []
		backUppers = []; backMiddles = []; backLowers = []
		for index in selectedLineIndices {
			frontUppers.append(lines[index].side[0]?.upperTexture ?? "-")
			frontMiddles.append(lines[index].side[0]?.middleTexture ?? "-")
			frontLowers.append(lines[index].side[0]?.lowerTexture ?? "-")
			if let side = lines[index].side[1] {
				backUppers.append(side.upperTexture ?? "-")
				backMiddles.append(side.middleTexture ?? "-")
				backLowers.append(side.lowerTexture ?? "-")
			}
		}
		
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
		
		frontUpperImageView.selectedLineIndices = selectedLineIndices
		frontMiddleImageView.selectedLineIndices = selectedLineIndices
		frontLowerImageView.selectedLineIndices = selectedLineIndices
		backUpperImageView.selectedLineIndices = selectedLineIndices
		backMiddleImageView.selectedLineIndices = selectedLineIndices
		backLowerImageView.selectedLineIndices = selectedLineIndices
	}
	

	/// Set the current line's special from the menu selection
	@objc func setSpecial(sender: NSMenuItem) {
		for index in selectedLineIndices {
			lines[index].special = sender.tag
		}
		updateSpecialButton(for: sender.tag)
	}
	
	@objc func clearSpecial(sender: NSMenuItem) {
		for index in selectedLineIndices {
			lines[index].special = 0
		}
		updateSpecialButton(for: 0)
	}

	func updateSpecialButton(for tag: Int) {
		
		for special in doomData.lineSpecials {
			if tag == special.index {
				specialsPopUpButton.selectItem(withTitle: special.type)
				specialLabel.stringValue = special.name
				break
			} else {
				specialsPopUpButton.selectItem(withTitle: "None")
				specialLabel.stringValue = "--"
			}
		}
	}
	
	func setTag() {
		if !tagTextField.stringValue.isEmpty {
			for index in selectedLineIndices {
				lines[index].tag = tagTextField.integerValue
			}
		}
	}
	
	func updateTextureLabelFromPanel(name: String, position: Int) {
		
		switch position {
		case 1:
			frontLowerLabel.textColor = Color.textColor
			frontLowerLabel.stringValue = name
		case 2:
			frontMiddleLabel.textColor = Color.textColor
			frontMiddleLabel.stringValue = name
		case 3:
			frontUpperLabel.textColor = Color.textColor
			frontUpperLabel.stringValue = name
		case -1:
			backLowerLabel.textColor = Color.textColor
			backLowerLabel.stringValue = name
		case -2:
			backLowerLabel.textColor = Color.textColor
			backMiddleLabel.stringValue = name
		case -3:
			backLowerLabel.textColor = Color.textColor
			backUpperLabel.stringValue = name
		default: return
		}
	}

	func updateTextureLabels() {

		if hasMultiple(array: frontUppers) {
			frontUpperLabel.textColor = NSColor.red
			frontUpperLabel.stringValue = "Multiple"
		} else {
			frontUpperLabel.textColor = Color.textColor
			frontUpperLabel.stringValue = lines[selectedLineIndices[0]].side[0]?.upperTexture ?? "-"
		}
		
		if hasMultiple(array: frontMiddles) {
			frontMiddleLabel.textColor = NSColor.red
			frontMiddleLabel.stringValue = "Multiple"
		} else {
			frontMiddleLabel.textColor = Color.textColor
			frontMiddleLabel.stringValue = lines[selectedLineIndices[0]].side[0]?.middleTexture ?? "-"
		}

		if hasMultiple(array: frontLowers) {
			frontLowerLabel.textColor = NSColor.red
			frontLowerLabel.stringValue = "Multiple"
		} else {
			frontLowerLabel.textColor = Color.textColor
			frontLowerLabel.stringValue = lines[selectedLineIndices[0]].side[0]?.lowerTexture ?? "-"
		}

		if hasMultiple(array: backUppers) {
			backUpperLabel.textColor = NSColor.red
			backUpperLabel.stringValue = "Multiple"
		} else {
			backUpperLabel.textColor = Color.textColor
			backUpperLabel.stringValue = lines[selectedLineIndices[0]].side[1]?.upperTexture ?? "-"
		}
		
		if hasMultiple(array: backMiddles) {
			backMiddleLabel.textColor = NSColor.red
			backMiddleLabel.stringValue = "Multiple"
		} else {
			backMiddleLabel.textColor = Color.textColor
			backMiddleLabel.stringValue = lines[selectedLineIndices[0]].side[1]?.middleTexture ?? "-"
		}
		
		if hasMultiple(array: backLowers) {
			backLowerLabel.textColor = NSColor.red
			backLowerLabel.stringValue = "Multiple"
		} else {
			backLowerLabel.textColor = Color.textColor
			backLowerLabel.stringValue = lines[selectedLineIndices[0]].side[1]?.lowerTexture ?? "-"
		}
	}
	
	func updateOffsets() {
		
		if selectedLineIndices.count == 1 {
			frontXOffsetTextField.integerValue = lines[selectedLineIndices[0]].side[0]!.x_offset
			frontYOffsetTextField.integerValue = lines[selectedLineIndices[0]].side[0]!.y_offset
			backXOffset.integerValue = lines[selectedLineIndices[0]].side[1]?.x_offset ?? 0
			backYOffset.integerValue = lines[selectedLineIndices[0]].side[1]?.y_offset ?? 0
		} else {
			var frontXOffsets: [Int] = []
			var frontYOffsets: [Int] = []
			var backXOffsets: [Int] = []
			var backYOffsets: [Int] = []
			
			for index in selectedLineIndices {
				frontXOffsets.append(lines[index].side[0]!.x_offset)
				frontYOffsets.append(lines[index].side[0]!.y_offset)
				if let side = lines[index].side[1] {
					backXOffsets.append(side.x_offset)
					backYOffsets.append(side.y_offset)
				}
			}

			if hasMultiple(array: frontXOffsets) {
				frontXOffsetTextField.stringValue = ""
			} else {
				frontXOffsetTextField.integerValue = frontXOffsets[0]
			}
			if hasMultiple(array: frontYOffsets) {
				frontYOffsetTextField.stringValue = ""
			} else {
				frontYOffsetTextField.integerValue = frontYOffsets[0]
			}
			if hasMultiple(array: backXOffsets) && (backXOffsets.count > 1) {
				backXOffset.stringValue = ""
			} else {
				if !backXOffsets.isEmpty {
					backXOffset.integerValue = backXOffsets[0]
				} else {
					backXOffset.integerValue = 0
				}
			}
			if hasMultiple(array: backYOffsets) && (backYOffsets.count > 1) {
				backYOffset.stringValue = ""
			} else {
				if !backYOffsets.isEmpty{
					backYOffset.integerValue = backYOffsets[0]
				} else {
					backYOffset.integerValue = 0
				}
			}
		}
	}
	
	func setOffsets() {
		
		if !frontXOffsetTextField.stringValue.isEmpty {
			for index in selectedLineIndices {
				lines[index].side[0]!.x_offset = frontXOffsetTextField.integerValue
			}
		}
		if !frontYOffsetTextField.stringValue.isEmpty {
			for index in selectedLineIndices {
				lines[index].side[0]!.y_offset = frontYOffsetTextField.integerValue
			}
		}
		if !backXOffset.stringValue.isEmpty {
			for index in selectedLineIndices {
				if lines[index].side[1] != nil {
					lines[index].side[1]!.x_offset = backXOffset.integerValue
				}
			}
		}
		if !backYOffset.stringValue.isEmpty {
			for index in selectedLineIndices {
				if lines[index].side[1] != nil {
					lines[index].side[1]!.y_offset = backYOffset.integerValue
				}
			}
		}
	}
	
	func setImage(_ imageView: inout TextureImageView!, names: [String]) {
		
		// might be no back sides selected
		if names == [] {
			imageView.image = nil
			imageView.textureIndex = -1
			return
		}
		
		if selectedLineIndices.count == 1 {
			imageView.image = imageForTexture(named: names[0])
			imageView.textureIndex = indexForTexture(named: names[0])
		} else {
			if hasMultiple(array: names) {
				imageView.image = nil
				imageView.textureIndex = -1
			} else {
				let t = names[0]
				if t != "-" {
					imageView.image = imageForTexture(named: t)
					imageView.textureIndex = indexForTexture(named: t)
				} else {
					imageView.image = nil
					imageView.textureIndex = -1
				}
			}
		}
	}
	
	func updateImageFromPanel(name: String, position: Int) {
		
		if name != "-" {
			switch position {
			case 1: frontLowerImageView.image = imageForTexture(named: name)
			case 2: frontMiddleImageView.image = imageForTexture(named: name)
			case 3: frontUpperImageView.image = imageForTexture(named: name)
			case -1: backLowerImageView.image = imageForTexture(named: name)
			case -2: backMiddleImageView.image = imageForTexture(named: name)
			case -3: backUpperImageView.image = imageForTexture(named: name)
			default: return
			}
		} else {
			switch position {
			case 1: frontLowerImageView.image = nil
			case 2: frontMiddleImageView.image = nil
			case 3: frontUpperImageView.image = nil
			case -1: backLowerImageView.image = nil
			case -2: backMiddleImageView.image = nil
			case -3: backUpperImageView.image = nil
			default: return
			}
		}
	}
	
	func updateImages() {

		setImage(&frontUpperImageView, names: frontUppers)
		setImage(&frontMiddleImageView, names: frontMiddles)
		setImage(&frontLowerImageView, names: frontLowers)
		setImage(&backUpperImageView, names: backUppers)
		setImage(&backMiddleImageView, names: backMiddles)
		setImage(&backLowerImageView, names: backLowers)
	}
	
	/// Get the texture image
	func imageForTexture(named name: String) -> NSImage? {
		
		for texture in wad.textures {
			if texture.name.uppercased() == name.uppercased() {
				return texture.image
			}
		}
		return nil
	}
	
	/// Get the texture index
	func indexForTexture(named name: String) -> Int {
		
		for i in 0..<wad.textures.count {
			if wad.textures[i].name.uppercased() == name.uppercased() {
				return i
			}
		}
		return -1
	}
	
	@IBAction func changeOption(_ sender: NSButton) {

		sender.allowsMixedState = false
		
		if sender.state == .on {
			for index in selectedLineIndices {
				lines[index].flags += sender.tag
			}
		} else if sender.state == .off {
			for index in selectedLineIndices {
				lines[index].flags -= sender.tag
			}
		}
		
		// Remove the back side tab label is not two-sided
		if sender.tag == 4 {
			if sender.state == .on {
				tabView.tabViewItems[1].label = "Back"
			} else if sender.state == .off {
				tabView.tabViewItems[1].label = "-"
			}
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
	
	/// Disable the back side tab is not two-sided
	func tabView(_ tabView: NSTabView, shouldSelect tabViewItem: NSTabViewItem?) -> Bool {
		if tabViewItem == tabView.tabViewItem(at: 0) {
			return true
		} else {
			return flagButtons[2].state == .on
		}
	}
}
