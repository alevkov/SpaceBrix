//
//  Utilities.swift
//  IO
//
//  Created by sphota on 3/11/15.
//  Copyright (c) 2015 Lex Levi. All rights reserved.
//

import Foundation
import CoreGraphics

infix operator ** { associativity left precedence 160 }
func ** (right: CGFloat, left: Int) -> CGFloat {
	return CGFloat( pow( Double(right), Double(left) ) ) // Pa-pa-power
}

infix operator <!> { }
func <!> (inout right: Bool, inout left: Bool) { // Why does this even exist?!
	right	= false
	left	= false
}
