//
//  HelpWindowController.swift
//  DoomEdit
//
//  Created by Thomas Foster on 6/2/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

protocol HelpWindowDelegate {
	func updateText(for mode: Mode)
}

struct HelpMessages {
	
	let editmode: NSAttributedString!
	let drawmode: NSAttributedString!
	
	init() {
		guard let editModeURL = Bundle.main.url(forResource: "editmode", withExtension: "rtf") else { fatalError() }
		guard let drawModeURL = Bundle.main.url(forResource: "drawmode", withExtension: "rtf") else { fatalError() }
		
		do {
			editmode = try NSAttributedString(url: editModeURL, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
			drawmode = try NSAttributedString(url: drawModeURL, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
		} catch {
			fatalError()
		}
	}
	
}

class HelpWindowController: NSWindowController, HelpWindowDelegate {
	
	@IBOutlet weak var label: NSTextField!
	
	
			
	override var windowNibName: NSNib.Name? {
		return NSNib.Name(rawValue: "HelpWindowController")
	}
	
    override func windowDidLoad() {
        super.windowDidLoad()
		
		window?.backgroundColor = COLOR_HELP
		
		let messages = HelpMessages()
		label.attributedStringValue = messages.editmode
    }
	
	func updateText(for mode: Mode)
	{
		print("called")
		let messages = HelpMessages()
		
		switch mode {
		case .edit:
			label.attributedStringValue = messages.editmode
		case .draw:
			label.attributedStringValue = messages.drawmode
		default:
			label.attributedStringValue = messages.editmode
		}
	}
	
}
