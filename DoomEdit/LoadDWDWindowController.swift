//
//  LoadDWDWindowController.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/30/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

class LoadDWDWindowController: NSWindowController {

	@IBOutlet weak var fileField: NSTextField!
	@IBOutlet weak var levelButton: NSPopUpButton!
	
	var levels: [String] = []
	var dwdURL: URL?
	
	override var windowNibName: NSNib.Name? {
		return NSNib.Name("LoadDWDWindowController")
	}
	
    override func windowDidLoad() {
        super.windowDidLoad()
		
		levelButton.removeAllItems()
		levelButton.addItems(withTitles: levels)
    }
	
	@IBAction func chooseFile(_ sender: Any) {
		
		let panel = NSOpenPanel()
		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = false
		panel.canChooseFiles = true
		panel.title = "Select a .dwd file"
		panel.showsResizeIndicator = true
		panel.showsHiddenFiles = false
		panel.canCreateDirectories = false
		panel.allowedFileTypes = ["dwd"]
		
		if panel.runModal() == NSApplication.ModalResponse.OK {
			dwdURL = panel.url
			let result = panel.url?.path
			fileField.stringValue = result!
		} else {
			return
		}
	}
	
	@IBAction func addMap(_ sender: Any) {
		
		// Copy dwd file to maps directory
		let fm = FileManager.default
		
		guard let url = dwdURL else { return }
		
		let destURL = doomProject.projectMapsURL.appendingPathComponent(url.lastPathComponent, isDirectory: true)
		
		do {
			try fm.copyItem(at: url, to: destURL)
		} catch {
			print("error, could not copy dwd to maps folder!")
		}
		
		// Update project file
		guard let fileName = dwdURL?.lastPathComponent else { return }
		guard let level = levelButton.selectedItem?.title else { return }
		
		var dwd: String = ""
		do {
			dwd = try String(contentsOf: dwdURL!)
		} catch {
			print("Error! Could not read dwd file.")
		}
		
		let map = Map(name: fileName, level: level, dwd: dwd)
		doomProject.addMapToProjectFile(map)

		window!.sheetParent!.endSheet(window!, returnCode: .OK)
	}
	
	@IBAction func cancel(_ sender: Any) {

		window!.sheetParent!.endSheet(window!, returnCode: .cancel)
	}
	
	
    
}
