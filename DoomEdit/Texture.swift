//
//  Texture.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/19/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

// DoomEd Patch and Texture Structs

/**

patch_t				data from wad
apatch_t			struct for loaded patches
mappatch_t			orients a patch inside a maptexture_t
texpatch_t			contains patch info, the loaded patch, and properties related to texture editor
worldpatch_t

maptexture_t		describes a rectangular texture, which is composed of one or mote mappatch_t that arrange graphic patches
worldtexture_t

*/



// ===============
// MARK: - Patches
// ===============

struct Patch {
	var rect = NSRect()
	var size = NSSize()
	var name: String = ""
	var image = NSImage()
	var WADindex: Int = 0
}

struct PatchInfo {
	var name: String = ""
	var width: UInt16 = 0
	var height: UInt16 = 0
	var xoffset: Int16 = 0
	var yoffset: Int16 = 0
	var columnOffsets: [UInt32] = []
}


struct TexPatch {
	var rect = NSRect()
	var patch = Patch()
	var info = MapPatch()
}

struct MapTexture {
	var name: String = ""
	var masked: Bool = false
	var width: CUnsignedShort = 0
	var height: CUnsignedShort = 0
	var columndirectory: CInt = 0
	var patchcount: CChar = 0
	var patches: [MapPatch] = []
}

struct MapPatch {
	var originx: CShort = 0
	var originy: CShort = 0
	var patchIndex: CShort = 0
	var name: String = ""
}


// ================
// MARK: - Textures
// ================

struct Texture {
	var WADindex: Int = 0
	var name: String = ""
	var width: Int = 0
	var height: Int = 0
	var index: Int = 0
	var selected: Bool = false
	var image = NSImage()
	var patchCount: Int = 0
	var rect = NSRect()
}

