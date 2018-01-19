//
//  Junk.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/18/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Foundation

/**
Stuff that didn't work, but save it just in case
*/

// From WadFile, patchToImage
/*
for i in 0..<width {
	
	var data = Int(patchInfo.columnOffset[i])
	
	repeat {
		let topdelta = patchData[data]
		data += 1
		if topdelta == 255 {
			break
		}
		var count = patchData[data]; data += 1
		var index = (Int(topdelta)*width+i)*4; data += 1
		while count != 0 {
			count -= 1
			let bytes = patchToRGB(patchData[data], palette: palette)
			dest.insert(contentsOf: bytes, at: index)
			index += width*4
		}
		data += 1
		
	} while true
}
*/
