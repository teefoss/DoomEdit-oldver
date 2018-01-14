//
//  WadFile.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/12/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Foundation

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
	var numLumps: Int32 = 0
	var dirOffset: Int32 = 0
	
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
		loadFlatNames()
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
		
		numLumps = data.scan(offset: numLumpsLoc, length: entrySize)
		dirOffset = data.scan(offset: dirOffsetLoc, length: entrySize)
		
		if numLumps == 0 || dirOffset <= headerSize {
			print("Error! Empty Wad file.")
			return
		}
	}
	
	func readDirectory() {
		
		let entrySize = 16
		
		let directory = data.subdata(in: Int(dirOffset)..<Int(dirOffset)+Int(numLumps)*entrySize)
		
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
	
	func loadLump(lump: Int) {
		
		var lump: LumpInfo
		var data: Data
		
	}
	
	func loadFlatNames() {
		
		var beginFlats: Bool = false
		var i: Int = 0
	
		for lump in lumps {
			if lump.name == "F1_START" || lump.name == "F1_END" || lump.name == "F2_START" || lump.name == "F2_END" {
				continue
			}
			if lump.name == "F_START" {
				beginFlats = true
				continue
			}
			if lump.name == "F_END" {
				break
			}
			if beginFlats {
				var newFlat = Flat(name: lump.name, index: i)
				doomData.doom1Flats.append(newFlat)
				i = i+1
			}
		}
	}
	
	
	func loadFlats() {
		
		var flatStart: Int
		var flatEnd: Int
		var shortPal: CUnsignedShort
		var palLBM: Data
		var flatData: Data
		var flat: Flat
		
		// Get the palette and convert to 16-bit
		
		
		
	}
	
	
	
	
	
	
	
	
	
	
	
}
