//
//  Light.swift
//  IO
//
//  Created by sphota on 3/7/15.
//  Copyright (c) 2015 Lex Levi. All rights reserved.
//

import Foundation
import SpriteKit

class Light: SKNode {
	
	var light			 : SKSpriteNode?
	var lightFrames		 : [AnyObject]?
	
	/* ALLWAYS make upper dependant weakly retained (Circle already owns Light) */
	
	override init() {
		super.init()
		
		var frames				= [AnyObject]()
		let lightAnimatedAtlas  = SKTextureAtlas(named: "light")
		let imageCount			= lightAnimatedAtlas.textureNames.count
		
		/* Loop through atlas frame */
		for ( var i = 1; i <= imageCount; ++i ) {
			var name = String(i)
			var temp = lightAnimatedAtlas.textureNamed(name)
			
			frames.append(temp)
		}
		
		lightFrames = frames
		
		var temp: SKTexture = lightFrames![0] as! SKTexture
		light = SKSpriteNode(texture: temp)
		// Add light node to main node
		self.addChild(light!)
		
		animateLight()
		
		self.xScale = 0.4
		self.yScale = 0.4
		
		self.physicsBody = SKPhysicsBody(circleOfRadius: light!.size.height / 2)
		self.physicsBody!.dynamic = true
		self.physicsBody!.affectedByGravity = false
		self.physicsBody!.restitution = 1.0
		self.physicsBody!.friction = 0
		self.physicsBody!.linearDamping = 0
		self.physicsBody!.angularDamping = 100
		
		self.light?.color = UIColor(random: true, alpha: 1.0)
	}
	
	func animateLight () {
		light?.runAction(SKAction.repeatActionForever (
						  SKAction.animateWithTextures (lightFrames!,
													    timePerFrame: 0.1,
														resize: false,
														restore: true)))
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}