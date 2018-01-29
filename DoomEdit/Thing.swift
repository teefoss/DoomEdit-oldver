//
//  Thing.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/2/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

// Flags

let SKILL_EASY = 1
let SKILL_NORMAL = 2
let SKILL_HARD = 4
let AMBUSH = 8
let NETWORK = 16

struct Thing {
	
	var selected: Int = 0

	var origin = NSPoint()
	var angle: Int = 0
	var type: Int = 0
	var options: Int = 0
	var def: ThingDef {
		for def in doomData.thingDefs {
			if def.type == type {
				return def
			}
		}
		return ThingDef()
	}
}
