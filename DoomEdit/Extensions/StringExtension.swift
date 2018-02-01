//
//  StringExtension.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/30/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Foundation

extension String {
	
	func appendLine(to fileURL: URL) throws {
		try (self + "\n").append(to: fileURL)
	}
	
	func append(to fileURL: URL) throws {
		let data = self.data(using: .ascii)!
		try data.append(to: fileURL)
	}
}
