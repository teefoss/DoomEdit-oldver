//
//  Data.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/9/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

let data = Data()

class Data {
	
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

	
	init() {
		loadThingNames()
		loadLineSpecials()
		
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

}
