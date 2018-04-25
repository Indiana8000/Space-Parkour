//
//  GameViewController.swift
//  Space Parkour
//
//  Created by Andreas Kreisl on 25.04.18.
//  Copyright © 2018 Andreas Kreisl. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            let gScene = MenuScene(size: self.view.bounds.size)
            view.presentScene(gScene)
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            //view.showsPhysics = true
        }
    }


    
}
