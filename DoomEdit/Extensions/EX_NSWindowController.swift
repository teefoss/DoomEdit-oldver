
import Cocoa

extension NSWindowController {
	
	func positionWindowTopLeft(leftOffset: CGFloat, topOffset: CGFloat) {
		
		if let window = window, let screen = window.screen {
			let screenFrame = screen.visibleFrame
			let originY = screenFrame.maxY - window.frame.height - topOffset
			window.setFrameOrigin(NSPoint(x: leftOffset, y: originY))
		}
	}
}
