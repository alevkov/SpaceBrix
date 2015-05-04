//
//  Ship.swift
//  IO
//
//  Created by sphota on 4/6/15.
//  Copyright (c) 2015 Lex Levi. All rights reserved.
//

import Foundation
import SpriteKit

final class Ship: SKNode {
	
	var ship : SKSpriteNode?
	
	/* Private properties */
	private var _shipTexture		: SKTexture?
	private var _explosionFrames	: [AnyObject]?
	private var _thrustframes		: [AnyObject]?
	private var _explodingNode		: SKNode!
	private var _thrustNode			: SKNode!
	
	override init() {
		super.init()
		
		/* Ship */
		_shipTexture = SKTexture(imageNamed: "Spaceship")
		ship = SKSpriteNode(texture: _shipTexture)
		ship?.xScale = 0.5
		ship?.yScale = 0.5
			self.addChild(ship!)
		
		/* Explosions */
		var explosionFrames			= [AnyObject]()
		let explosionAnimatedAtlas  = SKTextureAtlas(named: "explosion")
		let explosionImageCount		= explosionAnimatedAtlas.textureNames.count
		
		for ( var i = 1; i <= explosionImageCount; i++ ) {
			var name = "0\(i)"
			var temp = explosionAnimatedAtlas.textureNamed(name)
			
			explosionFrames.append(temp)
		}
		
		_explosionFrames = explosionFrames
		
		var explTemp	= _explosionFrames![0] as! SKTexture
		_explodingNode	= SKSpriteNode(texture: explTemp)
		
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	private func animateExplosion (explNodes: [SKSpriteNode]) {
		/* Creates two explosions, ship position-dependent */
		explNodes[0].position.x = self.position.x + CGFloat(arc4random_uniform(50))
		explNodes[0].position.y = self.position.y
		
		explNodes[0].xScale = 0.5
		explNodes[0].yScale = 0.5
		
		explNodes[1].xScale = 0.5
		explNodes[1].yScale = 0.5
		
		self.parent!.addChild(explNodes[0])
		
		/* fist explosion */
		explNodes[0].runAction(SKAction.repeatAction(SKAction.animateWithTextures (_explosionFrames!,
			timePerFrame: 0.05,
			resize: false,
			restore: false),
			count: 1),
			completion: { () -> Void in
				explNodes[0].removeFromParent()
				
				/* second explosion */
				explNodes[1].position.x = self.position.x - CGFloat(arc4random_uniform(50))
				explNodes[1].position.y = self.position.y
				self.parent!.addChild(explNodes[1])
				
				explNodes[1].runAction(SKAction.repeatAction(SKAction.animateWithTextures (self._explosionFrames!,
					timePerFrame: 0.05,
					resize: false,
					restore: false),
					count: 1),
					completion: { () -> Void in
						explNodes[1].removeFromParent()
				})
				
		})
	}
	
	func explode() {
		let expl1 = _explodingNode as! SKSpriteNode
		let expl2 = expl1.copy() as! SKSpriteNode

		var nodes = [SKSpriteNode]()
	
		nodes.append(expl1)
		nodes.append(expl2)
		
		self.animateExplosion(nodes)
	}
}
