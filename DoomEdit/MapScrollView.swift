//
//  MapScrollView.swift
//  DoomEdit
//
//  Created by Thomas Foster on 3/16/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

class MapScrollView: NSScrollView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

	override var wantsDefaultClipping: Bool {
		return false
	}
	
}
