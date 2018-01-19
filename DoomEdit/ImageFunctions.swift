//
//  ImageFunctions.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/17/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa


struct RGB {
	
	var red: UInt8
	var green: UInt8
	var blue: UInt8
	
	init(red: UInt8, green: UInt8, blue: UInt8) {
		self.red = red
		self.green = green
		self.blue = blue
	}
}

struct Palette {
	var colors: [RGB]	
}

/// Convert a flat's PLAYPAL index data to corresponding RGB values without alpha.
func flatToRGB(_ flat: [CUnsignedChar], palette: [CUnsignedChar]) -> [CUnsignedChar] {
	
	var array: [CUnsignedChar] = []
	
	for i in 0..<flat.count {
		let paletteIndex = Int(flat[i])*3
		let r = palette[paletteIndex]
		let g = palette[paletteIndex+1]
		let b = palette[paletteIndex+2]
		array.append(r); array.append(g); array.append(b)
	}
	return array
}

/// Convert a patch's PLAYPAL index data to corresponding RGB with alpha.
func patchToRGB (_ data: CUnsignedChar, palette: [CUnsignedChar]) -> [CUnsignedChar] {
	
	var array: [CUnsignedChar] = []
	
	let paletteIndex = Int(data)*4
	let r = palette[paletteIndex]
	let g = palette[paletteIndex+1]
	let b = palette[paletteIndex+2]
	array.append(r); array.append(g); array.append(b)

	return array
}

/// Convert PLAYPAL to 16-bit. (DoomEd original)
func LBMPaletteTo16(_ lbmpal: [CUnsignedChar], _ pal: inout [CUnsignedShort]) {
	
	var p: Int = 0
	
	for i in 0..<256 {
		
		let r = lbmpal[p]>>4; p += 1
		let g = lbmpal[p]>>4; p += 1
		let b = lbmpal[p]>>4; p += 1
		let shiftR = r<<12
		let shiftG = g<<8
		let shiftB = b<<4
		let sum = UInt16(shiftR + shiftG + shiftB + 15)
		pal[i] = NSSwapBigShortToHost(sum)
	}
}

/// Coverts raw 64x64 data to an NSImage
func flatToImage(rawData: [CUnsignedChar], pal: [CUnsignedChar]) -> NSImage? {
	var dest: [CUnsignedChar] = []
	var image: NSImageRep
	
	dest = flatToRGB(rawData, palette: pal)
	
	// Convert array to raw data
	// let imgData = Data(buffer: UnsafeBufferPointer(start: dest, count: dest.count))
	
	var allocatedBytes = UnsafeMutableRawPointer.allocate(bytes: dest.count, alignedTo: 1)
	
	var pointer: UnsafeMutablePointer? = allocatedBytes.bindMemory(to: UInt8.self, capacity: dest.count)
	pointer?.initialize(to: 0, count: dest.count)
	
	for i in 0..<dest.count {
		pointer?.advanced(by: i).pointee = dest[i]
	}
	
	let ptrptr: UnsafeMutablePointer<UnsafeMutablePointer<CUnsignedChar>?>? = UnsafeMutablePointer<UnsafeMutablePointer<CUnsignedChar>?>?(&pointer)
	
	defer {
		pointer?.deinitialize(count: dest.count)
		ptrptr?.deinitialize(count: dest.count)
	}
	
	image = NSBitmapImageRep(
		bitmapDataPlanes: ptrptr,
		pixelsWide: 64,
		pixelsHigh: 64,
		bitsPerSample: 8,
		samplesPerPixel: 3,
		hasAlpha: false,
		isPlanar: false,
		colorSpaceName: .calibratedRGB,
		bytesPerRow: (64*3),
		bitsPerPixel: 24)!
	
	let img = NSImage()
	img.addRepresentation(image)
	
	return img
}
