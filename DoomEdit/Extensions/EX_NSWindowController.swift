
import Cocoa

extension NSWindowController {
	
	func positionWindowTopLeft(leftOffset: CGFloat, topOffset: CGFloat) {
		
		if let window = window, let screen = window.screen {
			let screenFrame = screen.visibleFrame
			let originY = screenFrame.maxY - window.frame.height - topOffset
			window.setFrameOrigin(NSPoint(x: leftOffset, y: originY))
		}
	}
	
	func centerWindowWith(size: CGFloat) {
		if let window = window, let screen = window.screen {
			let screenFrame = screen.visibleFrame
			let rect = NSRect(x: screenFrame.origin.x + screenFrame.size.width * size,
							  y: screenFrame.origin.y + screenFrame.size.height * size,
							  width: screenFrame.size.width * size,
							  height: screenFrame.size.height * size)
			window.setFrame(rect, display: true)
		}
	}
}
