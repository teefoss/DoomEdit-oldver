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
Storage Object for data not loaded from WAD: things, specials, etc.
Methods to reads data out of `.dsp` files.
*/

class DoomData {
	
	var lineSpecials: [LineSpecial] = []
	var thingDefs: [ThingDef] = []
	
	init() {
//		loadLineSpecials()
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
				thingDefs.append(t)
			}
		}
	}
	
	func loadLineSpecials(forResource fileName: String, ofType fileExtension: String) {
		
		var fileContents: String?		// to store the entire file
		if let filepath = Bundle.main.path(forResource: fileName, ofType: fileExtension) {
			do {
				fileContents = try String(contentsOfFile: filepath)
			} catch {
				print("Error, the file could not be loaded")
			}
		}
		
		guard let fileLines = fileContents?.components(separatedBy: .newlines) else { return }
		
		for fileLine in fileLines {
			var lineSpecial = LineSpecial()
			
			if readLineSpecial(from: fileLine, to: &lineSpecial) {
				lineSpecials.append(lineSpecial)
			}
		}
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
