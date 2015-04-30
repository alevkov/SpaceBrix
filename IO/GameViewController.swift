//
//  GameViewController.swift
//  IO
//
//  Created by sphota on 3/4/15.
//  Copyright (c) 2015 Lex Levi. All rights reserved.
//

import UIKit
import SpriteKit



final class GameViewController: UIViewController {
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		
		if MotionManager.sharedInstance.motionManager.accelerometerAvailable == true {
			MotionManager.sharedInstance.motionManager.accelerometerUpdateInterval = 0.01
			MotionManager.sharedInstance.motionManager.startAccelerometerUpdates()
		}

		let scene = Menu(size: self.view.frame.size)
		let skView = self.view as! SKView
		skView.showsFPS = true
		skView.showsNodeCount = true
		skView.ignoresSiblingOrder = true
		
		/* Scale to fit the window */
		scene.scaleMode = .AspectFill
		
		skView.presentScene(scene)
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
