//
//  WorldObjects.swift
//  DoomEdit
//
//  Created by Thomas Foster on 9/18/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//
//  Points, Lines, Sectors, Things, etc.
//

import Foundation

struct Point {
	var coord: NSPoint
	var isSelected: Bool
	var ref: Int
}

struct Side {
	var middleTexture: String?
	var upperTexture: String?
	var lowerTexture: String?
}

// For testing
// TODO: remove these
struct TestPoint {
	var coord: NSPoint
}

struct TestLine {
	var pt1, pt2: TestPoint
	
	var midPoint: NSPoint {
		let x = (pt1.coord.x + pt2.coord.x) / 2
		let y = (pt1.coord.y + pt2.coord.y) / 2
		return NSPoint(x: x, y: y)
	}
	
	/// The point at the end of the 'tick mark' of a line
	var normal: NSPoint {
		let dx = Double(pt2.coord.x - pt1.coord.x)
		let dy = Double(pt2.coord.y - pt1.coord.y)
		let length = CGFloat(sqrt(dx*dx + dy*dy) / Double(LINENORMALLENGTH))
		
		let normalX = midPoint.x + CGFloat(dy)/length
		let normalY = midPoint.y - CGFloat(dx)/length
		
		return NSPoint(x: normalX, y: normalY)
	}
}



struct Line {

	//Geometry
	var pt1, pt2: Point

	// TODO: - var length

	var slope: Double? {
		get {
			let delta_y = pt1.coord.y - pt2.coord.y
			let delta_x = pt1.coord.x - pt2.coord.x
			if delta_x != 0 {
				return Double(delta_y / delta_x)
			} else {
				return nil
			}
		}
	}
	
	var midpoint: CGPoint {
			let x = (pt1.coord.x + pt2.coord.x) / 2
			let y = (pt1.coord.y + pt2.coord.y) / 2
			return CGPoint(x: x, y: y)
	}
	
	var normal: Float

	// Editor
	var isSelected: Bool
	var ref: Int
	
	// Game properties
	var front: Side
	var back: Side?
	var x_offSet, y_offSet: Int
	var special, tag: Int
	var flags: [Int]
}



struct Sector {
	var ref: Int
	var isSelected: Bool
	
	var lines: [Line]
	var ceilingTexture, floorTexture: String
	var ceilingHeight, floorHeight: Int
	var light: Int
	var special, tag: Int
}



struct Thing {
	var ref: Int
	var isSelected: Bool
	
	var x, y: Int
	var size: CGSize
	var type: Int
	var direction: Int
	var flags: Int
	
}






















