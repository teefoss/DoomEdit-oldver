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
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		let mapWindowController = MapWindowController()
		mapWindowController.showWindow(self)
		self.mapWindowController = mapWindowController
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}


}

