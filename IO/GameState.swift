//
//  GameState.swift
//  IO
//
//  Created by sphota on 4/10/15.
//  Copyright (c) 2015 Lex Levi. All rights reserved.
//

import Foundation

/* This sngtn variant uses a global,but it's much cleaner
 * than using a struct */
private let _sharedInstance = GameState.loadInstance()

final class GameState: NSObject, NSCoding {
	
	class var sharedInstance: GameState {
		return _sharedInstance
	}
	
	let GameDataHighScoreKey = "highscore"
	
	var score = 0
	var highScore = 0
	
	func reset() {
		score = 0
	}
	
	convenience init(coder aDecoder: NSCoder) {
		self.init()
		
		highScore = aDecoder.decodeIntegerForKey(GameDataHighScoreKey)
	}
	
	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeInteger(highScore, forKey: GameDataHighScoreKey)
	}
	
	func save() {
		var encodedData: NSData = NSKeyedArchiver.archivedDataWithRootObject(self)
		encodedData.writeToFile(GameState.filePath() as String, atomically: true)
	}
	
	class func filePath() -> NSString {
		/* create filepath to store highscore */
		var filePath: NSString? = nil
		if filePath == nil {
			filePath = (NSSearchPathForDirectoriesInDomains(
				NSSearchPathDirectory.DocumentDirectory,
				NSSearchPathDomainMask.UserDomainMask,
				true).first! as? NSString)?.stringByAppendingPathComponent("gamedata")
			
		}
		
		return filePath!
	}
	
	class func loadInstance() -> GameState {
		let decodeData: NSData? = NSData(contentsOfFile: GameState.filePath() as String)
		if decodeData != nil {
			/* What unarchiveObjectWithData: does here is to try to initialize
			* a new GameState by invoking its initWithCoder: initializer
			* with an NSCoder loaded with decodedData.
			* */
			let gameData = NSKeyedUnarchiver.unarchiveObjectWithData(decodeData!) as! GameState
			
			return gameData
		}
		
		return self()
	}

}



