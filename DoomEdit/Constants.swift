//
//  Constants.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/1/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

let fileName = "e1m1"
let fileExt = "dwd"
let fullFileName = fileName + "." + fileExt

let POINT_SIZE: CGFloat = 14
let POINT_DRAW_SIZE = 4

let THING_DRAW_SIZE = 32

let LINE_WIDTH: CGFloat = 1.0
let LINE_NORMAL_LENGTH = 6

let SELECTION_BOX_WIDTH: CGFloat = 4.0

struct Color {
	static let lineOneSided = NSColor.black
	static let lineTwoSided = NSColor.gray
	static let lineSpecial = NSColor.green
}
