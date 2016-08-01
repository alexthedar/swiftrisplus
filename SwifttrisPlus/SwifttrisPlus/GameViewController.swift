//
//  GameViewController.swift
//  SwifttrisPlus
//
//  Created by Alexandar on 7/31/16.
//  Copyright (c) 2016 Alexandar. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    var scene: GameScene!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let skView = view as! SKView
        
        skView.multipleTouchEnabled = false
        
        scene = GameScene(size: skView.bounds.size)
        
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
        
    }


    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
