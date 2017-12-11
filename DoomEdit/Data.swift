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
	
	init() {
		loadThingNames()
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
