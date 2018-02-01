//
//  ProgressViewController.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/24/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

class ProgressViewController: NSViewController {
	
	@IBOutlet weak var progressBar: NSProgressIndicator!
	@IBOutlet weak var label: NSTextField!
	
	var win: NSWindow?
	
	let delay = DispatchTime.now() + 6.0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
		progressBar.isIndeterminate = false
		self.progressBar.startAnimation(self)

	}
	
	override func viewDidAppear() {
		super.viewDidAppear()

		win = view.window
		
		DispatchQueue.main.async {
			self.loadWad()
		}
		
		DispatchQueue.main.async {
			self.progressBar.increment(by: 100)
			self.label.stringValue = "Success!"
		}

		DispatchQueue.main.asyncAfter(deadline: delay) {
			self.win?.performClose(nil)
		}
	}
	
	
	
	func loadWad() {
		
		wad.readHeader()
		wad.readDirectory()
		wad.loadFlats()
		wad.loadPNAMES()
		wad.loadPatches()
		wad.loadTextures()
		wad.createAllTextureImages()
		wad.loadSprites()
	}
}



