//
//  Constants.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/1/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

// File (testing)
let fileName = "e1m1"
let fileExt = "dwd"
let fullFileName = fileName + "." + fileExt

// Visual Sizes
let POINT_SELECT_SIZE: CGFloat = 14 // Area around point for detecting click
let POINT_DRAW_SIZE = 4
let THING_DRAW_SIZE = 32
let LINE_WIDTH: CGFloat = 1.0
let LINE_NORMAL_LENGTH = 6
let SELECTION_BOX_WIDTH: CGFloat = 4.0

// Keys
let KEY_MINUS: 			UInt16 = 27
let KEY_EQUALS: 		UInt16 = 24
let KEY_LEFTBRACKET: 	UInt16 = 33
let KEY_RIGHTBRACKET: 	UInt16 = 30
let KEY_I: 				UInt16 = 34
let KEY_SPACE:			UInt16 = 49
let KEY_1:				UInt16 = 18
let KEY_F:				UInt16 = 3
let KEY_S:				UInt16 = 1
let KEY_DELETE:			UInt16 = 51
let KEY_L:				UInt16 = 37

// Colors
var COLOR_BKG = NSColor.white
var COLOR_LINE_ONESIDED = NSColor.black
let COLOR_LINE_TWOSIDED = NSColor.gray
var COLOR_MONSTER = NSColor.black
var COLOR_THINGINFO = NSColor.white
var COLOR_GRID = NSColor.systemBlue
var COLOR_TILE = NSColor.systemBlue
var COLOR_HELP = NSColor(calibratedRed: 255, green: 212, blue: 121, alpha: 1.0)

// Other
let SIDE_BIT = 0x8000

var THEME: Theme = .light

enum Theme {
	case light
	case dark
}

// Color

struct Color {
	static let lineTwoSided = NSColor.lightGray
	static let lineSpecial = NSColor.green
	static let textColor: NSColor = (THEME == .light) ? .black : .white
}

struct Settings {
	static let knobStyle: NSScroller.KnobStyle = (THEME == .light) ? .dark : .light
}



// ========================
// MARK: - Global Functions
// ========================

/// Turns 8 bytes of data into a string.
func makeString(from data: Data) -> String? {
	
	let string = data.withUnsafeBytes({(pointer: UnsafePointer<CChar>) -> String? in
		var ptr = pointer
		for _ in 0..<8 {
			if ptr.pointee == CChar(0) {
				break
			}
			ptr = ptr.successor()
		}
		let position = pointer.distance(to: ptr)
		return String(data: data.subdata(in: 0..<position), encoding: String.Encoding.ascii)
	})
	return string
}

func runAlertPanel(title: String, message: String) {

	let alert = NSAlert()
	alert.messageText = title
	alert.informativeText = message
	alert.alertStyle = .warning
	alert.addButton(withTitle: "OK")
	alert.runModal()
}

func runDialogPanel(question: String, text: String) -> Bool {

	let alert = NSAlert()
	alert.messageText = question
	alert.informativeText = text
	alert.alertStyle = .warning
	alert.addButton(withTitle: "Yes")
	alert.addButton(withTitle: "No")
	return alert.runModal() == .alertFirstButtonReturn
}

func hasMultiple<T: Equatable>(array: [T]) -> Bool {
	
	let first = array.first
	for element in array {
		if element != first {
			return true
		}
	}
	return false
}

func buttonState(for bool: Bool) -> NSButton.StateValue {
	
	return bool ? .on : .off
}

/// Converts "E1M1" to "1 1" or "MAP01" to "1"
/// Don't pass in string with extension
func convertDoomMapToArg(mapname: String) -> (String, String)? {
	
	var episode: Int = 0
	var mission: Int = 0
	let upper = mapname.uppercased()
	let scanner = Scanner(string: upper)
	
		if scanner.scanString("E", into: nil) && scanner.scanInt(&episode) &&
			scanner.scanString("M", into: nil) && scanner.scanInt(&mission)
		{
			let ep = String(episode)
			let m = String(mission)
			return (ep, m)
		}
	
	print("Error. convertMapToArg")
	return nil
}

func convertDoom2MapToArg(mapname: String) -> String? {
	
	let upper = mapname.uppercased()
	let scanner = Scanner(string: upper)
	var mission = 0
	
	if scanner.scanString("MAP", into: nil) && scanner.scanInt(&mission) {
		return String(mission)
	}
	print("Error. convertDoom2MapToArg")
	return nil
}



