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

	@IBOutlet weak var preferencesMenuItem: NSMenuItem!
	
	var launchWindowController: LaunchWindowController?
	var projectWindowController: ProjectWindowController?
	
	var mapWindowController: MapWindowController?
	var window: NSWindow?
	var preferencesWindowController: PreferencesWindowController?
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {

//		/*
		let launch = LaunchWindowController()
		launch.showWindow(self)
		self.launchWindowController = launch
//		*/
		
		
		/*
		let progVC = ProgressViewController()
		let win = NSWindow(contentViewController: progVC)
		win.makeKeyAndOrderFront(self)
		self.window = win
		*/
		
		/*
		let mapWindowController = MapWindowController()
		mapWindowController.showWindow(self)
		self.mapWindowController = mapWindowController
		*/
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	@IBAction func openPreferences(_ sender: Any) {
		
		let prefs = PreferencesWindowController()
		prefs.showWindow(self)
		self.preferencesWindowController = prefs
	}
	

}

