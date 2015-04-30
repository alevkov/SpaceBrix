//
//  MotionManager.swift
//  IO
//
//  Created by sphota on 4/13/15.
//  Copyright (c) 2015 Lex Levi. All rights reserved.
//

import Foundation
import CoreMotion

private let _sharedInstance = MotionManager()

final class MotionManager: NSObject {
	
	var motionManager = CMMotionManager()
	
	class var sharedInstance: MotionManager {
		return _sharedInstance
	}
}