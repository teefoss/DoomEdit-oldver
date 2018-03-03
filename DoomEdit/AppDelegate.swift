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
	@IBOutlet weak var runMapMenuItem: NSMenuItem!
	
	var launchWindowController: LaunchWindowController?
	var projectWindowController: ProjectWindowController?
	
	var mapWindowController: MapWindowController?
	var window: NSWindow?
	var preferencesWindowController: PreferencesWindowController?
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {

		runMapMenuItem.isEnabled = editWorld.loaded
		
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
	
	@IBAction func runMap(_ sender: Any) {
		editWorld.saveWorld()
		
		let url = Bundle.main.resourceURL?.appendingPathComponent("doombsp")
		
		let process = Process()
		process.launchPath = url?.path
		process.arguments = [(doomProject.currentMapURL?.path)!, doomProject.projectMapsURL.path]
		
		process.terminationHandler = {
			task in
			DispatchQueue.main.async {
				self.launchChocolateDoom()
			}
		}
		process.launch()
		process.waitUntilExit()
	}
	
	func launchChocolateDoom() {
		
		guard let openMap = doomProject.openMap else {
			print("Error. launchChocolateDoom")
			return
		}
		var wadfile = openMap.name
		
		if let range = wadfile.range(of: ".") {
			wadfile.removeSubrange(range.lowerBound..<wadfile.endIndex)
		}
		guard let warparg = convertMapToArg(mapname: wadfile) else {
			print("Error. warparg")
			return
		}
		wadfile += ".wad"
		
		// Launch chocolate doom with appropriate iwad, level, and pwad
		let process = Process()
		let bundlePath = "/Contents/MacOS/chocolate-doom"
		var appPath: String = ""
		if let path = UserDefaults.standard.value(forKey: PrefKeys.chocolateDoomPath) as? String {
			appPath = path
		} else {
			runAlertPanel(title: "Error!", message: "Could not launch Chocolate Doom. Please set the path in preferences.")
			return
		}
		if appPath == "" {
			runAlertPanel(title: "Error!", message: "Could not launch Chocolate Doom. Please set the path in preferences.")
			return
		}
		print(appPath + bundlePath)
		process.launchPath = appPath + bundlePath
		var args = ["-iwad", doomProject.wadURL.path,
					"-warp", warparg,
					"-merge", doomProject.projectMapsURL.appendingPathComponent(wadfile).path
		]
		if let netgame = UserDefaults.standard.value(forKey: PrefKeys.netGame) as? Bool {
			if netgame {
				args.append("-solo-net")
			}
		}
		if let dm = UserDefaults.standard.value(forKey: PrefKeys.deathmatch) as? Bool {
			if dm {
				args.append("-altdeath")
			}
		}
		if let nomon = UserDefaults.standard.value(forKey: PrefKeys.noMonsters) as? Bool {
			if nomon {
				args.append("-nomonsters")
			}
		}
		if let win = UserDefaults.standard.value(forKey: PrefKeys.windowed) as? Bool {
			if win {
				args.append("-window")
			} else {
				args.append("-fullscreen")
			}
		}
		if let nomus = UserDefaults.standard.value(forKey: PrefKeys.noMusic) as? Bool {
			if nomus {
				args.append("-nomusic")
			}
		}

		process.arguments = args
		process.launch()
		process.waitUntilExit()
	}
	
	/// Converts "E1M1" to "1 1" or "MAP01" to "1"
	/// Don't pass in string with extension
	func convertMapToArg(mapname: String) -> String? {

		var episode: Int = 0
		var mission: Int = 0
		let upper = mapname.uppercased()
		let scanner = Scanner(string: upper)
		
		if upper.first == "E" {
			if scanner.scanString("E", into: nil) && scanner.scanInt(&episode) &&
			scanner.scanString("M", into: nil) && scanner.scanInt(&mission)
			{
				let ep = String(episode)
				let m = String(mission)
				return ep + " " + m
			}
		} else if upper.first == "M" {
			if scanner.scanString("MAP", into: nil) && scanner.scanInt(&mission) {
				return String(mission)
			}
		}

		print("Error. convertMapToArg")
		return nil
	}
	
}

