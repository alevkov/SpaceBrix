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
		ship?.xScale = 0.5
		ship?.yScale = 0.5
			self.addChild(ship!)
		
		/* Explosions */
		var frames					= [AnyObject]()
		let explosionAnimatedAtlas  = SKTextureAtlas(named: "explosion")
		let imageCount				= explosionAnimatedAtlas.textureNames.count
		
		for ( var i = 1; i <= imageCount; ++i ) {
			var name = "0\(i)"
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
		let expl1 = explodingNode as! SKSpriteNode
		let expl2 = expl1.copy() as! SKSpriteNode

		var nodes = [SKSpriteNode]()
	
		nodes.append(expl1)
		nodes.append(expl2)
		
		animateExplosion(nodes)
	}
	
	func animateExplosion (node: [SKSpriteNode]) {
		node[0].position.x = self.position.x + CGFloat(arc4random_uniform(50))
		node[0].position.y = self.position.y
		
		node[0].xScale = 0.5
		node[0].yScale = 0.5
		
		node[1].xScale = 0.5
		node[1].yScale = 0.5

		self.parent!.addChild(node[0])
		
		/* fist explosion */
		node[0].runAction(SKAction.repeatAction(SKAction.animateWithTextures (explodingFrames!,
			timePerFrame: 0.05,
			resize: false,
			restore: false),
			count: 1),
			completion: { () -> Void in
				node[0].removeFromParent()
				
				/* second explosion */
				node[1].position.x = self.position.x - CGFloat(arc4random_uniform(50))
				node[1].position.y = self.position.y
				self.parent!.addChild(node[1])
				
				node[1].runAction(SKAction.repeatAction(SKAction.animateWithTextures (self.explodingFrames!,
				timePerFrame: 0.05,
				resize: false,
				restore: false),
				count: 1),
				completion: { () -> Void in
					node[1].removeFromParent()
				})

		})
		
		
	}
}
