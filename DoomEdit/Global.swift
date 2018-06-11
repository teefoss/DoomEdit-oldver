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


// Constant Colors
struct Color {
	static let lineTwoSided = NSColor.lightGray
	static let lineSpecial = NSColor.green
	static let helpWindow = NSColor(calibratedRed: 255, green: 212, blue: 121, alpha: 1.0)
}

struct Settings {
	static var knobStyle: NSScroller.KnobStyle = (currentStyle.index == 1) ? .dark : .light
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



/**
Adds a line to a preexisting NSBezierPath
Does not stroke
*/
func addLineToPath(_ path: NSBezierPath,
			 _ x1: Int, _ y1: Int,
			 _ x2: Int, _ y2: Int) {
	
	path.move(to: NSPoint(x: x1, y: y1))
	path.line(to: NSPoint(x: x2, y: y2))
}



