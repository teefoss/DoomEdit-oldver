//
//  DataExtension.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/12/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Foundation

extension Data {
	
	func scan<T>(offset: Int, length: Int) -> T {
		
		return subdata(in: offset..<offset+length).withUnsafeBytes {
			(pointer: UnsafePointer<T>) -> T in
			return pointer.pointee
		}
	}
	
	func elements <T> () -> [T] {
		return withUnsafeBytes {
			Array(UnsafeBufferPointer<T>(start: $0, count: count/MemoryLayout<T>.size))
		}
	}
	
	func append(to fileURL: URL) throws {
		if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
			defer {
				fileHandle.closeFile()
			}
			fileHandle.seekToEndOfFile()
			fileHandle.write(self)
		}
		else {
			try write(to: fileURL, options: .atomic)
		}
	}
}
