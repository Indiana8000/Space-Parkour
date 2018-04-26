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
    let scoreLabel = SKLabelNode(fontNamed: "Arial")
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .black
        
        playButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        addChild(playButton)
        
        scoreLabel.fontSize = 26
        if currentScore > 0 {
            scoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 100)
            scoreLabel.text = "Gamescore: \(currentScore)"
            addChild(scoreLabel)
        } else if UserDefaults.standard.integer(forKey: "HIGHSCORE") > 0 {
            scoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 + 100)
            scoreLabel.text = "Highscore: \(UserDefaults.standard.integer(forKey: "HIGHSCORE"))"
            addChild(scoreLabel)
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let locationUser = touch.location(in: self)

            if atPoint(locationUser) == playButton {
                startGame()
            }
        }
    }
    
    func startGame() {
        let transition = SKTransition.doorsOpenHorizontal(withDuration: 1.3)
        let gScene = GameScene(size: self.size)
        gScene.scaleMode = .aspectFit
        self.view?.presentScene(gScene, transition: transition)
    }
    
}
