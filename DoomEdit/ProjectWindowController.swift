//
//  ProjectWindowController.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/29/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

// TODO: Alter map names
// TODO: Alter map level

import Cocoa

class ProjectWindowController: NSWindowController {

	@IBOutlet weak var nameLabel: NSTextField!
	@IBOutlet weak var gameLabel: NSTextField!
	@IBOutlet weak var mapNameTextField: NSTextField!
	@IBOutlet weak var levelButton: NSPopUpButton!
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var openMapButton: NSButton!
	@IBOutlet weak var removeMapButton: NSButton!
	
	var levels: [String] = []
	
	override var windowNibName: NSNib.Name? {
		return NSNib.Name("ProjectWindowController")
	}
	
    override func windowDidLoad() {
        super.windowDidLoad()

		tableView.delegate = self
		tableView.dataSource = self
		
		nameLabel.stringValue = doomProject.name
		
		switch doomProject.projectType {
		case .doom1: gameLabel.stringValue = "DOOM"
		case .doom2: gameLabel.stringValue = "DOOM 2"
		default: gameLabel.stringValue = ""
		}
		
		loadLevelButton()
		tableView.reloadData()
		updateStatus()
		
		print(doomProject.projectFileURL)
    }
	
	
	
	// ==============
	// Helper Methods
	// ==============
	
	func loadLevelButton() {
		
		levelButton.removeAllItems()
		
		switch doomProject.projectType {
		case .doom1:
			for e in 1...4 {
				for m in 1...9 {
					levels.append("E\(e)M\(m)")
				}
			}
			levelButton.addItems(withTitles: levels)
		case .doom2:
			for m in 1...9 {
				levels.append("MAP0\(m)")
			}
			for m in 10...32 {
				levels.append("MAP\(m)")
			}
			levelButton.addItems(withTitles: levels)
		default:
			break
		}
	}
	
	
	
	// ===============
	// MARK: - Actions
	// ===============
	
	@IBAction func createMap(_ sender: Any) {
		
		if mapNameTextField.stringValue.isEmpty {
			runAlertPanel(title: "Hey!", message: "You haven't entered a map name.")
			return
		}
		
		var name = mapNameTextField.stringValue

		// No illegal characters
		let dot: CharacterSet = [".", "-", "_"]
		let alphanumAndDot = dot.union(.alphanumerics)
		if !alphanumAndDot.isSuperset(of: CharacterSet(charactersIn: name)) {
			runAlertPanel(title: "Warning", message: "File name should contain only letters, numbers, '-' or '_'. Please rename.")
			return
		}
		
		// Add an extension if needed
		let suffix = name.suffix(4)
		if suffix != ".dwd" {
			name += ".dwd"
		}
		
		let dwd = "" // no map data yet
		let map = Map(name: name, level: levelButton.titleOfSelectedItem!, dwd: dwd)
		doomProject.addMapToProjectFile(map)
		tableView.reloadData()
		
		print(name)
	}
	
	@IBAction func openMap(_ sender: Any) {
		
		if editWorld.loaded {
			editWorld.closeWorld()
		}
		
		let map = doomProject.maps[tableView.selectedRow]
		doomProject.openMap = map
		editWorld.loadWorldFile(map.dwd)
		
		let appDelegate = NSApplication.shared.delegate as! AppDelegate
		if appDelegate.mapWindowController == nil {
			let mapWC = MapWindowController()
			mapWC.showWindow(self)
			appDelegate.mapWindowController = mapWC
		} else {
			appDelegate.redraw()
		}
	}
	
	@IBAction func addMap(_ sender: Any) {
		
		if let window = window {
			let panel = LoadDWDWindowController()
			panel.levels = levels
			window.beginSheet(panel.window!, completionHandler: { result in
				if result == .OK {
					self.tableView.reloadData()
				}
				panel.window?.orderOut(nil)
			})
		}
	}
	
	@IBAction func removeMap(_ sender: Any) {
		
		var val: Bool
		let selectedMap = doomProject.maps[tableView.selectedRow]
		var isOpen = false
		
		if editWorld.loaded {
			if doomProject.openMap?.name == selectedMap.name {
				isOpen = true
			}
		}
		
		val = runDialogPanel(question: "Delete Map?", text: "Warning! This cannot be undone. Are you sure?")
		
		if val {
			// Delete file
			let fm = FileManager.default
			do {
				try fm.removeItem(at: doomProject.projectMapsURL.appendingPathComponent(selectedMap.name))
			} catch {
				print("Error! Could not delete dwd file.")
			}
			// remove from doomProject.maps
			doomProject.maps.remove(at: tableView.selectedRow)
			// rewrite project file
			doomProject.writeProjectFile(at: doomProject.projectFileURL)

			tableView.reloadData()
			
			// if map is open, close it
			if isOpen {
				doomProject.openMap = nil
				doomProject.setDirtyMap(false)
				let appDelegate = NSApplication.shared.delegate as! AppDelegate
				appDelegate.mapWindowController?.close()
				appDelegate.mapWindowController = nil
			}
		}
		
	}
    
}


extension ProjectWindowController: NSTableViewDelegate, NSTableViewDataSource {
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return doomProject.maps.count
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

		var cellID: String = ""
		var text: String = ""
		let map = doomProject.maps[row]
		
		if tableColumn == tableView.tableColumns[0] {
			text = map.name
			cellID = "NameCell"
		} else if tableColumn == tableView.tableColumns[1] {
			text = map.level
			cellID = "LevelCell"
		}

		if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellID), owner: nil) as? NSTableCellView {
			cell.textField?.stringValue = text
			return cell
		}
		return nil
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		updateStatus()
	}
	
	func updateStatus() {
		
		if tableView.selectedRowIndexes.count == 0 {
			openMapButton.isEnabled = false
			removeMapButton.isEnabled = false
		} else {
			openMapButton.isEnabled = true
			removeMapButton.isEnabled = true
		}
	}
}



extension ProjectWindowController: NSWindowDelegate {
	
	func windowWillClose(_ notification: Notification) {
		
		doomProject.closeProject()
		
		let launch = LaunchWindowController()
		launch.showWindow(self)
		
		let appDelegate = NSApplication.shared.delegate as! AppDelegate
		appDelegate.launchWindowController = launch
	}
}
