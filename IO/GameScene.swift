//
//  GameScene.swift
//  IO
//
//  Created by sphota on 3/4/15.
//  Copyright (c) 2015 Lex Levi. All rights reserved.
//

import SpriteKit
import Foundation
import CoreMotion

final class GameScene: SKScene, SKPhysicsContactDelegate {
	
	/* Numericals */
	let offsetX = 4 as CGFloat
	let offsetY = 4 as CGFloat
	let MOTION_SCALE					= 100.0		as Double
	let MOTION_THRESHOLD				= 0.0001	as Double
	var WORLD_GRAVITY_VECTOR_Y			= -5.0		as CGFloat
	var NEAR_BACKGROUND_SPEED_FACTOR	= 200		as CGFloat
	var SPAWN_OBSTACLE_SPEED_FACTOR     = 2			as CGFloat
	var SPAWN_OBSTACLE_DELAY			= 1.4		as CGFloat
	let OBSTACLE_GAP_SIZE				= 100		as CGFloat
	var SCREEN_SIZE						= UIScreen.mainScreen().bounds.size
	
	/* Bitmask categories */
	let shipCategory	 : UInt32 = 0x1 << 0
	let barCategory		 : UInt32 = 0x1 << 1
	let gapCategory		 : UInt32 = 0x1 << 2
	let brickCategory	 : UInt32 = 0x1 << 3
	let lightCategory	 : UInt32 = 0x1 << 4
	
	/* Backgrounds*/ 
	let background1		= SKSpriteNode(imageNamed: "Image")
	let background2		= SKSpriteNode(imageNamed: "Image")
	
	var ship			: Ship?
	
	var movement		: NSTimer!
	var motion			: NSTimer!
	var acceleration	: NSTimer!

	let scoreLabelNode	= SKLabelNode()
	var scoreLabelShadow : SKLabelNode!
	let reset			= SKLabelNode()
	
	let barShortTexture	= SKTexture(imageNamed: "Bar2")
	let barLongTexture	= SKTexture(imageNamed: "Bar1")
	
	var ObstactleMoveAndRemove	= SKAction()
	var BrickDropAndRemove		= SKAction()
	var Tilt					= SKAction()
	
	var destX		: CGFloat = 0.0
	var endgame     = false
	var shipCrashed = false
	
	// =========================================
	
	/* Wrapper around NSTimer class func, because the original verbose method is awful */
	
	func start(#selector: String, interval: NSTimeInterval) -> NSTimer {
		return NSTimer.scheduledTimerWithTimeInterval(
			interval,
			target: self,
			selector: Selector(selector),
			userInfo: nil,
			repeats: true)
	}
	
	// =========================================
	
	/* View Set Up */
	
	func shootStars() {
		let path = NSBundle.mainBundle().pathForResource("Stars", ofType: "sks")
		let starsEmitter = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as! SKEmitterNode
		starsEmitter.particlePosition = CGPointMake(CGRectGetMidX(self.frame) - background1.size.height/10, CGRectGetMaxY(self.frame))
		starsEmitter.zPosition = -70
		self.addChild(starsEmitter)
	}
	
	// =========================================
	
	func setUpParallaxBackground() {
		background1.position  = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame))
		background1.zPosition = -100
		self.addChild(background1)
		
		background2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + background1.size.height)
		background2.zPosition = -100
		self.addChild(background2)
		
		/* Score */
		scoreLabelNode.fontColor	= UIColor(hex: 0xE7E6F8, alpha: 0.9)
		scoreLabelNode.fontName		= "8BIT WONDER Nominal"
		scoreLabelNode.text			= String(GameState.sharedInstance.score)
		scoreLabelNode.fontSize		= 40
		scoreLabelNode.position		= CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + self.view!.frame.size.height / 3.4)
		self.addChild(scoreLabelNode)
		
		scoreLabelShadow = scoreLabelNode.createDropShadow(2)
		scoreLabelShadow.fontColor = UIColor(hex: 0xFF007F, alpha: 0.7)
		self.addChild(scoreLabelShadow)
	}
	
	// =========================================
	
	func scrollBackground() { // called every frame
		/* Foreground */
		if NEAR_BACKGROUND_SPEED_FACTOR == 200 {
			background1.position.y = background1.position.y - self.view!.frame.size.height / NEAR_BACKGROUND_SPEED_FACTOR
			background2.position.y = background2.position.y - self.view!.frame.size.height / NEAR_BACKGROUND_SPEED_FACTOR
		
			if background2.position.y > (self.view!.frame.midY - 1) && background2.position.y < (self.view!.frame.midY + 1) {
				background1.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + background1.size.height)
				background2.position  = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame))
			}
		
			if background1.position.y > (self.view!.frame.midY - 1) && background2.position.y < (self.view!.frame.midY + 1) {
				background2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + background1.size.height)
				background1.position  = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame))
			}
		} else if NEAR_BACKGROUND_SPEED_FACTOR == 500 {
			background1.position.y = background1.position.y - self.view!.frame.size.height / NEAR_BACKGROUND_SPEED_FACTOR
			background2.position.y = background2.position.y - self.view!.frame.size.height / NEAR_BACKGROUND_SPEED_FACTOR
			
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
	
	// =========================================
	
	override final func didMoveToView(view: SKView) {
		self.setUpParallaxBackground()
		self.shootStars()
		
		self.spawnBars(false)
		
		/* Ship */
		ship = Ship()
		ship!.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame) - self.size.height / 4)
		ship!.ship!.texture?.filteringMode = SKTextureFilteringMode.Nearest
		self.addChild(ship!)
		
		if MotionManager.sharedInstance.motionManager.accelerometerAvailable == true {
			
			MotionManager.sharedInstance.motionManager.startAccelerometerUpdates()
			
			/* poll data from MotionManager */
			motion = start(selector:"updateAccelerometerData", interval: 0.01)
			
			if ship!.physicsBody == nil {
				ship!.physicsBody = SKPhysicsBody(circleOfRadius: ship!.ship!.size.height / 3)
				ship!.physicsBody!.dynamic = true
				ship!.physicsBody!.categoryBitMask = shipCategory
				ship!.physicsBody!.contactTestBitMask = barCategory
				ship!.physicsBody!.collisionBitMask = shipCategory
				ship!.physicsBody!.allowsRotation = false
			}
			acceleration = start(selector: "accelerateShip", interval: 0.1)
		} else {
			if ship!.physicsBody == nil {
				ship!.physicsBody = SKPhysicsBody(circleOfRadius: ship!.ship!.size.height / 3)
				ship!.physicsBody!.dynamic = true
				ship!.physicsBody!.categoryBitMask = shipCategory
				ship!.physicsBody!.contactTestBitMask = barCategory
				ship!.physicsBody!.collisionBitMask = shipCategory
				ship!.physicsBody!.allowsRotation = false
			}
		}
		/* start ship movement */
		movement = start(selector: "move", interval: 0.05)
	
		/* World */
		self.physicsWorld.gravity			= CGVectorMake( 0.0, WORLD_GRAVITY_VECTOR_Y )
		self.physicsWorld.contactDelegate	= self
	}
	
	// =========================================
	
	// MARK: - SKPhysicsContactDelegate
	
	// =========================================
	
	func didBeginContact(contact: SKPhysicsContact) {
		
		let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
		
		switch(contactMask) {
			
			case barCategory | shipCategory:
				if !shipCrashed {
					ship!.explode()
					self.gameOver()
				}
				shipCrashed = true

			
			case brickCategory | shipCategory:
				if !shipCrashed {
					ship!.explode()
					self.gameOver()
				}
				shipCrashed = true
			
			case lightCategory | brickCategory:
				contact.bodyB.node!.removeFromParent()
				contact.bodyA.node!.removeFromParent()
			
			default:
				return
			
		}
	}
	
	// =========================================
	
	func didEndContact(contact: SKPhysicsContact) {
		let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
		
		switch(contactMask) {
			
			case gapCategory | shipCategory:
				
				if !endgame {
					GameState.sharedInstance.score += 1
				
					scoreLabelNode.text = String(GameState.sharedInstance.score)
					scoreLabelShadow.text = String(GameState.sharedInstance.score)
				}
				
				/* Game Level Logic */
				switch (GameState.sharedInstance.score) {

					case Level.EASY.rawValue:
						self.spawnBricks()
					/*
					case Level.Medium.rawValue:
					case Level.Hard.rawValue:
					case Level.Insane.rawValue:
					case Level.Pro.rawValue:
					case Level.Pro.rawValue:*/
					default:
						println("Started Game")
				}
				
				if GameState.sharedInstance.score % 10 == 0 {
					self.shootStars()
				}
				contact.bodyA.node!.removeFromParent()
			
			default:
				return
		}
	}
	
	// =========================================
	
	func spawnBars(moving: Bool) {
		/* Bars */
		
		let distanceToMove = CGFloat(self.frame.size.height + barLongTexture.size().width)
		let moveBar		   = SKAction.moveByX(0.0, y: -distanceToMove, duration: NSTimeInterval(0.01 * distanceToMove / SPAWN_OBSTACLE_SPEED_FACTOR))
		let removeBar      = SKAction.removeFromParent()
		
		ObstactleMoveAndRemove = SKAction.sequence([moveBar, removeBar])
		
		let spawn = SKAction.runBlock { () -> () in
			if moving {
				self.spawnObstacle(false)
			} else {
				self.spawnObstacle(true)
			}
		}
		let delay = SKAction.waitForDuration(NSTimeInterval(SPAWN_OBSTACLE_DELAY))
		let spawnThenDelay = SKAction.sequence([spawn, delay])
		let spawnThenDelayForeverAndEverForAllEternity = SKAction.repeatActionForever(spawnThenDelay)
		self.runAction(spawnThenDelayForeverAndEverForAllEternity)
	}
	
	// =========================================
	
	func spawnBricks() {
		/* Bricks */
		let distanceToMove = CGFloat(self.frame.size.height + barLongTexture.size().width)
		let dropBrick = SKAction.moveByX(0.0, y: -distanceToMove, duration: NSTimeInterval(0.01 * distanceToMove / 4))
		let removeBrick = SKAction.removeFromParent()
		
		BrickDropAndRemove = SKAction.sequence([dropBrick, removeBrick])
		
		let spawnBrick = SKAction.runBlock { () -> () in
			self.spawnBrick()
		}
		let delayBrick = SKAction.waitForDuration(1.5)
		let spawnBrickThenDelay = SKAction.sequence([spawnBrick, delayBrick])
		let spawnBrickThenDelayForeverAndEverForAllEternity = SKAction.repeatActionForever(spawnBrickThenDelay)
		self.runAction(spawnBrickThenDelayForeverAndEverForAllEternity)
	}
	
	// =========================================
	
	func spawnObstacle(moving: Bool) {
		var width		= SCREEN_SIZE.width

		let barPair = SKNode()
		barPair.position = CGPointMake(CGRectGetMinX(self.frame) + (barPair.frame.size.width * 2) + CGFloat(arc4random() % UInt32(self.view!.frame.width / 5)), CGRectGetMidY(self.frame))
		barPair.zPosition = -10
		
		let barRight = SKSpriteNode(imageNamed: "Bar1")
		let barLeft = SKSpriteNode(imageNamed: "Bar3")
		
		if width == 320 {
			barLeft.xScale = 0.65
			barLeft.yScale = 0.65
		} else {
			barLeft.xScale = 0.9
			barLeft.yScale = 0.9
		}
		barLeft.position = barPair.position
		barLeft.physicsBody = SKPhysicsBody(rectangleOfSize: barLeft.size)
		barLeft.physicsBody?.dynamic = false
		barLeft.physicsBody?.categoryBitMask = barCategory
		barLeft.physicsBody?.collisionBitMask = barCategory
			barPair.addChild(barLeft)
		
		
		if width == 320 {
			barRight.xScale = 0.65
			barRight.yScale = 0.65
		} else {
			barRight.xScale = 0.9
			barRight.yScale = 0.9
		}
		barRight.position.y = barLeft.position.y
		barRight.position.x = barLeft.position.x + barLeft.size.width + OBSTACLE_GAP_SIZE
		barRight.physicsBody = SKPhysicsBody(rectangleOfSize: barRight.size)
		barRight.physicsBody?.categoryBitMask = barCategory
		barLeft.physicsBody?.collisionBitMask = barCategory
		barRight.physicsBody?.dynamic = false
			barPair.addChild(barRight)
		
		let gapSize = CGSizeMake(OBSTACLE_GAP_SIZE, barLeft.size.height)
		let gapNode = SKSpriteNode(color: UIColor.clearColor(), size: gapSize)
		gapNode.position = CGPointMake(barPair.position.x + barPair.position.x, barPair.position.y)
		gapNode.physicsBody = SKPhysicsBody(rectangleOfSize: gapSize)
		gapNode.physicsBody?.dynamic = false
		gapNode.physicsBody?.categoryBitMask = gapCategory
		gapNode.physicsBody?.contactTestBitMask = shipCategory
		gapNode.physicsBody?.collisionBitMask = shipCategory
			barPair.addChild(gapNode)
		
		if moving {
			//var moveSideways = SKAction.moveToX(x: CGFloat, duration: NSTimeInterval)
		}
		
		barPair.runAction(ObstactleMoveAndRemove)
			self.addChild(barPair)
	}
	
	// =========================================
	
	func spawnBrick() {
		let brick = SKSpriteNode(texture: barShortTexture)
		brick.position = CGPointMake(CGRectGetMinX(self.frame) + (barLongTexture.size().width / 4) + CGFloat(arc4random() % UInt32(self.view!.frame.width)), CGRectGetMaxY(self.frame) + barShortTexture.size().width)
		brick.zPosition = -10
		brick.physicsBody = SKPhysicsBody(rectangleOfSize: barShortTexture.size())
		brick.physicsBody?.dynamic = true
		brick.physicsBody?.allowsRotation = true
		brick.physicsBody?.affectedByGravity = true
		brick.physicsBody?.categoryBitMask = brickCategory
		brick.physicsBody?.contactTestBitMask = shipCategory
		brick.physicsBody?.collisionBitMask = brickCategory
		
		brick.runAction(BrickDropAndRemove)
			self.addChild(brick)
		
	}
	
	// =========================================
	
	/* Touches */
	
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		
		for touch: AnyObject in touches {
			let location = touch.locationInNode(self)
			
			/* stop acceleration on touch */
			if acceleration != nil && !endgame {
				acceleration.invalidate()
			}
			
			if self.nodeAtPoint(location) == reset {
				GameState.sharedInstance.reset()
				self.resetScene()
			}
		}

	}
	
	override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
		
		for _ in touches {
			if !endgame {
				/* accelerate ship again when player releases touch */
				acceleration = start(selector: "accelerateShip", interval: 0.01)
			}
		}
	}
	
	// =========================================
	
	/* Timed Methods */
	
	func updateAccelerometerData() { // for polling MotionManager
		var data = MotionManager.sharedInstance.motionManager.accelerometerData
		var currentX = self.ship!.position.x
		
		if data?.acceleration.x < -MOTION_THRESHOLD {
			self.destX = currentX + CGFloat(data.acceleration.x * MOTION_SCALE)
		}
			
		else if data?.acceleration.x > MOTION_THRESHOLD {
			self.destX = currentX + CGFloat(data.acceleration.x * MOTION_SCALE)
		}
	}
	
	func move() {
		Tilt = SKAction.moveToX(destX, duration: 0.1 as NSTimeInterval)
		
		self.ship!.runAction(Tilt)
	}
	
	func accelerateShip() {
		ship!.physicsBody?.velocity = CGVectorMake(0, 1)
		ship!.physicsBody?.applyImpulse(CGVectorMake(0, 50))
	}

	// =========================================
	
	func gameOver() {
		self.endgame = true
		
		self.physicsWorld.speed = 0.3
		
		SPAWN_OBSTACLE_SPEED_FACTOR = 0.03
		SPAWN_OBSTACLE_DELAY = 3
		NEAR_BACKGROUND_SPEED_FACTOR = 500
		
		self.shakeShipAndShowScore()
		
		GameState.sharedInstance.highScore = max(GameState.sharedInstance.score, GameState.sharedInstance.highScore)
		GameState.sharedInstance.save()
		
		ship!.physicsBody!.allowsRotation = true
		ship?.physicsBody!.applyAngularImpulse(0.01)
		acceleration.invalidate()

	}
	
	func resetScene() {
		self.removeAllChildren()
		self.removeAllActions()
		
		let scene = GameScene(size: self.size)
		let skView = self.view as SKView!
		skView.ignoresSiblingOrder = true
		scene.scaleMode = .ResizeFill
		scene.size = skView!.bounds.size
		skView.presentScene(scene, transition: SKTransition.fadeWithColor(UIColor.whiteColor(), duration: 0.6))
	}
	
	func shakeShipAndShowScore() {
		let shake = SKAction.shake(ship!.position, duration: 1, amplitudeX: 15, amplitudeY: 15)
		ship!.runAction(shake, completion: { () -> Void in
			self.SPAWN_OBSTACLE_SPEED_FACTOR = 2
			self.SPAWN_OBSTACLE_DELAY = 1.4
			self.NEAR_BACKGROUND_SPEED_FACTOR = 200
			
			self.physicsWorld.speed = 1
			
			self.ship!.physicsBody!.applyAngularImpulse(10)
			
			//gameOver.fontColor	= UIColor(hex: 0xFF007F, alpha: 0.8)
	
			//gameOverDropShadow.fontColor = UIColor(hex: 0x7F00FF, alpha: 0.8)
			
			
			self.reset.fontName	 = "8BIT WONDER Nominal"
			self.reset.text		 = "RETRY"
			self.reset.fontColor = UIColor(hex: 0x05CCFF, alpha: 0.9)
			self.reset.fontSize	 = 35
			self.reset.position	 = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 200)
			self.addChild(self.reset)
			
			let resetShadow				= self.reset.createDropShadow(2)
			resetShadow.fontColor = UIColor(hex: 0x05327F, alpha: 0.7)
			self.addChild(resetShadow)
		})
	}
	
	/* Update */
	
	// =========================================
	
    override func update(currentTime: CFTimeInterval) {

		self.scrollBackground()
		
		if ship!.position.y < 0 {
			if !shipCrashed {
				ship!.explode()
				self.gameOver()
			}
			shipCrashed = true
		}
	}
}
