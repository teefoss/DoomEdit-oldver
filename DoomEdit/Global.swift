//
//  Constants.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/1/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

// File (testing)
let fileName = "e4m6"
let fileExt = "dwd"
let fullFileName = fileName + "." + fileExt

// Visual Sizes
let POINT_SIZE: CGFloat = 14
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

// Colors
let CLLT_BKG = NSColor.white
let CLDK_BKG = NSColor.black
let CLLT_LINE_ONESIDED = NSColor.black
let CLDK_LINE_ONESIDED = NSColor.yellow

// Other
let SIDE_BIT = 0x8000

enum Theme {
	case light
	case dark
}

fileprivate let theme: Theme = .light

// Color
struct Color {
	static let background = CLLT_BKG
	static let lineOneSided = CLLT_LINE_ONESIDED
	static let lineTwoSided = NSColor.gray
	static let lineSpecial = NSColor.green
}

func displayAlert(question: String, text: String) {
	let alert = NSAlert()
	alert.messageText = question
	alert.informativeText = text
	alert.alertStyle = .warning
	alert.addButton(withTitle: "OK")
	alert.addButton(withTitle: "Cancel")
	alert.runModal()
	//return alert.runModal() == .alertFirstButtonReturn
}




