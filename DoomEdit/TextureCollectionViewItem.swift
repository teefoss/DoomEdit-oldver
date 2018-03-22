//
//  TextureCollectionViewItem.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/31/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

class TextureCollectionViewItem: NSCollectionViewItem {

	var name: String = ""
	var width: Int = 0
	var height: Int = 0
	
    override func viewDidLoad() {
        super.viewDidLoad()

		view.wantsLayer = true
		//view.layer?.backgroundColor = NSColor.gridColor.cgColor
		view.layer?.borderColor = NSColor.red.cgColor
		view.layer?.borderWidth = 0.0
	}
	
	override var isSelected: Bool {
		didSet {
			view.layer?.borderWidth = isSelected ? 2.0 : 0.0
		}
	}
		
}
