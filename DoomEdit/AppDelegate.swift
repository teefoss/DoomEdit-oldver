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
	var preferencesWindowController: PreferencesWindowController?
	

	
	// ==============================
	// MARK: - Application Life Cycle
	// ==============================

	func applicationDidFinishLaunching(_ aNotification: Notification) {

		setTheme()
		
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

	/// Redraw the contents of the map view.
	func redraw() {
		
		for window in NSApp.windows {
			if let wc = window.windowController as? MapWindowController {
				wc.mapView.display()
			}
		}
	}
	
	
	/// Load the theme from defaults and set colors accordingly
	func setTheme() {
		
		if let t = UserDefaults.standard.value(forKey: PrefKeys.theme) as? Int {
			switch t {
			case 1:
				THEME = .light
			case 2:
				THEME = .dark
			default:
				break
			}
		}
		switch THEME {
		case .light:
			COLOR_BKG = NSColor.white
			COLOR_LINE_ONESIDED = NSColor.black
			COLOR_MONSTER = NSColor.black
			COLOR_THINGINFO = NSColor.white
			COLOR_GRID = NSColor.systemBlue.withAlphaComponent(0.1)
			COLOR_TILE = NSColor.systemBlue.withAlphaComponent(0.3)
		case .dark:
			COLOR_BKG = NSColor.black
			COLOR_LINE_ONESIDED = NSColor.yellow
			COLOR_MONSTER = NSColor.white
			COLOR_THINGINFO = NSColor.black
			COLOR_GRID = NSColor.systemBlue.withAlphaComponent(0.2)
			COLOR_TILE = NSColor.systemBlue.withAlphaComponent(0.4)
		}
		//editWorld.delegate?.redisplay(editWorld.bounds)
		redraw()
	}

}

