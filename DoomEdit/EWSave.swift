//
//  EWSave.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/22/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Foundation

/**
Handle saving a map to a .DWD file.
*/

fileprivate let outputFile = "fucked2.dwd"
fileprivate let home = FileManager.default.homeDirectoryForCurrentUser

extension EditWorld {
	
	func saveMap(sender: Any?) {
		
		if !loaded {
			runAlertPanel(title: "Error!", message: "No map open.")
			return
		}
		
		saveDWD()
		doomProject.saveProject()
		
		dirty = false
	}
	
	func saveDWD() {
		
		let dwd = makeDWD()
		
		do {
			try dwd.write(to: doomProject.currentMapURL!, atomically: false, encoding: .ascii)
		} catch {
			print("Error. Could not save map as dwd at path \(doomProject.currentMapURL?.path ?? "")!")
		}
	}

	private func makeDWD() -> String {
		
		var dwd: String = ""
		
		dwd.append("WorldServer version 4\n\n")
		dwd.append("lines:\(lines.count)\n")
		
		for i in 0..<lines.count {
			
			let x1 = Int(points[lines[i].pt1].coord.x)
			let y1 = Int(points[lines[i].pt1].coord.y)
			let x2 = Int(points[lines[i].pt2].coord.x)
			let y2 = Int(points[lines[i].pt2].coord.y)

			dwd.append("(\(x1),\(y1)) to (\(x2),\(y2)) : \(lines[i].flags) : \(lines[i].special) : \(lines[i].tag)\n")
			
			if let front = lines[i].side[0] {

				dwd.append("    \(front.y_offset) (\(front.x_offset) : \(front.upperTexture ?? "-") / \(front.lowerTexture ?? "-") / \(front.middleTexture ?? "-") )\n")
				dwd.append("    \(front.ends.floorHeight) : \(front.ends.floorFlat) \(front.ends.ceilingHeight) : \(front.ends.ceilingFlat) \(front.ends.lightLevel) \(front.ends.special) \(front.ends.tag)\n")
			}
			if let back = lines[i].side[1] {
				dwd.append("    \(back.y_offset) (\(back.x_offset) : \(back.upperTexture ?? "-") / \(back.lowerTexture ?? "-") / \(back.middleTexture ?? "-") )\n")
				dwd.append("    \(back.ends.floorHeight) : \(back.ends.floorFlat) \(back.ends.ceilingHeight) : \(back.ends.ceilingFlat) \(back.ends.lightLevel) \(back.ends.special) \(back.ends.tag)\n")
			}
			
		}

//		dwd.append(" \n")
		dwd.append("\nthings:\(things.count)\n")
		
		for i in 0..<things.count {
			dwd.append("(\(Int(things[i].origin.x)),\(Int(things[i].origin.y)), \(things[i].angle)) :\(things[i].type), \(things[i].options)\n")
		}
		
		return dwd
	}
	
}