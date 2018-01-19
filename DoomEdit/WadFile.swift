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

struct PatchInfo {
	var width: UInt16 = 0
	var height: UInt16 = 0
	var xoffset: Int16 = 0
	var yoffset: Int16 = 0
	var imageDataLoc: Int {
		return 8+(4*Int(width))
	}
	var columnOffsets: [UInt32] = []
	var numPixels: [UInt8] = []
	var imageData: [CUnsignedChar] = []
}

class WadFile {
	
	var lumps: [LumpInfo] = []
	let data: Data
	var numOfLumps: Int32 = 0
	var dirOffset: Int32 = 0
	
	var flats: [Flat] = []
	var patches: [Patch] = []
	
	init() {
		let home = FileManager.default.homeDirectoryForCurrentUser
		let path = "Documents/Games/WADs/DOOM.WAD"
		let url = home.appendingPathComponent(path)
		do {
			data = try Data(contentsOf: url, options: .alwaysMapped)
		} catch {
			fatalError("Could not parse Wad file. To test, put DOOM.WAD in ~/Documents/Games/WADs")
		}
		readHeader()
		readDirectory()
		loadFlats()
		loadPatches()
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
	
	
	
	// ===================
	// MARK: - Load Assets
	// ===================
	
	func loadFlats() {
		
		var wadIndex = 0
		
		let palLBMlump = loadLump(named: "playpal")
		let palLBM: [CUnsignedChar] = palLBMlump.elements()
		
		repeat {
			
			let flatStart = lumpNamed("F\(wadIndex+1)_START") + 1
			let flatEnd = lumpNamed("F\(wadIndex+1)_END")
			
			if flatStart == -1 || flatEnd == -1 {
				if wadIndex == 0 {
					print("Error! You've got a WAD problem.")
				} else {
					wadIndex = -1
					continue
				}
			}
			
			for i in flatStart..<flatEnd {
				var fl = Flat()
				let flat = loadLump(i)
				let flatArray: [CUnsignedChar] = flat.elements()
				fl.image = flatToImage(rawData: flatArray, pal: palLBM)!
				fl.name = lumpName(i)
				fl.index = flats.count
				flats.append(fl)
			}
			wadIndex += 1
			
		} while wadIndex >= 0
	}
	
	func loadPatches() {
		
		let pnames = loadLump(named: "pnames")
		let playpal = loadLump(named: "playpal")
		let palette: [CUnsignedChar] = playpal.elements()
		
		// TODO: Handle load playpal lump error
		
		var wadIndex = 0
		
		repeat {
			
			let patchStart = lumpNamed("P\(wadIndex+1)_START") + 1
			let patchEnd = lumpNamed("P\(wadIndex+1)_END")
			
			if patchStart == -1 || patchEnd == -1 {
				if wadIndex == 0 {
					print("Error! You've got a WAD problem.")
				}
				wadIndex = -1
				continue
			}
			
			for i in patchStart..<patchEnd {
				
				let patch = loadLump(i)
				let patchData: [CUnsignedChar] = patch.elements()
				var p = Patch()
				let info = readImageHeader(for: i)
				p.name = lumpName(i)
				p.size.width = CGFloat(info.width)
				p.size.height = CGFloat(info.height)
				p.image = patchToImage(patchData, patchInfo: info, size: p.size, palette: palette)!
				patches.append(p)
			}
			wadIndex += 1
		} while wadIndex >= 0
	}
	
	func patchToImage(_ patchData: [CUnsignedChar], patchInfo: PatchInfo, size: NSSize, palette: [CUnsignedChar]) -> NSImage? {
		
		var image: NSImageRep
		
		let width = Int(size.width)
		let height = Int(size.height)
		
		var dest: [CUnsignedChar] = Array(repeating: 0, count: width*height*3)
		
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
		
		image = NSBitmapImageRep(bitmapDataPlanes: ptrptr,
								 pixelsWide: width,
								 pixelsHigh: height,
								 bitsPerSample: 8,
								 samplesPerPixel: 3,
								 hasAlpha: false,
								 isPlanar: false,
								 colorSpaceName: .calibratedRGB,
								 bytesPerRow: width*3,
								 bitsPerPixel: 24)!
		
		
		let img = NSImage()
		img.addRepresentation(image)
		
		return img
	}
	
	func addAlpha(to data: inout [CUnsignedChar]) {
		
		var otherData = data
		let rgbs = data.count/3
		
		for i in 0..<rgbs {
			if data[i*3] == 0 && data[i*3+1] == 0 && data[i*3+2] == 0 {
				otherData.insert(0, at: i*3+3)
			} else {
				otherData.insert(1, at: i*3+3)
			}
		}
		data = otherData
	}

	
	func columnDataToRGB(_ patchData: [CUnsignedChar], columnOffset: UInt32, palette: [CUnsignedChar]) -> [CUnsignedChar] {
		
		let offset = Int(columnOffset)
		var colArray: [CUnsignedChar] = []
		
		let numPixels = patchData[offset+1]
		
		let pixelStartIndex = offset+3		// skip the first byte
		let pixelEndIndex = offset+Int(numPixels)
		
		for j in pixelStartIndex..<pixelEndIndex {
			colArray.append(contentsOf: patchToRGB(patchData[j], palette: palette))
		}
		return colArray
	}
	
	func readImageHeader(for lump: Int) -> PatchInfo {
		
		var info = PatchInfo()
		let lump = loadLump(lump)
		
		
		info.width = lump.scan(offset: 0, length: 2)
		info.height = lump.scan(offset: 2, length: 2)
		info.xoffset = lump.scan(offset: 4, length: 2)
		info.yoffset = lump.scan(offset: 6, length: 2)
		
		for i in 0..<Int(info.width) {
			info.columnOffsets.append(lump.scan(offset: 8+(i*4), length: 4))
		}
		
		let imgDataSize = lump.count - info.imageDataLoc
		
		let imgData = lump.subdata(in: info.imageDataLoc..<info.imageDataLoc+imgDataSize)
		info.imageData = imgData.elements()
		
		return info
	}
	
	
	
}
