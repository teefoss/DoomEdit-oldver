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

struct TextureLumpInfo {
	var numTextures: Int32 = 0
	var offsets: [Int32] = []
}



// ===============
// MARK: - WadFile
// ===============

let wad = WadFile()

class WadFile {
	
	var lumps: [LumpInfo] = []
	let data: Data
	var numOfLumps: Int32 = 0
	var dirOffset: Int32 = 0
	
	var flats: [Flat] = []
	var pnames: [String] = []
	var patches: [Patch] = []
	var maptextures: [MapTexture] = []
	//var textures: [Texture] = []

	var progressWindow: ProgressWindowController?
	
	/* Testing
	let patchwin = PatchWindow()
	patchwin.showWindow(self)
	self.patchWindow = patchwin
	*/

	
	init() {
		let home = FileManager.default.homeDirectoryForCurrentUser
		let path = "Documents/Games/WADs/DOOM.WAD"
		let url = home.appendingPathComponent(path)
		do {
			data = try Data(contentsOf: url, options: .alwaysMapped)
		} catch {
			fatalError("Could not parse Wad file. To test, put DOOM.WAD in ~/Documents/Games/WADs")
		}
		
		// TODO: learn how to do a loading window
		
		let progressWin = ProgressWindowController()
		progressWin.window?.title = "Loading WAD"
		progressWin.showWindow(self)

		progressWin.progressBar.increment(by: 25.0)
		progressWin.label.stringValue = "Reading WAD directory…"
		readHeader()
		readDirectory()
		
		progressWin.progressBar.increment(by: 25.0)
		progressWin.label.stringValue = "Loading Flats…"
		loadFlats()
		
		progressWin.progressBar.increment(by: 25.0)
		progressWin.label.stringValue = "Loading Patches…"

		loadPNAMES()
		loadPatches()
		
		progressWin.progressBar.increment(by: 25.0)
		progressWin.label.stringValue = "Loading Textures…"
		loadTextures()
		
		progressWin.close()
	}
	
	
	
	// ===================
	// MARK: - Wad Parsing
	// ===================
	
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
	
	func readTexture(at offset: CInt, in lump: Int) -> MapTexture {

		let i = Int(offset)
		let lump = loadLump(lump)
		var tex = MapTexture()
		
		let nameData = lump.subdata(in: i..<i+8)
		if let name = makeString(from: nameData) {
			tex.name = name
		} else {
			tex.name = "Whoops!"
			print("could not parse wad for texture name!")
		}
		tex.width = lump.scan(offset: i+12, length: 2)
		tex.height = lump.scan(offset: i+14, length: 2)
		tex.patchcount = lump.scan(offset: i+20, length: 2)
		
		for j in 0..<Int(tex.patchcount) {
			let patchData = lump.subdata(in: (i+22)+(j*10)..<(i+22)+(j*10)+10)
			let patch = readPatch(from: patchData)
			tex.patches.append(patch)
		}
		return tex
	}
	
	func readPatch(from data: Data) -> MapPatch {
		
		var patch = MapPatch()
		
		patch.originx = data.scan(offset: 0, length: 2)
		patch.originy = data.scan(offset: 2, length: 2)
		patch.patchIndex = data.scan(offset: 4, length: 2)
		patch.name = self.pnames[Int(patch.patchIndex)]
		
		return patch
	}

	func readTextureHeader(of lump: Int) -> TextureLumpInfo {
		
		var info = TextureLumpInfo()
		let lump = loadLump(lump)
		
		info.numTextures = lump.scan(offset: 0, length: 4)
		
		for i in 0..<Int(info.numTextures) {
			let offset: Int32 = lump.scan(offset: 4+(i*4), length: 4)
			info.offsets.append(offset)
		}
		
		return info
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
		
		return info
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
	
	
	
	// ====================
	// MARK: - Lump Loading
	// ====================
	
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
	
	func loadTextures() {
		
		var wadIndex = 0
		repeat {

			let textureLumpIndex = lumpNamed("TEXTURE\(wadIndex+1)")
			if textureLumpIndex == -1 {
				if wadIndex == 0 {
					print("Error! You've got a WAD problem.")
				}
				wadIndex = -1
				continue
			}
			let info = readTextureHeader(of: textureLumpIndex)
						
			for i in 0..<Int(info.numTextures) {
				let tex = readTexture(at: info.offsets[i], in: textureLumpIndex)
				maptextures.append(tex)
			}
			wadIndex += 1
		} while wadIndex >= 0
	}
	
	func loadPNAMES() {
		
		let pnames = lumpNamed("PNAMES")
		
		if pnames == -1 {
			print("Error parsing pnames lump!")
		}
		let lump = loadLump(pnames)
		let numPatches: Int32 = lump.scan(offset: 0, length: 4)
		for i in 0..<Int(numPatches) {
			let nameData = lump.subdata(in: 4+(i*8)..<4+(i*8)+8)
			let name = makeString(from: nameData)
			if let name = name {
				self.pnames.append(name)
			} else {
				print("Could not get name from pnames data!")
			}
		}
	}
	
	
	
}
