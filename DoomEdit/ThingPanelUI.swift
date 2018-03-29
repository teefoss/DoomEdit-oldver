//
//  ThingPanelUI.swift
//  DoomEdit
//
//  Created by Thomas Foster on 3/24/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

/**
UI Setup for the Thing Panel
*/

extension ThingViewController {
	
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
		
		if def.game <= doomProject.projectType.rawValue {
			let item = NSMenuItem()
			item.title = def.name
			item.image = def.image
			
			item.tag = def.type
			item.target = self
			item.action = #selector(setSpecial(sender:))
			menu.addItem(item)
		}
	}
	
	func initSelectedThings() {
		
		indices = []
		for i in 0..<things.count {
			if things[i].selected == 1 {
				indices.append(i)
			}
		}
	}
	
	func setAllowedButtonState() {
		
		for button in flagButtons {
			button.allowsMixedState = (indices.count > 1)
		}
	}

}
