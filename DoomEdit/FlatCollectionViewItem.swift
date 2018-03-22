//
//  FlatCollectionViewItem.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/13/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

class FlatCollectionViewItem: NSCollectionViewItem {

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
