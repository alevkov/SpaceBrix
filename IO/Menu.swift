//
//  Menu.swift
//  IO
//
//  Created by sphota on 3/4/15.
//  Copyright (c) 2015 Lex Levi. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation
import CoreMotion

final class Menu: SKScene {
	let offsetX = 4 as CGFloat
	let offsetY = 4 as CGFloat
	
	let audioPlayer	= AVAudioPlayer()
	let logo		= SKLabelNode()
	var logoDrop	: SKLabelNode!
	
	let background1	= SKSpriteNode(imageNamed: "Image")
	let background2	= SKSpriteNode(imageNamed: "Image")
	
	var moveTimer	: NSTimer!
	
	func makeDropShadowLogo() {
		var size = UIScreen.mainScreen().bounds.size
		var width = size.width
		logo.fontName			= "8BIT WONDER Nominal"
		logo.text				= "spacebrix"
		logo.fontColor			= UIColor(hex: 0xFF007F, alpha: 0.5)
		
		if width == 320 {
			logo.fontSize = 35
		} else {
			logo.fontSize = 40
		}
		
		logo.position			= CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 20)
		self.addChild(logo)
		
		logoDrop = logo.createDropShadow(4)
		logoDrop.fontColor = UIColor(hex: 0x7F00FF, alpha: 0.3)
		self.addChild(logoDrop)
		
		moveTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "moveDropShadow", userInfo: nil, repeats: true)
	}
	
	func moveDropShadow() {
		var jerkAction = SKAction.moveByX(offsetX + CGFloat(arc4random_uniform(15)), y: offsetY - CGFloat(arc4random_uniform(15)), duration: 0.05)
		var returnToOriginal = SKAction.moveTo(CGPointMake(logo.position.x - offsetX, logo.position.y - offsetY), duration: 0.02)
		var wait = SKAction.waitForDuration(1.5)
		var jerkThenWait = SKAction.sequence([jerkAction,returnToOriginal, wait])
		logoDrop.runAction(jerkThenWait, completion: { () -> Void in
			jerkAction = SKAction.moveByX(self.offsetX - CGFloat(arc4random_uniform(15)), y: self.offsetY - CGFloat(arc4random_uniform(15)), duration: 0.05)
			jerkThenWait = SKAction.sequence([jerkAction,returnToOriginal, wait])
		})
	}
	
	override func didMoveToView(view: SKView) {
		self.backgroundColor	= UIColor(hex: 0xCC1247, alpha: 1.0)
		self.makeDropShadowLogo()
		
		self.view!.showsNodeCount <!> self.view!.showsFPS
		
		background1.position  = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame))
		background1.zPosition = -100
		self.addChild(background1)
		
		background2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + background1.size.height)
		background2.zPosition = -100
		self.addChild(background2)
		
	}
	
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		for touch: AnyObject in touches {
			let location = touch.locationInNode(self)
			
			if self.nodeAtPoint(location) == logo {
				var scene = GameScene(size: self.size)
				let skView = self.view as SKView!
				skView.ignoresSiblingOrder = true
				scene.scaleMode = .ResizeFill
				scene.size = skView!.bounds.size
				skView.presentScene(scene, transition: SKTransition.fadeWithColor(UIColor.whiteColor(), duration: 0.6))
			}
		}
	}
	
	override func update(currentTime: NSTimeInterval) {
		/* Foreground */
		background1.position.y = background1.position.y - self.view!.frame.size.height / 200
		background2.position.y = background2.position.y - self.view!.frame.size.height / 200
		
		if background2.position.y > (self.view!.frame.midY - 1) && background2.position.y < (self.view!.frame.midY + 1) {
			background1.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + background1.size.height)
			background2.position  = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame))
		}
		
		if background1.position.y > (self.view!.frame.midY - 1) && background2.position.y < (self.view!.frame.midY + 1) {
			background2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + background1.size.height)
			background1.position  = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame))
		}
	}
}