//
//  NSWindowExtension.swift
//  DoomEdit
//
//  Created by Thomas Foster on 3/16/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

extension NSWindow {
	
	/// Converts the point to the screen coordinate system from the window’s coordinate system.
	func convertBaseToScreen(_ point: inout NSPoint) {
		var rect = NSRect()
		rect.origin = point
		rect = convertToScreen(rect)
		point = rect.origin
	}
}
