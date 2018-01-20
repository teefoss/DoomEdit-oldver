//
//  ImageFunctions.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/17/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa



/// Adds alpha to format [R,G,B,R,G,B...]. Nil values are transparent, all other colors are opaque.
func addAlpha(to data: [CUnsignedChar?]) -> [CUnsignedChar] {
	
	var newData: [CUnsignedChar] = []
	
	for i in stride(from: 0, to: data.count-1, by: 3) {
		
		if data[i] == nil && data[i+1] == nil && data[i+2] == nil {
			newData.append(0)
			newData.append(0)
			newData.append(0)
			newData.append(0)  // replace the nil values with black and 0 alpha.
		} else {
			newData.append(data[i]!)
			newData.append(data[i+1]!)
			newData.append(data[i+2]!)
			newData.append(255)  // just copy the colors and make opaque.
		}
	}
	return newData
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

/// Coverts raw 64x64 data to an NSImage without alpha
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

/// Converts raw patch data to an NSImage with alpha.
func patchToImage(_ patchData: [CUnsignedChar], patchInfo: PatchInfo, size: NSSize, palette: [CUnsignedChar]) -> NSImage? {
	
	var image: NSImageRep
	
	let width = Int(size.width)
	let height = Int(size.height)
	
	var dest: [CUnsignedChar?] = Array(repeating: nil, count: width*height*3)
	
	if width == 0 || height == 0 {
		print("Can't create an NSBitmapImage of \(size)! Width or height = 0.")
	}
	
	for i in 0..<width {
		
		var offset = Int(patchInfo.columnOffsets[i])	// offset from start of patchData
		
		repeat {
			
			let topdelta = patchData[offset]; offset += 1
			if topdelta == 255 {
				break
			}
			var count = patchData[offset]; offset += 1
			var index = (Int(topdelta)*width+i)*3
			offset += 1  // skip the top byte
			while count != 0 {
				count -= 1
				var colorIndex = Int(patchData[offset])
				dest[index] = palette[colorIndex*3]        // set red
				dest[index+1] = palette[(colorIndex*3)+1]  // set green
				dest[index+2] = palette[(colorIndex*3)+2]  // set blue
				offset += 1
				index += width*3
			}
			offset += 1  // skip the last byte
		} while true
	}
	
	let destAlpha = addAlpha(to: dest)
	
	var allocatedBytes = UnsafeMutableRawPointer.allocate(bytes: destAlpha.count, alignedTo: 1)
	var pointer: UnsafeMutablePointer? = allocatedBytes.bindMemory(to: UInt8.self, capacity: destAlpha.count)
	pointer?.initialize(to: 0, count: destAlpha.count)
	
	for i in 0..<destAlpha.count {
		pointer?.advanced(by: i).pointee = destAlpha[i]
	}
	
	let ptrptr: UnsafeMutablePointer<UnsafeMutablePointer<CUnsignedChar>?>? = UnsafeMutablePointer<UnsafeMutablePointer<CUnsignedChar>?>?(&pointer)
	
	defer {
		pointer?.deinitialize(count: dest.count)
		ptrptr?.deinitialize(count: dest.count)
	}
	
	image = NSBitmapImageRep(bitmapDataPlanes: ptrptr,
							 pixelsWide: width,
							 pixelsHigh: height,
							 bitsPerSample: 8,
							 samplesPerPixel: 4,
							 hasAlpha: true,
							 isPlanar: false,
							 colorSpaceName: .calibratedRGB,
							 bytesPerRow: width*4,
							 bitsPerPixel: 32)!
	
	
	let img = NSImage()
	img.addRepresentation(image)
	
	return img
}
