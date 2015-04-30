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
	
	var ship				: SKSpriteNode?
	var texture				: SKTexture?
	var explodingFrames		: [AnyObject]?
	var explodingNode		: SKNode!
	
	override init() {
		super.init()
		
		/* Ship */
		texture = SKTexture(imageNamed: "Spaceship")
		ship = SKSpriteNode(texture: texture)
		ship?.xScale = 0.35
		ship?.yScale = 0.35
			self.addChild(ship!)
		
		/* Explosions */
		var frames					= [AnyObject]()
		let explosionAnimatedAtlas  = SKTextureAtlas(named: "explosion")
		let imageCount				= explosionAnimatedAtlas.textureNames.count
		
		for ( var i = 1; i <= imageCount; ++i ) {
			var name = "slice\(i)_\(i)"
			var temp = explosionAnimatedAtlas.textureNamed(name)
			
			frames.append(temp)
		}
		
		explodingFrames = frames
		
		var temp: SKTexture = explodingFrames![0] as! SKTexture
		explodingNode		= SKSpriteNode(texture: temp)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	func explode() {
		let expl1 = explodingNode.copy() as! SKSpriteNode
		let expl2 = explodingNode.copy() as! SKSpriteNode
		let expl3 = explodingNode.copy() as! SKSpriteNode
		self.addChild(explodingNode)
	}
	
	func animateExplosion (node: SKSpriteNode) {
		node.runAction(SKAction.repeatActionForever (
			SKAction.animateWithTextures (explodingFrames!,
				timePerFrame: 0.1,
				resize: false,
				restore: true)))
	}
}
