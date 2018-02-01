//
//  PreferencesWindowController.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/29/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {

	let defaults = UserDefaults.standard
	
	@IBOutlet weak var doomTextField: NSTextField!
	@IBOutlet weak var doom2TextField: NSTextField!
	
	override func windowDidLoad() {
        super.windowDidLoad()
		
		let doomPath = defaults.value(forKey: "DoomWADPath") as! String
		doomTextField.stringValue = doomPath

		let doom2Path = defaults.value(forKey: "Doom2WADPath") as! String
		doom2TextField.stringValue = doom2Path
    }
	
	override var windowNibName: NSNib.Name? {
		return NSNib.Name("PreferencesWindowController")
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
	
	@IBAction func savePressed(_ sender: Any) {
		
		//let defaults = UserDefaults.standard
		
		if !doomTextField.stringValue.isEmpty {
			defaults.set(doomTextField.stringValue, forKey: "DoomWADPath")
		}
		if !doom2TextField.stringValue.isEmpty {
			defaults.set(doom2TextField.stringValue, forKey: "Doom2WADPath")
		}
		
		window?.close()
	}
	
	@IBAction func cancelPressed(_ sender: Any) {
		window?.close()
	}
	
}
