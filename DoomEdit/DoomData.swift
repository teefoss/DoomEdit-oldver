//
//  Data.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/9/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

struct ThingDef {
	var type: Int = 0
	var name: String = ""
	var category: String = ""
	var size: Int = 0
	var game: Int = 0
	var spriteName: String = ""
	var image: NSImage? {
		for sprite in wad.sprites {
			if sprite.name == spriteName {
				return sprite.image
			}
		}
		return nil
	}
	var color: NSColor {
		switch category {
		case "Player": return .systemGreen
		case "Demon": return COLOR_MONSTER
		case "Power": return .systemBlue
		case "Ammo": return .systemOrange
		case "Health": return .systemYellow
		case "Armor": return .systemYellow
		case "Card": return .systemPurple
		case "Weapon": return .systemBrown
		case "Gore": return .darkGray
		case "Dead": return .darkGray
		case "Decor": return .lightGray
		case "Light": return .lightGray
		case "Other": return .systemPink
		default: return .systemPink
		}
	}
	var hasDirection: Bool {
		switch category {
		case "Player": return true
		case "Demon": return true
		case "Other": return true
		default: return false
		}
	}

}

	
	
let doomData = DoomData()

/**
Storage Object for data not loaded from WAD: things, specials, etc.
Methods to reads data out of `.dsp` files.
*/

class DoomData {
	
	var doom1Textures: [Texture] = []
	var doom1FlatNames: [String] = []
	var doom1Flats: [Flat] = []
	var doom1FlatImages: [NSImage] = []
	var doom1LineSpecials: [LineSpecial] = []
	
	var thingDefs: [ThingDef] = []
	
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
		loadLineSpecials()
		loadTextures()
		loadThingsDefs()
	}
	
	
	
	// =================================
	// MARK: - Initialize Storage Arrays
	// =================================
	
	func loadThingsDefs() {
		
		var fileContents: String?		// to store the entire file
		if let filepath = Bundle.main.path(forResource: "allthings", ofType: "txt") {
			do {
				fileContents = try String(contentsOfFile: filepath)
			} catch {
				print("Error, the file could not be loaded")
			}
		}
		guard let fileLines = fileContents?.components(separatedBy: CharacterSet.newlines) else { return }
			
		for fileLine in fileLines {
			var t = ThingDef()
			if readThingDef(from: fileLine, to: &t) {
//				if let img = wad.imageForLump(named: t.imageName) {
//					t.image = img
//				}
				thingDefs.append(t)
			}
		}
	}
	
	func loadLineSpecials() {
		
		var fileContents: String?		// to store the entire file
		if let filepath = Bundle.main.path(forResource: "linespecials", ofType: "doom1") {
			do {
				fileContents = try String(contentsOfFile: filepath)
			} catch {
				print("Error, the file could not be loaded")
			}
		}
		
		guard let fileLines = fileContents?.components(separatedBy: .newlines) else { return }
		
		for fileLine in fileLines {
//			var string: String = ""
//			var index: Int = 0
			
			var lineSpecial = LineSpecial()
			
			if readLineSpecial(from: fileLine, to: &lineSpecial) {
				doom1LineSpecials.append(lineSpecial)
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

	func readLineSpecial(from fileLine: String, to lineSpecial: inout LineSpecial) -> Bool {
		
		var type: NSString?
		var name: NSString?
		let scanner = Scanner(string: fileLine)
		scanner.charactersToBeSkipped = CharacterSet()
		
		if fileLine.first == "n" {
			return false
		} else if
			scanner.scanInt(&lineSpecial.index) &&
			scanner.scanString(":", into: nil) &&
			scanner.scanUpTo("_", into: &type) &&
			scanner.scanString("_", into: nil) &&
			scanner.scanUpTo("\n", into: &name)
		{
			lineSpecial.type = type! as String
			lineSpecial.name = name! as String
			return true
		}
		return false
	}
	
	func readThingDef(from fileLine: String, to def: inout ThingDef) -> Bool {
		
		var nsString: NSString?
		var catstring: NSString?
		var sprstring: NSString?
		let scanner = Scanner(string: fileLine)
		scanner.charactersToBeSkipped = CharacterSet()
				
		if fileLine.first == "%" {
			return false
		}
		
		if scanner.scanUpTo("_", into: &catstring) && scanner.scanString("_", into: nil) &&
			scanner.scanInt(&def.type) && scanner.scanString("_", into: nil) &&
			scanner.scanInt(&def.game) && scanner.scanString("_", into: nil) &&
			scanner.scanInt(&def.size) && scanner.scanString("_", into: nil) &&
			scanner.scanUpTo("_", into: &sprstring) && scanner.scanString("_", into: nil) &&
			scanner.scanUpTo("_", into: &nsString)
		{
			def.category = catstring! as String
			def.name = nsString! as String
			def.spriteName = sprstring! as String
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
	
	
}
