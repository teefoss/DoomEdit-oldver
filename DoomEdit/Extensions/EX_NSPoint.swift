
import Foundation

infix operator <->

extension NSPoint {
	
	static func <-> (left: NSPoint, right: NSPoint) -> CGFloat {
		return sqrt(pow(left.x - right.x, 2) + pow(left.y - right.y, 2))
	}
	
}
