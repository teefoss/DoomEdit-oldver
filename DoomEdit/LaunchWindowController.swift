//
//  LaunchWindowController.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/29/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

class LaunchWindowController: NSWindowController {

	@IBOutlet weak var nameTextField: NSTextField!
	
	
	
	override var windowNibName: NSNib.Name? {
		return NSNib.Name("LaunchWindowController")
	}
	
    override func windowDidLoad() {
        super.windowDidLoad()
		
		doomProject.projectType = .doom1
    }
	
	@IBAction func projectTypeSet(_ sender: NSButton) {

		doomProject.projectType = DoomProject.ProjectType(rawValue: sender.tag)
	}
	
	@IBAction func newProjectPressed(_ sender: Any) {
		
		if nameTextField.stringValue.isEmpty {
			runAlertPanel(title: "Whoops!", message: "You must enter a project name.")
			return
		} else {
			doomProject.name = nameTextField.stringValue
			
			let panel = NSOpenPanel()
			panel.title = "Choose a location for this project"
			panel.showsResizeIndicator = true
			panel.canChooseDirectories = true
			panel.canChooseFiles = false
			panel.allowsMultipleSelection = false
			panel.canCreateDirectories = true
			
			if panel.runModal() == NSApplication.ModalResponse.OK {
				doomProject.directory = panel.url
				doomProject.createProject()
				window?.close()
			} else {
				return
			}
			
		}
	}
	
	@IBAction func openProjectPressed(_ sender: Any) {
		
		let panel = NSOpenPanel()
		panel.showsResizeIndicator = true
		panel.canChooseDirectories = false
		panel.canChooseFiles = true
		panel.allowsMultipleSelection = false
		panel.canCreateDirectories = false
		panel.allowedFileTypes = ["doomedit"]
		
		if panel.runModal() == NSApplication.ModalResponse.OK {
			doomProject.openProject(from: panel.url!)
			window?.close()
		} else {
			return
		}

	}
	
}
