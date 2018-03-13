//
//  DoomProject.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/29/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

struct Map {
	var name: String = ""
	var level: String = ""
	var dwd: String = ""
}


var doomProject = DoomProject()

class DoomProject {
	
	var loaded: Bool = false
	var projectType: ProjectType!	// Doom or Doom 2
	var name: String = ""
	var directory: URL!			// the directory the project folder is in
	var projectURL: URL!		// the project folder
	var projectMapsURL: URL!	// the folder containing the project dwd and wad files
	var projectFileURL: URL!	// the url to the project file
	var currentMapURL: URL? {
		if let map = openMap {
			return projectMapsURL.appendingPathComponent(map.name)
		} else {
			return nil
		}
	}
	var wadURL: URL!
	
	var recentProjects: [URL]? = []
	var maps: [Map] = []
	var openMap: Map?
	
	var mapDirty = false
	var projectDirty = false
	
	enum ProjectType: Int {
		case doom1 = 1
		case doom2 = 2
	}
	
	func checkDirtyProject() {
		
		if projectDirty == false {
			return
		}
		let val = runDialogPanel(question: "Important", text: "Do you wish to save your project before exiting?")
		if val {
			saveProject()
		}
	}
	
	func closeProject() {
		loaded = false
		projectType = nil
		name = ""
		projectURL = nil
		directory = nil
		projectMapsURL = nil
		projectFileURL = nil
		maps = []
		openMap = nil
		mapDirty = false
		projectDirty = false
		wadURL = nil
	}
	
	func quit() {
		
		editWorld.closeWorld()
		checkDirtyProject()
	}
	
	func setDirtyMap(_ bool: Bool) {

		mapDirty = bool
		let appdel = NSApplication.shared.delegate as! AppDelegate
		if let mapwin = appdel.mapWindowController {
			mapwin.setDocumentEdited(bool)
		}
	}
	
	func saveProject() {
		
		if !loaded {
			return
		}
		writeProjectFile(at: projectFileURL)
		loadMaps()  // update the maps array in case a dwd has changed
		projectDirty = false
	}
	
	func createProject() {
		
		let fm = FileManager.default
		
		// Set the url for the project folder
		let url = directory.appendingPathComponent(name, isDirectory: true)
		projectURL = url
		
		// Create the project folder
		if !fm.fileExists(atPath: url.path) {
			do {
				try fm.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
			} catch {
				runAlertPanel(title: "Error!", message: "Could not create project directory.")
				return
			}
		} else {
			runAlertPanel(title: "Error", message: "A folder called \(url.lastPathComponent) already exists!")
		}
		
		// Set the url for the maps folder
		let mapurl = url.appendingPathComponent("maps", isDirectory: true)
		projectMapsURL = mapurl
		
		// Create the maps folder
		do {
			try fm.createDirectory(at: mapurl, withIntermediateDirectories: true, attributes: nil)
		} catch {
			fatalError("While creating project folder, could not create maps folder.")
		}
		
		// Set the url for the project file
		let projectFile = url.appendingPathComponent(name, isDirectory: false).appendingPathExtension("doomedit")
		projectFileURL = projectFile

		// Create and write the project file
		fm.createFile(atPath: projectFile.path, contents: nil, attributes: nil)
		writeProjectFile(at: projectFile)
		
		loadProject()
	}
	
	/// Gets the right WAD and opens the project window
	func loadProject() {
		
		switch projectType {
		case .doom1:
			let path = UserDefaults.standard.value(forKey: "DoomWADPath") as! String
			wadURL = URL(fileURLWithPath: path)
			wad.setWadLoation(wadURL)
		case .doom2:
			let path = UserDefaults.standard.value(forKey: "Doom2WADPath") as! String
			let wadURL = URL(fileURLWithPath: path)
			wad.setWadLoation(wadURL)
		default:
			break
		}
		
		DispatchQueue.global(qos: .background).async {
			wad.loadAssets()
		}
		
		mapDirty = false
		projectDirty = false
		loaded = true
		
		loadRecents()
		
		var exists: Bool = false
		if let recents = recentProjects {
			for url in recents {
				if url == projectFileURL {
					exists = true
					break
				}
			}
		}

		if !exists {
			if recentProjects?.count == 50 {
				recentProjects?.remove(at: 0)
			}
			recentProjects?.append(projectFileURL)
			saveRecents()
		}

		// Open the project window
		let appDelegate = NSApplication.shared.delegate as! AppDelegate
		let proj = ProjectWindowController()
		proj.positionAtScreenTopRight()
		proj.showWindow(self)
		appDelegate.projectWindowController = proj
	}
	
	/// Opens a project file and sets project info
	func openProject(from url: URL) {
		
		checkDirtyProject()
		
		// Set URLs
		projectFileURL = url
		directory = url.deletingLastPathComponent()
		projectMapsURL = directory.appendingPathComponent("maps", isDirectory: true)
		
		// Get the project info from the project file
		readProjectFile(from: url)
		
		// No maps, just load
		if maps.count == 0 {
			loadProject()
			return
		}
		
		loadMaps()
		loadProject()
	}
	
	func loadMaps() {
		
		for m in 0..<maps.count {
			let url = projectMapsURL.appendingPathComponent(maps[m].name)
			do {
				try maps[m].dwd = String(contentsOf: url)
			} catch {
				print("Error! Could not load \(maps[m].name).dwd into project.")
			}
		}
	}
	
	func writeProjectFile(at url: URL) {
		
		var data = ""
		
		data.append("DoomEdit Project File Version: 1\n\n")
		data.append("Name: \(name)\n")
		data.append("WAD: \(projectType.rawValue)\n")
		data.append("Maps: \(maps.count)\n")
		
		for map in maps {
			data.append("-\(map.name): \(map.level)\n")
		}
		
		do {
			try data.write(to: url, atomically: false, encoding: .ascii)
		} catch {
			runAlertPanel(title: "Error!", message: "Could not write project file")
		}
	}
	
	func addMapToProjectFile(_ map: Map) {
		
		maps.append(map)
		writeProjectFile(at: projectFileURL)
	}
	
	func readProjectFile(from url: URL) {
		
		var fileContents: String?
		do {
			try fileContents = String(contentsOf: url)
		} catch {
			print("Error! could not load project file")
		}
		guard let fileLines = fileContents?.components(separatedBy: .newlines) else { return }
		
		for line in fileLines {
			readProjectFileLine(line)
		}
	}
	
	func readProjectFileLine(_ fileLine: String) {
		
		let scanner = Scanner(string: fileLine)
		scanner.charactersToBeSkipped = CharacterSet()
		
		
		if fileLine.first == "-" {
			var map = Map()
			var name: NSString?
			var level: NSString?
			if scanner.scanString("-", into: nil) &&
				scanner.scanUpTo(":", into: &name) &&
				scanner.scanString(": ", into: nil) &&
				scanner.scanUpTo("\n", into: &level)
			{
				map.name = name! as String
				map.level = level! as String
				maps.append(map)
				return
			}
			return
		}

		var header: NSString?
		var name: NSString?
		var game: Int = 0

		if scanner.scanUpTo(":", into: &header) {
			
			let h = header! as String
			
			switch h {
			case "DoomEdit Project File Version":
				return
			case "Name":
				if scanner.scanString(": ", into: nil) && scanner.scanUpTo("\n", into: &name) {
					doomProject.name = name! as String
					return
				}
			case "WAD":
				if scanner.scanString(": ", into: nil) && scanner.scanInt(&game) {
					doomProject.projectType = DoomProject.ProjectType(rawValue: game)
					return
				}
			case "Maps":
				return
			default:
				return
			}
		}
		return
	}
	
	
	
	// =======================
	// MARK: - Recent Projects
	// =======================

	/// Loads values in Defaults to `recentsProjects`
	func loadRecents() {
		
		var urls: [URL] = []
		let recents = UserDefaults.standard.object(forKey: "recentProjects") as! [String]?
		
		if let recents = recents {
			for string in recents {
				let url = URL(string: string)
				urls.append(url!)
			}
		}
		recentProjects = urls
	}
	
	/// Stores `recentProjects` in UserDefaults
	func saveRecents() {
		
		var paths: [String] = []
		
		if let recents = recentProjects {
			for url in recents {
				let path = url.absoluteString
				paths.append(path)
			}
		}
		UserDefaults.standard.set(paths, forKey: "recentProjects")
	}
	
	
	
	// =================================
	// MARK: - Progress Indicator Window
	// =================================

	/*
	func showProgressWindow() {
		
		let win = ProgressWindowController()
		win.showWindow(self)
		self.progressWindow = win
	}
	
	/// Updates the progress window's label, current progress indicator position, and max position.
	func updateProgressWindow(labelText: String, current: Int, max: Int) {

		guard let w = self.progressWindow else { return } // window must be open!

		w.label.stringValue = labelText
		w.progressBar.maxValue = Double(max)
		w.progressBar.increment(by: Double(current))
		w.progressBar.display()
	}
	
	func closeProgressWindow() {
		
		guard let progressWindow = self.progressWindow else { return }
		progressWindow.close()
		self.progressWindow = nil
	}
	*/
}
