//
//  LinePanelUI.swift
//  DoomEdit
//
//  Created by Thomas Foster on 3/8/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

extension LineViewController {
	
	/// Create all the menu items, set submenus, add specials to menu.
	func setupSpecialMenu() {
		
		// Create specials submenus
		let manualMenu = NSMenu()
		let buttonMenu = NSMenu()
		let switchMenu = NSMenu()
		let triggerMenu = NSMenu()
		let retriggerMenu = NSMenu()
		let effectMenu = NSMenu()
		let impactMenu = NSMenu()
		
		// Create specials menu
		let noneMenuItem = NSMenuItem(title: "None", action: #selector(clearSpecial(sender:)), keyEquivalent: "")
		let manualMenuItem = NSMenuItem(title: "Manual", action: nil, keyEquivalent: "")
		let buttonMenuItem = NSMenuItem(title: "Button", action: nil, keyEquivalent: "")
		let switchMenuItem = NSMenuItem(title: "Switch", action: nil, keyEquivalent: "")
		let triggerMenuItem = NSMenuItem(title: "Trigger", action: nil, keyEquivalent: "")
		let retriggerMenuItem = NSMenuItem(title: "Retrigger", action: nil, keyEquivalent: "")
		let effectMenuItem = NSMenuItem(title: "Effect", action: nil, keyEquivalent: "")
		let impactMenuItem = NSMenuItem(title: "Impact", action: nil, keyEquivalent: "")
		
		// Set the submenus
		manualMenu.setSubmenu(manualMenu, for: manualMenuItem)
		buttonMenu.setSubmenu(buttonMenu, for: buttonMenuItem)
		switchMenu.setSubmenu(switchMenu, for: switchMenuItem)
		triggerMenu.setSubmenu(triggerMenu, for: triggerMenuItem)
		retriggerMenu.setSubmenu(retriggerMenu, for: retriggerMenuItem)
		effectMenu.setSubmenu(effectMenu, for: effectMenuItem)
		impactMenu.setSubmenu(impactMenu, for: impactMenuItem)
		
		for special in doomData.lineSpecials {
			
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
	
	/// For setting up the specials menu
	func addSpecial(_ special: LineSpecial, to menu: NSMenu) {
		let item = NSMenuItem()
		item.title = special.name
		item.tag = special.index
		item.target = self
		item.action = #selector(setSpecial(sender:))
		menu.addItem(item)
	}
	
	/// Call to set up checkbox buttons when multiple lines are selected
	func setButtonState(_ button: inout NSButton!, option: Int) {
		let first = lines[selectedLineIndices[0]].hasOption(option)
		var next = false
		loop: for i in 1..<selectedLineIndices.count {
			next = lines[selectedLineIndices[i]].hasOption(option)
			if next != first {
				break loop
			}
		}
		if next != first {
			button.state = .mixed
		} else {
			first ? (button.state = .on) : (button.state = .off)
		}
	}

	/// Store indices lines that are currently selected
	func initSelectedLines() {
		
		selectedLineIndices = []
		for i in 0..<lines.count {
			if lines[i].selected > 0 {
				selectedLineIndices.append(i)
			}
		}
	}
	
	func setAllowedButtonState() {

		for i in 0..<flagButtons.count {
			flagButtons[i].allowsMixedState = (selectedLineIndices.count > 1)
		}
	}
	
	func setTitle() {
		
		if selectedLineIndices.count == 1 {
			titleLabel.stringValue = "Line \(selectedLineIndices[0]) Properties"
		} else if selectedLineIndices.count > 1 {
			titleLabel.textColor = NSColor.red
			titleLabel.stringValue = "Line Properties (multiple)"
		} else {
			print("Error")
		}
	}
	
}
