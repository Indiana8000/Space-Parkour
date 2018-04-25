//
//  SP_MenuScene.swift
//  Space Parkour
//
//  Created by Andreas Kreisl on 25.04.18.
//  Copyright © 2018 Andreas Kreisl. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    let playButton = SKSpriteNode(imageNamed: "play_buttons")
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .black
        
        playButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        addChild(playButton)
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let locationUser = touch.location(in: self)

            if atPoint(locationUser) == playButton {
                let transition = SKTransition.doorsCloseHorizontal(withDuration: 2)
                let gScene = GameScene(size: self.size)
                self.view?.presentScene(gScene, transition: transition)
            }
        }
    }
}
