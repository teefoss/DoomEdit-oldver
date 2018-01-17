//
//  WadFile.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/12/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

struct WadInfo {
	var identification: String		// should be IWAD
	var numLumps: Int
	var infoTableOffset: Int
}

struct LumpInfo {
	var offset: Int32
	var length: Int32
	var name: String
}

class WadFile {

	var lumps: [LumpInfo] = []
	let data: Data
	var numOfLumps: Int32 = 0
	var dirOffset: Int32 = 0
	
	var flats: [Flat] = []
	
	init() {
		let home = FileManager.default.homeDirectoryForCurrentUser
		let path = "Documents/Games/WADs/DOOM.WAD"
		let url = home.appendingPathComponent(path)
		do {
			data = try Data(contentsOf: url, options: .alwaysMapped)
		} catch {
			fatalError("Could not parse Wad file.")
		}
		readHeader()
		readDirectory()
		loadFlats()
	}
	
	func readHeader() {
		
		let headerSize = 12
		let numLumpsLoc = 4
		let dirOffsetLoc = 8
		let entrySize = 4
		
		// Make sure there's a full header
		if data.count < 12 {
			print("Error! Wad File is too small.")
			return
		}
		
		// Make sure it's an IWAD
		let iwad = "IWAD".data(using: String.Encoding.ascii)
		let wadType = data.subdata(in: 0..<entrySize)
	
		if wadType != iwad {
			print("Error! Wad is not an IWAD")
			return
		}
		
		numOfLumps = data.scan(offset: numLumpsLoc, length: entrySize)
		dirOffset = data.scan(offset: dirOffsetLoc, length: entrySize)
		
		if numOfLumps == 0 || dirOffset <= headerSize {
			print("Error! Empty Wad file.")
			return
		}
	}
	
	func readDirectory() {
		
		let entrySize = 16
		
		let directory = data.subdata(in: Int(dirOffset)..<Int(dirOffset)+Int(numOfLumps)*entrySize)
		
		for i in stride(from: 0, to: directory.count, by: entrySize) {
			
			let entry = directory.subdata(in: i..<i+entrySize)
			let lumpOffset: Int32 = entry.scan(offset: 0, length: 4)
			let lumpLength: Int32 = entry.scan(offset: 4, length: 4)

			let lumpNameData = entry.subdata(in: 8..<16)
			
			var lumpName: String = ""
			let name = lumpNameData.withUnsafeBytes({(pointer: UnsafePointer<CChar>) -> String? in
				var ptr = pointer
				for _ in 0..<8 {
					if ptr.pointee == CChar(0) {
						break
					}
					ptr = ptr.successor()
				}
				let position = pointer.distance(to: ptr)
				return String(data: lumpNameData.subdata(in: 0..<position), encoding: String.Encoding.ascii)
			})
			
			if let name = name {
				lumpName = name
			} else {
				print("Error! Could not parse lump name")
			}
			
			lumps.append(LumpInfo(offset: lumpOffset, length: lumpLength, name: lumpName))
		}
	}
	

	
	// ===================
	// MARK: - Lump Lookup
	// ===================
	
	func numLumps() -> Int {
		return lumps.count
	}

	func lumpSize(_ index: Int) -> Int {
		
		return Int(lumps[index].length)
	}
	
	/// Returns the offset of the lump in the WAD
	func lumpStart(_ index: Int) -> Int {
		
		return Int(lumps[index].offset)
	}
	
	/// Returns the lump name for a given index
	func lumpName(_ index: Int) -> String {
		
		return lumps[index].name
	}
	
	/// Returns the lump index for a given name.
	func lumpNamed(_ name: String) -> Int {
		
		for i in 0..<lumps.count {
			let inf = lumps[i]
			if inf.name.uppercased() == name.uppercased() {
				return i
			}
		}
		return -1
	}
	
	
	
	// ==================
	// MARK: Lump Loading
	// ==================

	/// Returns the raw data for lump at given index
	func loadLump(_ index: Int) -> Data {
		
		var inf: LumpInfo
		var buf: Data

		inf = lumps[index]
		
		buf = data.subdata(in: Int(inf.offset)..<Int(inf.offset)+Int(inf.length))
		return buf
	}
	
	/// Returns the raw data for lump of given name.
	func loadLump(named name: String) -> Data {
		
		return loadLump(lumpNamed(name))
	}
	
	
	func loadFlats() {
		
		var wadIndex = 0
		
		let palLBMlump = loadLump(named: "playpal")
		let palLBM: [CUnsignedChar] = palLBMlump.elements()
		
		repeat {
			
			let flatStart = lumpNamed("F\(wadIndex+1)_START") + 1
			let flatEnd = lumpNamed("F\(wadIndex+1)_END")
			
			if flatStart == -1 || flatEnd == -1 {
				if wadIndex == 0 {
					print("Error.")
				} else {
					wadIndex = -1
					continue
				}
			}
			
			for i in flatStart..<flatEnd {
				var fl = Flat()
				let flat = loadLump(i)
				let flatArray: [CUnsignedChar] = flat.elements()
				fl.imageFromWad = flatToImage(rawData: flatArray, pal: palLBM)!
				fl.name = lumpName(i)
				fl.index = flats.count
				flats.append(fl)
			}
			wadIndex += 1
			
		} while wadIndex >= 0
		
		for flat in flats {
			print(flat.index)
		}
		
	}
	
	/// Convert a flat's PLAYPAL index data to corresponding RGB values.
	func flatToRGB(_ flat: [CUnsignedChar], palette: [CUnsignedChar]) -> [CUnsignedChar] {

		var array: [CUnsignedChar] = []
		
		for i in 0..<flat.count {
			let paletteIndex = Int(flat[i])*3
			let r = palette[paletteIndex]
			let g = palette[paletteIndex+1]
			let b = palette[paletteIndex+2]
			array.append(r)
			array.append(g)
			array.append(b)
		}
				
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
	
	
	
	
	
	
}
