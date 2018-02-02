//
//  ProjectWindowController.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/29/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

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
		// TODO:
	}
	
	@IBAction func openMap(_ sender: Any) {
		
		let map = doomProject.maps[tableView.selectedRow]
		doomProject.openMap = map
		editWorld.loadDWDFile(map.dwd)
		
		let appDelegate = NSApplication.shared.delegate as! AppDelegate
		
		let mapWC = MapWindowController()
		mapWC.showWindow(self)
		appDelegate.mapWindowController = mapWC
		
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
		// TODO:
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
