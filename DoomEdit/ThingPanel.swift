//
//  ThingViewController.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/10/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

class ThingPanel: NSViewController {
	
	var thing = Thing()
	var thingIndex: Int = 0
	
	override var acceptsFirstResponder: Bool { return true }
	override func becomeFirstResponder() -> Bool { return true }
	override func resignFirstResponder() -> Bool { return true }
	
	@IBOutlet weak var nameLabel: NSTextField!
	@IBOutlet weak var typeLabel: NSTextField!
	@IBOutlet weak var typeButton: NSPopUpButton!
	@IBOutlet weak var easyButton: NSButton!
	@IBOutlet weak var normalButton: NSButton!
	@IBOutlet weak var hardButton: NSButton!
	@IBOutlet weak var ambushButton: NSButton!
	@IBOutlet weak var networkButton: NSButton!
	@IBOutlet weak var northButton: NSButton!
	@IBOutlet weak var southButton: NSButton!
	@IBOutlet weak var eastButton: NSButton!
	@IBOutlet weak var westButton: NSButton!
	@IBOutlet weak var northeastButton: NSButton!
	@IBOutlet weak var southwestButton: NSButton!
	@IBOutlet weak var northwestButton: NSButton!
	@IBOutlet weak var southeastButton: NSButton!
	@IBOutlet weak var thingImageView: NSImageView!
	@IBOutlet weak var countLabel: NSTextField!
	
	var directionButtons: [NSButton] = []

	
	
	// ==================
	// MARK: - Life Cycle
	// ==================
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		directionButtons.append(eastButton)			// 0
		directionButtons.append(northeastButton)	// 45
		directionButtons.append(northButton)		// 90
		directionButtons.append(northwestButton)	// 135
		directionButtons.append(westButton)			// 180
		directionButtons.append(southwestButton)	// 225
		directionButtons.append(southButton)		// 270
		directionButtons.append(southeastButton)	// 315
		
		setupPopupButton()
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		// Update UI
		
		nameLabel.stringValue = "Thing \(thingIndex) Properties"
		thingImageView.image = thing.def.image
		typeLabel.stringValue = thing.def.name
		updateCountLabel()
		updateButton()
		
		// Set options buttons
		
		if thing.options & SKILL_EASY == SKILL_EASY { easyButton.state = .on } else { easyButton.state = .off }
		if thing.options & SKILL_NORMAL == SKILL_NORMAL { normalButton.state = .on } else { normalButton.state = .off }
		if thing.options & SKILL_HARD == SKILL_HARD { hardButton.state = .on } else { hardButton.state = .off }
		if thing.options & AMBUSH == AMBUSH { ambushButton.state = .on } else { ambushButton.state = .off }
		if thing.options & NETWORK == NETWORK { networkButton.state = .on } else { networkButton.state = .off }
		
		// Set direction buttons
		
		var index: Int
		if thing.angle == 0 {
			index = 0
		} else {
			index = thing.angle/45
		}
		for i in 0..<directionButtons.count {
			if i == index {
				directionButtons[i].state = .on
			} else {
				directionButtons[i].state = .off
			}
		}
	}


	
	// ======================
	// MARK: - Helper Methods
	// ======================
	
	func setupPopupButton() {
		
		let playerMenu = NSMenu()
		let demonMenu = NSMenu()
		let weaponMenu = NSMenu()
		let ammoMenu = NSMenu()
		let healthMenu = NSMenu()
		let armorMenu = NSMenu()
		let powerMenu = NSMenu()
		let cardMenu = NSMenu()
		let lightMenu = NSMenu()
		let decorMenu = NSMenu()
		let deadMenu = NSMenu()
		let goreMenu = NSMenu()
		let otherMenu = NSMenu()
		
		let player = NSMenuItem(title: "Player", action: nil, keyEquivalent: "")
		let demon = NSMenuItem(title: "Demons", action: nil, keyEquivalent: "")
		let weap = NSMenuItem(title: "Weapons", action: nil, keyEquivalent: "")
		let ammo = NSMenuItem(title: "Ammo", action: nil, keyEquivalent: "")
		let health = NSMenuItem(title: "Health", action: nil, keyEquivalent: "")
		let armor = NSMenuItem(title: "Armor", action: nil, keyEquivalent: "")
		let power = NSMenuItem(title: "Power-ups", action: nil, keyEquivalent: "")
		let card = NSMenuItem(title: "Keycards", action: nil, keyEquivalent: "")
		let light = NSMenuItem(title: "Lights", action: nil, keyEquivalent: "")
		let decor = NSMenuItem(title: "Decorations", action: nil, keyEquivalent: "")
		let dead = NSMenuItem(title: "Corpses", action: nil, keyEquivalent: "")
		let gore = NSMenuItem(title: "Gore", action: nil, keyEquivalent: "")
		let other = NSMenuItem(title: "Other", action: nil, keyEquivalent: "")
		
		playerMenu.setSubmenu(playerMenu, for: player)
		demonMenu.setSubmenu(demonMenu, for: demon)
		weaponMenu.setSubmenu(weaponMenu, for: weap)
		ammoMenu.setSubmenu(ammoMenu, for: ammo)
		healthMenu.setSubmenu(healthMenu, for: health)
		armorMenu.setSubmenu(armorMenu, for: armor)
		powerMenu.setSubmenu(powerMenu, for: power)
		cardMenu.setSubmenu(cardMenu, for: card)
		lightMenu.setSubmenu(lightMenu, for: light)
		decorMenu.setSubmenu(decorMenu, for: decor)
		deadMenu.setSubmenu(deadMenu, for: dead)
		goreMenu.setSubmenu(goreMenu, for: gore)
		otherMenu.setSubmenu(otherMenu, for: other)
		
		for def in doomData.thingDefs {
			
			switch def.category {
			case "Player": addThingDef(def, to: playerMenu)
			case "Demon": addThingDef(def, to: demonMenu)
			case "Weapon": addThingDef(def, to: weaponMenu)
			case "Ammo": addThingDef(def, to: ammoMenu)
			case "Health": addThingDef(def, to: healthMenu)
			case "Armor": addThingDef(def, to: armorMenu)
			case "Power": addThingDef(def, to: powerMenu)
			case "Card": addThingDef(def, to: cardMenu)
			case "Light": addThingDef(def, to: lightMenu)
			case "Decor": addThingDef(def, to: decorMenu)
			case "Dead": addThingDef(def, to: deadMenu)
			case "Gore": addThingDef(def, to: goreMenu)
			case "Other": addThingDef(def, to: otherMenu)
			default: print("Error. Could not add \(thing.def.name) to menu!")
			}
		}
		
		typeButton.removeAllItems()
		typeButton.menu?.addItem(player)
		typeButton.menu?.addItem(demon)
		typeButton.menu?.addItem(NSMenuItem.separator())
		typeButton.menu?.addItem(weap)
		typeButton.menu?.addItem(ammo)
		typeButton.menu?.addItem(NSMenuItem.separator())
		typeButton.menu?.addItem(health)
		typeButton.menu?.addItem(armor)
		typeButton.menu?.addItem(power)
		typeButton.menu?.addItem(card)
		typeButton.menu?.addItem(NSMenuItem.separator())
		typeButton.menu?.addItem(light)
		typeButton.menu?.addItem(decor)
		typeButton.menu?.addItem(dead)
		typeButton.menu?.addItem(gore)
		typeButton.menu?.addItem(other)
	}
	
	func addThingDef(_ def: ThingDef, to menu: NSMenu) {
		if def.game <= wad.game {
			let item = NSMenuItem()
			item.title = def.name
			item.image = def.image
			
			item.tag = def.type
			item.target = self
			item.action = #selector(setSpecial(sender:))
			menu.addItem(item)
		}
	}
	
	
	
	// =========================
	// MARK: - Update UI Methods
	// =========================
	
	func updateUI() {
		
		updateCountLabel()
		updateButton()
		updateImage()
		updateTypeLabel()
	}
	
	func updateCountLabel() {
		
		var count = 0
		for thing in things {
			if thing.type == things[thingIndex].type {
				count += 1
			}
		}
		countLabel.integerValue = count
	}
	
	func updateTypeLabel() {
		
		typeLabel.stringValue = things[thingIndex].def.name
	}
	
	func updateImage() {
		
		thingImageView.image = things[thingIndex].def.image
	}
	
	func updateButton() {
		
		switch things[thingIndex].def.category {
			case "Player": typeButton.selectItem(withTitle: "Player")
			case "Demon": typeButton.selectItem(withTitle: "Demons")
			case "Weapon": typeButton.selectItem(withTitle: "Weapons")
			case "Ammo": typeButton.selectItem(withTitle: "Ammo")
			case "Health": typeButton.selectItem(withTitle: "Health")
			case "Armor": typeButton.selectItem(withTitle: "Armor")
			case "Power": typeButton.selectItem(withTitle: "Power-ups")
			case "Card": typeButton.selectItem(withTitle: "Keycards")
			case "Light": typeButton.selectItem(withTitle: "Lights")
			case "Decor": typeButton.selectItem(withTitle: "Decoration")
			case "Dead": typeButton.selectItem(withTitle: "Corpses")
			case "Gore": typeButton.selectItem(withTitle: "Gore")
			case "Other": typeButton.selectItem(withTitle: "Other")
			default: return
		}
	}


	
	// ===============
	// MARK: - Actions
	// ===============

	@objc func setSpecial(sender: NSMenuItem) {
		
		things[thingIndex].type = sender.tag
		updateUI()
	}


	/// Changes the selected things's options.
	/// NSButton tags are set in IB; each is equal to the option's bit.
	@IBAction func optionButtonClicked(_ sender: NSButton) {
		
		if sender.state == .on {
			things[thingIndex].options += sender.tag
		} else {
			things[thingIndex].options -= sender.tag
		}
	}
	
	@IBAction func directionClicked(_ sender: NSButton) {
		
		things[thingIndex].angle = sender.tag
	}
	
	
	
}
