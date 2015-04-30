//
//  Extensions.swift
//  IO
//
//  Created by sphota on 4/20/15.
//  Copyright (c) 2015 Lex Levi. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

// ***************************
// UIColor
// ***************************

extension UIColor { // Use HEX color value as argument
	convenience init(hex: Int, alpha: CGFloat = 1.0) {
		
		let red			= CGFloat((hex & 0xFF0000)	>> 16) / 255.0
		let green		= CGFloat((hex & 0xFF00)	>> 8 ) / 255.0
		let blue		= CGFloat((hex & 0xFF)			 ) / 255.0
		
		self.init(red: red, green: green, blue: blue, alpha: alpha)
	}
}

extension UIColor { // Generate a random color
	convenience init(random: Bool, alpha: CGFloat) {
		
		let red			= CGFloat(arc4random() % 255) / 255.0
		let green		= CGFloat(arc4random() % 255) / 255.0
		let blue		= CGFloat(arc4random() % 255) / 255.0
		
		self.init(red: red, green: green, blue: blue, alpha: alpha)
	}
}

// ***************************
// Array
// ***************************

extension Array {
	/* removes a given object without specifying index */
	mutating func removeObject<U: Equatable>(object: U) {
		var index: Int?
		for (idx, objectToCompare) in enumerate(self) {
			if let to = objectToCompare as? U {
				if object == to {
					index = idx
				}
			}
		}
		
		if(index != nil) {
			self.removeAtIndex(index!)
		}
	}
}

// ***************************
// SKLabelNode
// ***************************

extension SKLabelNode {
	func createDropShadow(withOffset: CGFloat) -> SKLabelNode {
		let offsetX = withOffset
		let offsetY = withOffset
		let shadow = SKLabelNode()
		
		shadow.fontName		= self.fontName
		shadow.fontSize		= self.fontSize
		shadow.text			= self.text
		shadow.zPosition	= self.zPosition - 1
		shadow.position		= CGPointMake(self.position.x - offsetX, self.position.y - offsetY)
		
		return shadow
	}

}

