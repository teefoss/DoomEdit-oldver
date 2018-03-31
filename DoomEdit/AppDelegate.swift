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
	

	
	// ==============================
	// MARK: - Application Life Cycle
	// ==============================

	func applicationDidFinishLaunching(_ aNotification: Notification) {

		setTheme()
		//runMapMenuItem.isEnabled = editWorld.loaded
		
		// Display the launch window
		let launch = LaunchWindowController()
		launch.showWindow(self)
		self.launchWindowController = launch
	}

	func applicationWillTerminate(_ aNotification: Notification) {

		doomProject.quit()
	}

	@IBAction func openPreferences(_ sender: Any) {
		
		let prefs = PreferencesWindowController()
		prefs.showWindow(self)
		self.preferencesWindowController = prefs
	}
}

