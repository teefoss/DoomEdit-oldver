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
		if checkWADPaths() == 0 {
			runAlertPanel(title: "Warning", message: "No WAD Paths are set. Go to File > Preferences and set where your DOOM or DOOM 2 WADs are located.")
		}
		
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
	
	/// FIXME: Is this right??
	func updateHelpText(for mode: Mode) {
		
		for window in NSApp.windows {
			if let wc = window.windowController as? HelpWindowController {
				wc.updateText(for: mode)
			}
		}
	}
		
	
	/// Load the theme from defaults and set colors accordingly
	func setTheme() {
		
		if let theme = UserDefaults.standard.value(forKey: PrefKeys.theme) as? Int {
			switch theme {
			case 1:
				currentStyle = lightStyle
			case 2:
				currentStyle = darkStyle
			default:
				currentStyle = lightStyle
			}
		}
		redraw()
	}
	

}

