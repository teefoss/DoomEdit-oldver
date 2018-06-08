//
//  PreferencesWindowController.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/29/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

struct UIStyle {
	var background: 	NSColor
	var oneSidedLines: 	NSColor
	var twoSidedLines: 	NSColor
	var monsters: 		NSColor
	var thingInfo: 		NSColor
	var grid: 			NSColor
	var tile: 			NSColor
	var textColor:		NSColor
	var index:			Int
}

var currentStyle: UIStyle = lightStyle

let lightStyle = UIStyle(background: .white,
						 oneSidedLines: .black,
						 twoSidedLines: .gray,
						 monsters: .black,
						 thingInfo: .white,
						 grid: NSColor.systemBlue.withAlphaComponent(0.1),
						 tile: NSColor.systemBlue.withAlphaComponent(0.3),
						 textColor: NSColor.black,
						 index: 1)

let darkStyle = UIStyle(background: .black,
						oneSidedLines: .yellow,
						twoSidedLines: .gray,
						monsters: .white,
						thingInfo: .black,
						grid: NSColor.systemBlue.withAlphaComponent(0.2),
						tile: NSColor.systemBlue.withAlphaComponent(0.4),
						textColor: NSColor.white,
						index: 2)


struct PrefKeys {
	static let doomWADPath = "DoomWADPath"
	static let doom2WADPath = "Doom2WADPath"
	static let chocolateDoomPath = "ChocolateDoomPath"
	static let netGame = "NetGame"
	static let deathmatch = "Deathmatch"
	static let noMonsters = "NoMonsters"
	static let skill = "Skill"
	static let windowed = "Windowed"
	static let noMusic = "NoMusic"
	static let theme = "Theme"	// Int - 1: Light, 2: Dark
}

class PreferencesWindowController: NSWindowController {
	
	let defaults = UserDefaults.standard
	
	var theme = 1
	var skill = 0
	var skillButtons: [NSButton] = []
	
	@IBOutlet weak var lightThemeButton: NSButton!
	@IBOutlet weak var darkThemeButton: NSButton!
	
	@IBOutlet weak var doomTextField: NSTextField!
	@IBOutlet weak var doom2TextField: NSTextField!

	@IBOutlet weak var chocDoomTextField: NSTextField!
	@IBOutlet weak var netGameButton: NSButton!
	@IBOutlet weak var deathmatchButton: NSButton!
	@IBOutlet weak var noMonstersButton: NSButton!
	@IBOutlet weak var skill1button: NSButton!
	@IBOutlet weak var skill2button: NSButton!
	@IBOutlet weak var skill3button: NSButton!
	@IBOutlet weak var skill4button: NSButton!
	@IBOutlet weak var skill5button: NSButton!
	@IBOutlet weak var windowedButton: NSButton!
	@IBOutlet weak var noMusicButton: NSButton!
	
	override func windowDidLoad() {
		super.windowDidLoad()
		
		if let theme = defaults.value(forKey: PrefKeys.theme) as? Int {
			if theme == 1 {
				lightThemeButton.state = .on
			} else if theme == 2 {
				darkThemeButton.state = .on
			}
		}
		
		skillButtons.append(skill1button)
		skillButtons.append(skill2button)
		skillButtons.append(skill3button)
		skillButtons.append(skill4button)
		skillButtons.append(skill5button)
		
		// set ui to stored values
		if let doomPath = defaults.value(forKey: PrefKeys.doomWADPath) as? String {
			doomTextField.stringValue = doomPath
		}
		if let doom2Path = defaults.value(forKey: PrefKeys.doom2WADPath) as? String {
			doom2TextField.stringValue = doom2Path
		}
		if let chocPath = defaults.value(forKey: PrefKeys.chocolateDoomPath) as? String {
			chocDoomTextField.stringValue = chocPath
		}
		if let netgame = defaults.value(forKey: PrefKeys.netGame) as? Bool {
			netgame ? (netGameButton.state = .on) : (netGameButton.state = .off)
		}
		if let dm = defaults.value(forKey: PrefKeys.deathmatch) as? Bool {
			dm ? (deathmatchButton.state = .on) : (deathmatchButton.state = .off)
		}
		if let nomon = defaults.value(forKey: PrefKeys.noMonsters) as? Bool {
			nomon ? (noMonstersButton.state = .on) : (noMonstersButton.state = .off)
		}

		if let sk = defaults.value(forKey: PrefKeys.skill) as? Int {
			skill = sk
			for button in skillButtons {
				if button.tag == sk {
					button.state = .on
				}
			}
		} else {
			skill4button.state = .on
		}
		if let win = defaults.value(forKey: PrefKeys.windowed) as? Bool {
			win ? (windowedButton.state = .on) : (windowedButton.state = .off)
		}
		if let nomus = defaults.value(forKey: PrefKeys.noMusic) as? Bool {
			nomus ? (noMusicButton.state = .on) : (noMusicButton.state = .off)
		}
	}
	
	override var windowNibName: NSNib.Name? {
		return NSNib.Name("PreferencesWindowController")
	}
	
	@IBAction func setTheme(_ sender: NSButton) {
		theme = sender.tag
	}
	
	
	@IBAction func setWADPath(_ sender: NSButton) {
		
		let dialog = NSOpenPanel()
		dialog.title = "Select .wad file"
		dialog.showsResizeIndicator = true
		dialog.showsHiddenFiles = false
		dialog.canChooseDirectories = true
		dialog.canCreateDirectories = false
		dialog.allowsMultipleSelection = false
		dialog.allowedFileTypes = ["wad"]
		
		if dialog.runModal() == NSApplication.ModalResponse.OK {
			let result = dialog.url
			
			if result != nil {
				let path = result!.path
				if sender.tag == 1 {
					doomTextField.stringValue = path
				} else if sender.tag == 2 {
					doom2TextField.stringValue = path
				}
			}
		} else {
			return
		}
	}
	
	@IBAction func setChocDoomPath(_ sender: Any) {
		
		let dialog = NSOpenPanel()
		//dialog.title = "Select Chocolate Doom"
		dialog.showsResizeIndicator = true
		dialog.showsHiddenFiles = false
		dialog.canChooseDirectories = true
		dialog.canCreateDirectories = false
		dialog.allowsMultipleSelection = false
		dialog.allowedFileTypes = ["app"]
		
		if dialog.runModal() == NSApplication.ModalResponse.OK {
			let result = dialog.url
			
			if result != nil {
				let path = result!.path
				chocDoomTextField.stringValue = path
			}
		} else {
			return
		}
		
	}
	
	@IBAction func skillPressed(_ sender: NSButton) {
		skill = sender.tag
	}
	
	
	// OK button clicked
	@IBAction func savePressed(_ sender: Any) {
		
		defaults.set(theme, forKey: PrefKeys.theme)
		
		if let delegate = NSApp.delegate as? AppDelegate {
			delegate.setTheme()
		}
		
		// Save WAD Paths
		if doomTextField.stringValue == "" {
			defaults.removeObject(forKey: PrefKeys.doomWADPath)
		} else {
			defaults.set(doomTextField.stringValue, forKey: PrefKeys.doomWADPath)
		}
		
		if doom2TextField.stringValue == "" {
			defaults.removeObject(forKey: PrefKeys.doom2WADPath)
		} else {
			defaults.set(doom2TextField.stringValue, forKey: PrefKeys.doom2WADPath)
		}

		defaults.set(chocDoomTextField.stringValue, forKey: PrefKeys.chocolateDoomPath)
		defaults.set((netGameButton.state == .on), forKey: PrefKeys.netGame)
		defaults.set((deathmatchButton.state == .on), forKey: PrefKeys.deathmatch)
		defaults.set((noMonstersButton.state == .on), forKey: PrefKeys.noMonsters)
		defaults.set(skill, forKey: PrefKeys.skill)
		defaults.set((windowedButton.state == .on), forKey: PrefKeys.windowed)
		defaults.set((noMusicButton.state == .on), forKey: PrefKeys.noMusic)
		
		window?.close()
	}
	
	@IBAction func cancelPressed(_ sender: Any) {
		window?.close()
	}
	
}
