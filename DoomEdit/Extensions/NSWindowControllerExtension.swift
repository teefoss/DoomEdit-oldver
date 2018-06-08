
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
	
	func positionAtScreenTopRight() {

		if let window = window, let screen = window.screen {
			var p = NSPoint()
			p.x = screen.visibleFrame.origin.x + screen.visibleFrame.size.width - window.frame.size.width
			p.y = screen.visibleFrame.origin.y + screen.visibleFrame.size.height - window.frame.size.height
			window.setFrameOrigin(p)
		}
	}
	
	func positionAtScreenBottomRight() {
		
		if let window = window, let screen = window.screen {
			var p = NSPoint()
			p.x = screen.visibleFrame.origin.x + screen.visibleFrame.size.width - window.frame.size.width
			p.y = screen.visibleFrame.origin.y
			window.setFrameOrigin(p)
		}
	}
}
