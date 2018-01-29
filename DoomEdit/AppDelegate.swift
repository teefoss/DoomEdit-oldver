//
//  AppDelegate.swift
//  DoomEdit
//
//  Created by Thomas Foster on 11/21/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	var mapWindowController: MapWindowController?
	var window: NSWindow?
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {

//		wad.loadAssets()
		let progVC = ProgressViewController()
		let win = NSWindow(contentViewController: progVC)
		win.makeKeyAndOrderFront(self)
		self.window = win
		
		let mapWindowController = MapWindowController()
		mapWindowController.showWindow(self)
		self.mapWindowController = mapWindowController
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}


}

