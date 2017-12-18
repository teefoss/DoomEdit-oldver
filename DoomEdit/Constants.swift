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

// Visual
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

// Color
struct Color {
	static let lineOneSided = NSColor.black
	static let lineTwoSided = NSColor.gray
	static let lineSpecial = NSColor.green
}
