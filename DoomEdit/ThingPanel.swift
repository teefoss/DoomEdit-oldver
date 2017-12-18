//
//  ThingViewController.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/10/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

class ThingPanel: NSViewController {
	
	var thing = Thing()
	var thingIndex: Int = 0
	var monsterIndex = 0
	
	override var acceptsFirstResponder: Bool { return true }
	override func becomeFirstResponder() -> Bool { return true }
	override func resignFirstResponder() -> Bool { return true }

	
	@IBOutlet weak var typeButton: NSPopUpButton!
	@IBOutlet weak var easyButton: NSButton!
	@IBOutlet weak var normalButton: NSButton!
	@IBOutlet weak var hardButton: NSButton!
	@IBOutlet weak var ambushButton: NSButton!
	@IBOutlet weak var networkButton: NSButton!
	@IBOutlet weak var northButton: NSButton!
	@IBOutlet weak var southButton: NSButton!
	@IBOutlet weak var eastButton: NSButton!
	@IBOutlet weak var westButton: NSButton!
	@IBOutlet weak var northeastButton: NSButton!
	@IBOutlet weak var southwestButton: NSButton!
	@IBOutlet weak var northwestButton: NSButton!
	@IBOutlet weak var southeastButton: NSButton!
	@IBOutlet weak var thingImageView: NSImageView!
	
	@IBOutlet weak var monsterMenu: NSMenu!
	
	
	var directionButtons: [NSButton] = []
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		directionButtons.append(eastButton)			// 0
		directionButtons.append(northeastButton)	// 45
		directionButtons.append(northButton)		// 90
		directionButtons.append(northwestButton)	// 135
		directionButtons.append(westButton)			// 180
		directionButtons.append(southwestButton)	// 225
		directionButtons.append(southButton)		// 270
		directionButtons.append(southeastButton)	// 315


    }
	
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		if thing.options & SKILL_EASY == SKILL_EASY { easyButton.state = .on } else { easyButton.state = .off }
		if thing.options & SKILL_NORMAL == SKILL_NORMAL { normalButton.state = .on } else { normalButton.state = .off }
		if thing.options & SKILL_HARD == SKILL_HARD { hardButton.state = .on } else { hardButton.state = .off }
		if thing.options & AMBUSH == AMBUSH { ambushButton.state = .on } else { ambushButton.state = .off }
		if thing.options & NETWORK == NETWORK { networkButton.state = .on } else { networkButton.state = .off }

		var index: Int
		if thing.angle == 0 {
			index = 0
		} else {
			index = thing.angle/45
		}
		
		for i in 0..<directionButtons.count {
			if i == index {
				directionButtons[i].state = .on
			} else {
				directionButtons[i].state = .off
			}
		}
	}
	
	@IBAction func easyClicked(_ sender: NSButton) {
		if sender.state == .on {
			things[thingIndex].options += SKILL_EASY
		} else {
			things[thingIndex].options -= SKILL_EASY
		}
	}

	@IBAction func normalClicked(_ sender: NSButton) {
		if sender.state == .on {
			things[thingIndex].options += SKILL_NORMAL
		} else {
			things[thingIndex].options -= SKILL_NORMAL
		}
	}
	
	@IBAction func hardClicked(_ sender: NSButton) {
		if sender.state == .on {
			things[thingIndex].options += SKILL_HARD
		} else {
			things[thingIndex].options -= SKILL_HARD
		}
	}
	
	@IBAction func ambushClicked(_ sender: NSButton) {
		if sender.state == .on {
			things[thingIndex].options += AMBUSH
		} else {
			things[thingIndex].options -= AMBUSH
		}
	}
	
	@IBAction func networkClicked(_ sender: NSButton) {
		if sender.state == .on {
			things[thingIndex].options += NETWORK
		} else {
			things[thingIndex].options -= NETWORK
		}
	}
	
	@IBAction func directionClicked(_ sender: NSButton) {

		if sender.state == .on {
			return
		} else {
			//deselectAllButtons()
			sender.state = .on
//			for i in 0..<directionButtons.count {
//				directionButtons[i].state = .off
//				sender.state = .on
//				if sender === directionButtons[i] {
//					things[thingIndex].angle = i*45
//				}
//			}
		}
	}
	
//	func deselectAllButtons() {
//		for i in 0..<directionButtons.count {
//			button.state = .off
//		}
//	}
	
	
	func updateThing(_ type: Int) {
		things[thingIndex].type = type
		thingImageView.image = NSImage(named: NSImage.Name(rawValue: things[thingIndex].imageName))
		typeButton.removeItem(at: 0)
		typeButton.insertItem(withTitle: things[thingIndex].name, at: 0)
		typeButton.selectItem(at: 0)
	}
	
	
	// ==================
	// Mark: - IB Actions
	// ==================
	
	@IBAction func selectZombieman(_ sender: NSMenuItem) {
		updateThing(3004)
	}
	
	@IBAction func selectShotgunGuy(_ sender: NSMenuItem) {
		updateThing(9)
	}
	
	@IBAction func selectImp(_ sender: NSMenuItem) {
		updateThing(3001)
	}
	
	// FIXME: get key presses
	override func keyDown(with event: NSEvent) {
		switch event.keyCode {
		case KEY_1:
			updateThing(3004)
		default:
			break
		}
	}
	
	
    
}
