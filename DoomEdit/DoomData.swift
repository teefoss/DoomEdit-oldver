//
//  Data.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/9/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

let doomData = DoomData()

/**
Storage Object for all assets data.
Methods to reads all the data out of the `.dsp` files.
*/

class DoomData {
	
	var doom1Textures: [Texture] = []
	var doom1FlatNames: [String] = []
	var doom1Flats: [Flat] = []
	
	var things: [String] = []
	
	var lineSpecials: [String] = []
	
	var ceilingsSpecials: [String] = []
	var doorsSpecials: [String] = []
	var effectsSpecials: [String] = []
	var exitsSpecials: [String] = []
	var floorsSpecials: [String] = []
	var liftsSpecials: [String] = []
	var lightsSpecials: [String] = []
	var lockedDoorSpecials: [String] = []
	var stairsSpecials: [String] = []
	var teleportSpecials: [String] = []

	var doomThingMenu: [[String]] = [[]]
	
	var doom1Monsters: [String] = ["Zombieman",
								   "Shotgun Guy",
								   "Imp"]
	
	init() {
		loadThingNames()
		loadLineSpecials()
		loadTextures()
//		loadDoomThingMenu()
		
		/*
		for i in 0..<lineSpecials.count {
			switch i {
			case 1,2,3,4,16,29,31,42,46,50,61,63,75,76,86,90,103,105,106,107,108,109,110,111,112,113,114,115,116,117,118:
				ceilingsSpecials.append(lineSpecials[i])
			case 26,28,27,32,33,34,99,134,136,133,135,137:
				lockedDoorSpecials.append(lineSpecials[i])
				case
			}
		}
		*/
	}
	
	
	
	// =================================
	// MARK: - Initialize Storage Arrays
	// =================================
	func loadThingNames() {
		
		var fileContents: String?		// to store the entire file
		if let filepath = Bundle.main.path(forResource: "things", ofType: "dsp") {
			do {
				fileContents = try String(contentsOfFile: filepath)
			} catch {
				print("Error, the file could not be loaded")
			}
		}
		guard let fileLines = fileContents?.components(separatedBy: CharacterSet.newlines) else { return }
			
		for fileLine in fileLines {
			var string: String = ""
			if readThingName(from: fileLine, to: &string) {
				self.things.append(string)
			}
		}
	}
	
	func loadLineSpecials() {
		
		var fileContents: String?		// to store the entire file
		if let filepath = Bundle.main.path(forResource: "things", ofType: "dsp") {
			do {
				fileContents = try String(contentsOfFile: filepath)
			} catch {
				print("Error, the file could not be loaded")
			}
		}
		
		guard let fileLines = fileContents?.components(separatedBy: .newlines) else { return }
		
		for fileLine in fileLines {
			var string: String = ""
			var index: Int = 0
			if readLineSpecial(from: fileLine, to: &string, to: &index) {
				lineSpecials[index] = string
			}
		}

	}
	
	func loadTextures() {
		
		var texture1Contents: String?
		var texture2Contents: String?
		
		if let filepath1 = Bundle.main.path(forResource: "texture1", ofType: "dsp") {
			do {
				texture1Contents = try String(contentsOfFile: filepath1)
			} catch {
				print("Error, the file could not be loaded")
			}
		}
		
		if let filepath2 = Bundle.main.path(forResource: "texture2", ofType: "dsp") {
			do {
				texture2Contents = try String(contentsOfFile: filepath2)
			} catch {
				print("Error, the file could not be loaded")
			}
		}
		
		guard let tex1FileLines = texture1Contents?.components(separatedBy: .newlines) else { return }
		guard let tex2FileLines = texture2Contents?.components(separatedBy: .newlines) else { return }
		
		for fileLine in tex1FileLines {
			
			var texture = Texture()
			
			if readTextures(from: fileLine, name: &texture.name, width: &texture.width, height: &texture.height) {
				doom1Textures.append(texture)
			}
		}
		
		for fileLine in tex2FileLines {
			
			var texture = Texture()
			
			if readTextures(from: fileLine, name: &texture.name, width: &texture.width, height: &texture.height) {
				doom1Textures.append(texture)
			}
		}
		
		for i in 0..<doom1Textures.count {
			doom1Textures[i].index = i
		}

	}
	
	
	
	// ===================
	// MARK: - Information
	// ===================

	func indexForFlat(named name: String) -> Int {
		
		for flat in doom1Flats {
			if flat.name == name {
				return flat.index
			}
		}
		return -1
	}
	
	
	
	// ====================
	// MARK: - Data Reading
	// ====================

	func readLineSpecial(from fileLine: String, to string: inout String, to index: inout Int) -> Bool {
		
		var nsString: NSString?
		let scanner = Scanner(string: fileLine)
		scanner.charactersToBeSkipped = CharacterSet()
		
		if fileLine.first == "n" {
			return false
		} else if
			scanner.scanInt(&index) &&
			scanner.scanString(":", into: nil) &&
			scanner.scanUpTo("\n", into: &nsString)
		{
			string = nsString! as String
			return true
		}
		return false
	}
	
	func readThingName(from fileLine: String, to string: inout String) -> Bool {
		
		var nsString: NSString?
		let scanner = Scanner(string: fileLine)
		scanner.charactersToBeSkipped = CharacterSet()
		
		if fileLine.first == "n" {
			return false
		}
		if scanner.scanUpTo(" ", into: &nsString) {
			string = nsString! as String
			return true
		}
		return false
	}
	
	// Format:
	// AASTINKY 24, 72, 2
	func readTextures(from fileLine: String, name: inout String, width: inout Int, height: inout Int) -> Bool {
		
		var nsString: NSString?
		let scanner = Scanner(string: fileLine)
		scanner.charactersToBeSkipped = CharacterSet()

		if fileLine.first == " " {
			return false
		}
		if scanner.scanUpTo(" ", into: &nsString) &&
			scanner.scanString(" ", into: nil) &&
			scanner.scanInt(&width) &&
			scanner.scanString(", ", into: nil) &&
			scanner.scanInt(&height)
		{
			if nsString == "numtextures:" {
				return false
			} else {
				name = nsString! as String
				return true
			}
		}
		return false
	}
	
	
	
	
//	func loadDoomThingMenu() -> [[String]] {
//		var menu: [[String]]
//
//		var monsters = ["Zombieman",
//						"Shotgun Guy",
//						"Imp",
//						"Demon",
//						"Lost Soul",
//						"Cacodemon",
//						"Baron of Hell",
//						"Cyberdemon",
//						"Spider Mastermind"]
//
//		menu.append(monsters)
//	}

	
	
	
	
	
	
	
	
	
	
	
	
	
}
