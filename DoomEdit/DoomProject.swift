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
	var projectType: ProjectType!
	var name: String = ""
	var directory: URL!
	var projectURL: URL!
	var projectMapsURL: URL!
	var projectFileURL: URL!
	var currentMapURL: URL {
		return projectMapsURL.appendingPathComponent(openMap.name)
	}
	
	var maps: [Map] = []
	var openMap = Map()
	
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
	
	func saveProject() {
		
		if !loaded {
			return
		}
		writeProjectFile(at: projectFileURL)
		projectDirty = false
	}
	
	func createProject() {
		
		let fm = FileManager.default
		
		let url = directory.appendingPathComponent(name, isDirectory: true)
		projectURL = url
		
		if !fm.fileExists(atPath: url.path) {
			do {
				try fm.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
			} catch {
				runAlertPanel(title: "Error!", message: "Could not create project directory.")
				return
			}
		}
		
		let mapurl = url.appendingPathComponent("maps", isDirectory: true)
		projectMapsURL = mapurl
		
		do {
			try fm.createDirectory(at: mapurl, withIntermediateDirectories: true, attributes: nil)
		} catch {
			fatalError("While creating project folder, could not create maps folder.")
		}
		
		let projectFile = url.appendingPathComponent(name, isDirectory: false)
		let projectFileFull = projectFile.appendingPathExtension("doomedit")
		projectFileURL = projectFileFull
		
		fm.createFile(atPath: projectFileFull.path, contents: nil, attributes: nil)
		
		writeProjectFile(at: projectFileFull)
		loadProject()
		
	}
	
	func loadProject() {
		
		switch projectType {
		case .doom1:
			let path = UserDefaults.standard.value(forKey: "DoomWADPath") as! String
			let url = URL(fileURLWithPath: path)
			wad.setWadLoation(url)
		case .doom2:
			let path = UserDefaults.standard.value(forKey: "Doom2WADPath") as! String
			let url = URL(fileURLWithPath: path)
			wad.setWadLoation(url)
		default:
			break
		}
		
		wad.loadAssets()
		
		let appDelegate = NSApplication.shared.delegate as! AppDelegate
		
		let proj = ProjectWindowController()		
		proj.showWindow(self)
		appDelegate.projectWindowController = proj
		
	}
	
	func openProject(from url: URL) {
		
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
		
		// load the maps data
		for m in 0..<maps.count {
			let url = projectMapsURL.appendingPathComponent(maps[m].name)
			do {
				try maps[m].dwd = String(contentsOf: url)
			} catch {
				print("Error! Could not load \(maps[m].name).dwd into project.")
			}
		}
		loadProject()
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
			readProject(fileLine: line)
		}
	}
	
	func readProject(fileLine: String) {
		
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
	
}
