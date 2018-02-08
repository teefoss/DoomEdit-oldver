//
//  LaunchWindowController.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/29/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

class LaunchWindowController: NSWindowController {

	var recentProjects: [URL]?
	
	@IBOutlet weak var nameTextField: NSTextField!
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var clearListButton: NSButton!
	@IBOutlet weak var openRecentButton: NSButton!

	override var windowNibName: NSNib.Name? {
		return NSNib.Name("LaunchWindowController")
	}
	
    override func windowDidLoad() {
        super.windowDidLoad()
		
		tableView.delegate = self
		tableView.dataSource = self
		
		doomProject.projectType = .doom1
		doomProject.loadRecents()

		updateButtons()
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
	
	@IBAction func openRecent(_ sender: Any) {
		
		if let recents = doomProject.recentProjects {
			doomProject.openProject(from: recents[tableView.selectedRow])
			window?.close()
		}
	}
	
	
	@IBAction func clearRecents(_ sender: Any) {
		
		let val = runDialogPanel(question: "Clear Recent Projects List", text: "Are you sure?")
		if val {
			doomProject.recentProjects = []
			doomProject.saveRecents()
			tableView.reloadData()
			updateButtons()
		}
	}
	
	func updateButtons() {
		
		openRecentButton.isEnabled = tableView.selectedRowIndexes.count != 0
		clearListButton.isEnabled = tableView.numberOfRows != 0
	}
}



extension LaunchWindowController: NSTableViewDelegate, NSTableViewDataSource {

	func numberOfRows(in tableView: NSTableView) -> Int {

		doomProject.loadRecents()
		return doomProject.recentProjects?.count ?? 0
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		
		updateButtons()
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "RecentCell"), owner: nil) as? NSTableCellView {
			cell.textField?.stringValue = doomProject.recentProjects?[row].lastPathComponent ?? ""
			return cell
		}
		return nil

	}
	
}
