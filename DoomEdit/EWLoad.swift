//
//  WorldLoad.swift
//  DoomEdit
//
//  Created by Thomas Foster on 11/29/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Foundation

/**
Handle loading a map from a .DWD file.
*/

extension EditWorld {
	
	// TODO: stores thing data in things
	/// Reads data from a `.dwd` file and stores all line and thing data
	func loadDWDFile(_ dwd: String) {
		
		let fileLines = dwd.components(separatedBy: CharacterSet.newlines)
		
		var line = Line()
		var p1 = NSPoint()
		var p2 = NSPoint()
		var side = Side()
		var sectorDef = SectorDef()
		var thing = Thing()

		var gotFrontSide = false
		var gotFrontSectorDef = false
		var isTwoSided = false
		var finishedReadingLine = false
		var gotThing = false
		
		for fileLine in fileLines {
			
			if readLineData(from: fileLine, to: &line, p1: &p1, p2: &p2) {
				if line.flags&TWO_SIDED == TWO_SIDED {
					isTwoSided = true
				}
			} else if readSideData(from: fileLine, to: &side) {
				switch isTwoSided {
				case true:
					if !gotFrontSide {
						line.side[0] = side
						gotFrontSide = true
					} else {
						line.side[1] = side
					}
				case false:
					line.side[0] = side
				}
			} else if readSectorData(from: fileLine, to: &sectorDef) {
				switch isTwoSided {
				case true:
					if !gotFrontSectorDef {
						line.side[0]?.ends = sectorDef
						gotFrontSectorDef = true
					} else {
						line.side[1]?.ends = sectorDef
						finishedReadingLine = true
					}
				case false:
					line.side[0]?.ends = sectorDef
					finishedReadingLine = true
				}
			} else if readThingData(from: fileLine, to: &thing) {
				gotThing = true
			} else {
				continue
			}
			
			if finishedReadingLine {
				newLine(line: &line, from: p1, to: p2)
				line = Line()
				finishedReadingLine = false
				isTwoSided = false
				gotFrontSide = false
				gotFrontSectorDef = false
			}
			if gotThing {
				newThing(thing)
				thing = Thing()
				gotThing = false
			}
		}
	}
	
	

	
	
	
	func readLineData(from fileLine: String, to line: inout Line, p1: inout NSPoint, p2: inout NSPoint) -> Bool {
		
		let scanner = Scanner(string: fileLine)
		scanner.charactersToBeSkipped = CharacterSet()
		
		var p1x = 0
		var p1y = 0
		var p2x = 0
		var p2y = 0
		
		if !(scanner.scanString("(", into: nil) &&
			scanner.scanInt(&p1x) && scanner.scanString(",", into: nil) &&
			scanner.scanInt(&p1y) && scanner.scanString(") to (", into: nil) &&
			scanner.scanInt(&p2x) && scanner.scanString(",", into: nil) &&
			scanner.scanInt(&p2y) && scanner.scanString(") : ", into: nil) &&
			scanner.scanInt(&line.flags) && scanner.scanString(" : ", into: nil) &&
			scanner.scanInt(&line.special) && scanner.scanString(" : ", into: nil) &&
			scanner.scanInt(&line.tag))
		{
			return false
		} else {
			p1.x = CGFloat(p1x)
			p1.y = CGFloat(p1y)
			p2.x = CGFloat(p2x)
			p2.y = CGFloat(p2y)
		}
		return true
	}
	
	
	func readSideData(from fileLine: String, to side: inout Side) -> Bool {
		
		// FORMAT
		// "    yOffset (xOffset : UPPERTEX / LOWERTEX / MIDTEX )"
		
		let scanner = Scanner(string: fileLine)
		scanner.charactersToBeSkipped = CharacterSet()
		
		var upper: NSString?
		var lower: NSString?
		var middle: NSString?

		if !(scanner.scanString("    ", into: nil) &&
			scanner.scanInt(&side.y_offset) && scanner.scanString(" (", into: nil) &&
			scanner.scanInt(&side.x_offset) && scanner.scanString(" : ", into: nil) &&
			scanner.scanUpTo(" ", into: &upper) && scanner.scanString(" / ", into: nil) &&
			scanner.scanUpTo(" ", into: &lower) && scanner.scanString(" / ", into: nil) &&
			scanner.scanUpTo(" ", into: &middle) && scanner.scanString(" )", into: nil))
		{
			return false
		} else {
			side.upperTexture = upper! as String
			side.lowerTexture = lower! as String
			side.middleTexture = middle! as String
		}
		return true
	}
	

	
	func readSectorData(from fileLine: String, to sectorDef: inout SectorDef) -> Bool {
		
		// FORMAT
		// "    floorHt : FLRFLAT ceilingHt : CEILFLAT lightLevel special tag"

		let scanner = Scanner(string: fileLine)
		scanner.charactersToBeSkipped = CharacterSet()
		
		var flr: NSString?
		var ceil: NSString?

		if !(scanner.scanString("    ", into: nil) &&
			scanner.scanInt(&sectorDef.floorHeight) && scanner.scanString(" : ", into: nil) &&
			scanner.scanUpTo(" ", into: &flr) && scanner.scanString(" ", into: nil) &&
			scanner.scanInt(&sectorDef.ceilingHeight) && scanner.scanString(" : ", into: nil) &&
			scanner.scanUpTo(" ", into: &ceil) && scanner.scanString(" ", into: nil) &&
			scanner.scanInt(&sectorDef.lightLevel) && scanner.scanString(" ", into: nil) &&
			scanner.scanInt(&sectorDef.special) && scanner.scanString(" ", into: nil) &&
			scanner.scanInt(&sectorDef.tag))
		{
			return false
		} else {
			sectorDef.floorFlat = flr! as String
			sectorDef.ceilingFlat = ceil! as String
		}
		return true

	}
	
	func readThingData(from fileLine: String, to thing: inout Thing) -> Bool {
		
		// FORMAT
		// (1056,-3616, 90) :1, 7
		// (x,y, angle) :type, flags

		let scanner = Scanner(string: fileLine)
		scanner.charactersToBeSkipped = CharacterSet()
		
		var x = 0
		var y = 0

		if !(scanner.scanString("(", into: nil) &&
			scanner.scanInt(&x) && scanner.scanString(",", into: nil) &&
			scanner.scanInt(&y) && scanner.scanString(", ", into: nil) &&
			scanner.scanInt(&thing.angle) && scanner.scanString(") :", into: nil) &&
			scanner.scanInt(&thing.type) && scanner.scanString(", ", into: nil) &&
			scanner.scanInt(&thing.options))
		{
			return false
		} else {
			thing.origin.x = CGFloat(x)
			thing.origin.y = CGFloat(y)
		}
		return true
	}
	
	
	
	
	
	
}
