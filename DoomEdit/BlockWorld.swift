//
//  BlockWorld.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/13/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

var blockWorld = BlockWorld()
var sectors: [Sector] = []
var numSectors: Int {
	return sectors.count
}

class BlockWorld {
	
	var wbounds = NSRect()
	var bwidth: Int = 0
	var bheight: Int = 0
	var bmap: [UInt16]?
	var brow: Int = 0
	
	let WL_NORTH: Int = 0
	let WL_EAST: Int = 1
	let WL_SOUTH: Int = 2
	let WL_WEST: Int = 3
	let WL_MARK: Int = 4
	let WL_NWSE: Int = 5
	let WL_NESW: Int = 6
	let WLSIZE: Int = 7
	let SIDEBIT: UInt16 = 0x8000
	
	var blockView = NSView()
	
	// MARK: -

	func sectorError(message: String, line1: Int, line2: Int) {
		
		// panel order out
		// run panel
		editWorld.deselectAll()
		if line1 != -1 {
			editWorld.selectLine(line1)
		}
		if line2 != -1 {
			editWorld.selectLine(line2)
		}
		editWorld.updateWindows()
		runAlertPanel(title: "Sector Error", message: message)
	}
	
	
	// ========================
	// MARK: - World Pixelation
	// ========================

	/// Allocates a new block map.
	func createBlockMap() {
		
		var size: Int
		
		// find the dimensions of the world and allocate an empty map
		wbounds = editWorld.getBounds()

		if bmap != nil {
			bmap = nil
		}
		bwidth = Int(wbounds.size.width/8)
		bheight = Int(wbounds.size.height/8)
		brow = bwidth * WLSIZE
		size = brow * bheight * 2
		bmap = Array(repeating: 0, count: size)
		
		// draw all the lines into the map
		for i in 0..<lines.count {
			if lines[i].selected != -1 {
				drawBlockLine(i)
			}
		}
	}
	
	/// Writes all line data to the block map.
	func drawBlockLine(_ lineNum: Int) {
		
		var line: Line
		var x1,y1,x2,y2: Int
		var pt: NSPoint
		var left,right,top,bottom: UInt16
		var dest: Int
		var offset: Int
		var dx,dy,ilength: Int
		var length,x,y,xstep,ystep: Float
		let li = UInt16(lineNum)
		
		line = lines[lineNum]
		pt = points[line.pt1].coord
		x1 = Int((pt.x - wbounds.origin.x)/8)
		y1 = Int((pt.y - wbounds.origin.y)/8)
		pt = points[line.pt2].coord
		x2 = Int((pt.x - wbounds.origin.x)/8)
		y2 = Int((pt.y - wbounds.origin.y)/8)
		
		// vertical line
		if x1 == x2 {
			if y1 < y2 {
				left = (li+1) | SIDEBIT
			} else {
				left = li+1
				let temp = y1
				y1 = y2
				y2 = temp
			}
			
			right = left ^ SIDEBIT
			dest = (bheight-1-y1)*brow + x1*WLSIZE
			
			while y1 < y2 {
				bmap![dest+WL_WEST] = right
				bmap![dest-WLSIZE+WL_EAST] = left
				dest -= brow
				y1 += 1
			}
			return
		}
		
		// horizontal line
		if y1 == y2 {
			if x1 < x2 {
				top = (li+1) | SIDEBIT
			} else {
				top = li+1
				let temp = x1
				x1 = x2
				x2 = temp
			}
			
			bottom = top ^ SIDEBIT
			dest = (bheight-1-y1)*brow + x1*WLSIZE
			
			while x1 < x2 {
				bmap![dest+WL_SOUTH] = top
				bmap![dest+brow+WL_NORTH] = bottom
				dest += WLSIZE
				x1 += 1
			}
			return
		}
		
		// sloping line
		if x1 < x2 {
			if y1 < y2 {
				offset = WL_NESW
				left = li+1
			} else {
				offset = WL_NWSE
				left = li+1
			}
		} else {
			if y1 < y2 {
				offset = WL_NWSE
				left = (li+1) | SIDEBIT
			} else {
				offset = WL_NESW
				left = (li+1) | SIDEBIT
			}
		}
													// Original was:
		dx = x2 - x1								// int dx
		dy = y2 - y1								// int dy
		let dx_f = Float(dx)
		let dy_f = Float(dy)
		length = sqrtf(dx_f*dx_f + dy_f*dy_f)		// float length
		xstep = dx_f/length							// float xstep
		ystep = dy_f/length							// float ystep
		x = Float(x1)+xstep/2						// float x
		y = Float(y1)+ystep/2						// float y
		ilength = Int(length+0.5)					// int ilength
		
		repeat {
			y1 = Int(y)
			x1 = Int(x)
			dest = (bheight-1-y1)*brow + x1*WLSIZE
			bmap![dest+offset] = left
			x += xstep
			y += ystep
			ilength -= 1
		} while (ilength > 0)
		
		return
	}
	
	/// Selects front or back of a line.
	func selectLine(_ line: UInt16) {
		var li = line - 1
		if li & SIDEBIT == SIDEBIT {
			li &= ~SIDEBIT
			let index = Int(li)
			lines[index].selected = 2
			return
		}
		let index = Int(li)
		lines[index].selected = 1
	}
	
	/// Scans for all lines in an enclosed area and selects them.
	func floodLine(startx: Int, y: Int) {
		
		var x, firstx, lastx: Int
		var line: UInt16 = 0
		var dest: Int
		
		if startx<0 || startx >= bwidth || y < 0 || y >= bheight {
			fatalError("Bad fill point.")
		}
		
		// scan east until a wall is hit
		x = startx-1
		while x < bwidth - 1 {
			x += 1
			dest = y*brow + x*WLSIZE
			bmap![dest+WL_MARK] = 1
			
			if bmap![dest+WL_EAST] != 0 {
				line = bmap![dest+WL_EAST]
				selectLine(line)
				break
			} else if x < bwidth - 1 {
				if bmap![dest+WLSIZE+WL_NWSE] != 0 {
					line = bmap![dest+WLSIZE+WL_NWSE]
					selectLine(line)
					break
				} else if bmap![dest+WLSIZE+WL_NESW] != 0 {
					line = bmap![dest+WLSIZE+WL_NESW]
					selectLine(line^SIDEBIT)
					break
				}
			}
		}
		lastx = x
		
		// scan west until a wall is hit
		x = startx
		while x > 0 {
			dest = y*brow + x*WLSIZE
			bmap![dest+WL_MARK] = 1
			
			if bmap![dest+WL_WEST] != 0 {
				line = bmap![dest+WL_WEST]
				selectLine(line)
				break
			} else if x > 0 {
				if bmap![dest-WLSIZE+WL_NWSE] != 0 {
					line = bmap![dest-WLSIZE+WL_NWSE]
					selectLine(line^SIDEBIT)
					break
				} else if bmap![dest-WLSIZE+WL_NESW] != 0 {
					line = bmap![dest-WLSIZE+WL_NESW]
					selectLine(line)
					break
				}
			}
			x -= 1
		}
		firstx = x
		
		// check the top and bottom pixels
		if firstx < 0 || lastx >= bwidth || firstx > lastx {
			fatalError("Bad fill span.")
		}
		
		for x in firstx...lastx {
			dest = y*brow + x*WLSIZE
			
			if bmap![dest+WL_SOUTH] != 0 {
				line = bmap![dest+WL_SOUTH]
				selectLine(line)
			} else if y < bheight-1 && bmap![dest+brow+WL_MARK] == 0 {
				if bmap![dest+brow+WL_NWSE] != 0 {
					line = bmap![dest+brow+WL_NWSE]
					selectLine(line^SIDEBIT)
				} else if bmap![dest+brow+WL_NESW] != 0 {
					line = bmap![dest+brow+WL_NESW]
					selectLine(line^SIDEBIT)
				} else {
					floodLine(startx: x, y: y+1)
				}
			}
			
			if bmap![dest+WL_NORTH] != 0 {
				line = bmap![dest+WL_NORTH]
				selectLine(line)
			} else if y > 0 && bmap![dest-brow+WL_MARK] == 0 {
				if bmap![dest-brow+WL_NWSE] != 0 {
					line = bmap![dest-brow+WL_NWSE]
					selectLine(line)
				} else if bmap![dest-brow+WL_NESW] != 0 {
					line = bmap![dest-brow+WL_NESW]
					selectLine(line)
				} else {
					floodLine(startx: x, y: y-1)
				}
			}
		}
	}
	
	func floodFillSector(from point: NSPoint) {
		var x1, y1: Int
		
		createBlockMap()
		editWorld.deselectAll()
		x1 = Int(point.x - wbounds.origin.x)/8
		y1 = Int(point.y - wbounds.origin.y)/8
		
		floodLine(startx: x1, y: bheight-1-y1)
	}
	
	/// Displays the block map visually in a window for testing purposes.
	/*
	func displayBlockMap() {
		
		var aRect: NSRect
		var window: NSWindow
		var planes: [CUnsignedChar]
		var i, size: Int
		var dest: Int
		
		aRect = NSRect(x: 100, y: 100, width: brow/WLSIZE, height: bheight)
		window = NSWindow.init(contentRect: aRect, styleMask: .titled, backing: .buffered, defer: false)
		window.display()
		
		window.contentView = blockView
		size = brow/WLSIZE*bheight
		
		for i in 0..<size {
			if bmap![WL_MARK] != 0 {
				
			}
		}
	}
	*/
	
	// bcmp()
	//
	// The bcmp() function shall compare the first n bytes of the area pointed to by s1 with the area pointed to by s2.
	// The bcmp() function shall return 0 if s1 and s2 are identical; otherwise, it shall return non-zero. Both areas are assumed to be n bytes long. If the value of n is 0, bcmp() shall return 0.
	
	// FIXME: makeSector() : get it working
	
	/// Groups all selected sides into a sector.
	/// Returns `false` and presents an alert panel if there is an error.
	func makeSector() -> Bool {
		
		var side = Side()
		var backline, frontline: Int
		var newSector = Sector()
		var nilSide = false
		
		backline = -1
		frontline = -1
		
		
		for i in 0..<lines.count {
			
			let line = lines[i]

			if line.selected < 1 {  // deleted line
				continue
			}
			
			// backside of two-sided line selected
			if line.selected == 2 && (line.flags & TWO_SIDED == 1) {
				backline = i
				continue
			}
			
			// flood point outside of level
//			if line.selected == 2 && (line.flags & TWO_SIDED != 1) {
//				continue
//			}

//			// added because sometimes the back side (side[1]) is nil
			if line.side[line.selected-1] == nil {
				continue
			}
			
			// shouldn't be nil!(?)
			side = lines[i].side[line.selected-1]!  // the selected side
			
			if frontline == -1 {
				newSector.def = side.ends
			} else {
				if newSector.def == side.ends {
					newSector.lines = []
					sectorError(message: "Line side sectordefs differ", line1: i, line2: frontline)
					return false
				}
			}
			
			newSector.lines.append(i)
			frontline = i
			if lines[i].side[line.selected-1]?.sector != -1 {
				newSector.lines = []
				sectorError(message: "Line side grouped into multiple sectors", line1: i, line2: -1)
				return false
			} else {
				lines[i].side[line.selected-1]?.sector = sectors.count
			}
			
//			if nilSide {  // set it back to nil again
//				lines[i].side[line.selected-1] == nil
//				nilSide = false
//			}
		}
		
		if backline > -1 && frontline > -1 {
			newSector.lines = []
			sectorError(message: "Inside and outside lines grouped together", line1: backline, line2: frontline)
			return false
		}
		if frontline > -1 {
			sectors.append(newSector)
		} else {
			newSector.lines = []
		}
		
		return true
	}
	
	
	func connectSectors() -> Bool {

		var sector = Sector()

		// clear all sector marks
		
		for i in 0..<sectors.count {
			sector = sectors[i]
			sector.lines = []
		}
		
		sectors = []
		
		for i in 0..<lines.count {
			lines[i].side[0]?.sector = -1
			lines[i].side[1]?.sector = -1
		}
		
		// flood fill everything
		
		createBlockMap()
		// TODO: panel
		var dest = 0
		for y in 0..<bheight {
			for x in 0..<bwidth {
				if bmap![dest+WL_MARK] == 0 && bmap![dest+WL_NWSE] == 0 && bmap![dest+WL_NESW] == 0 {
					editWorld.deselectAll()
					floodLine(startx: x, y: y)
					if makeSector() == false {
						return false
					}
				}
				dest += WLSIZE
			}
		}
		
		// check to make sure all line sides were grouped
		
		for i in 0..<lines.count {
			
			if lines[i].selected < 1 {
				continue
			}
						
			if lines[i].side[0]?.sector == -1 || ((lines[i].flags & TWO_SIDED) == 1 && lines[i].side[1]?.sector == -1) {
				sectorError(message: "Line side not grouped", line1: i, line2: -1)
				return false
			}
		}
		
		editWorld.deselectAll()
		return true
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}
