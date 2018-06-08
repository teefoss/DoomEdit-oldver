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

fileprivate let home = FileManager.default.homeDirectoryForCurrentUser

extension EditWorld {
	
	func saveMap(sender: Any?) {
		
		if !loaded {
			runAlertPanel(title: "Error!", message: "No map open.")
			return
		}
		
		let dwd = makeDWD() // generate a string in dwd format from level data
		
		//Write the dwd to current map url
		do {
			try dwd.write(to: doomProject.currentMapURL!, atomically: false, encoding: .ascii)
		} catch {
			print("Error. Could not save map as dwd at path \(doomProject.currentMapURL?.path ?? "")!")
		}

		doomProject.saveProject()
		
		dirty = false
	}
	

	/**
	Returns a string in dwd format
	*/
	private func makeDWD() -> String {
		
		var dwd: String = ""
		var count = 0
		
		for line in lines {
			if line.selected != -1 {
				count += 1
			}
		}
		
		dwd.append("WorldServer version 4\n\n")
		dwd.append("lines:\(count)\n")
		
		for i in 0..<lines.count {
			
			if lines[i].selected == -1 {
				continue
			}
			
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

		count = 0
		for thing in things {
			if thing.selected != -1 {
				count += 1
			}
		}
		dwd.append("\nthings:\(count)\n")
		
		for i in 0..<things.count {
			if things[i].selected == -1 {
				continue
			}
			dwd.append("(\(Int(things[i].origin.x)),\(Int(things[i].origin.y)), \(things[i].angle)) :\(things[i].type), \(things[i].options)\n")
		}
		
		return dwd
	}
	
}
