//
//  GameScene.swift
//  Space Parkour
//
//  Created by Andreas Kreisl on 25.04.18.
//  Copyright © 2018 Andreas Kreisl. All rights reserved.
//

import SpriteKit
import AVFoundation

var currentScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let spaceshipTexture = SKTexture(imageNamed: "playerShip1_blue")
    let spaceship = SKSpriteNode(imageNamed: "playerShip1_blue")
    var touchTarget = 0 as CGFloat
    var spaceshipDamage = SKSpriteNode(imageNamed: "playerShip1_damage3")
    
    let bulletTexture = SKTexture(imageNamed: "bullet")
    let enemyTexture = SKTexture(imageNamed: "spaceship_enemy_start")

    let background1 = SKSpriteNode(imageNamed: "background")
    let background2 = SKSpriteNode(imageNamed: "background")

    let optionMusic = SKSpriteNode(imageNamed: "194-note-2")
    
    let highScoreLabe = SKLabelNode(fontNamed: "Arial")
    let currentScoreLabe = SKLabelNode(fontNamed: "Arial")
    var highScore = UserDefaults.standard.integer(forKey: "HIGHSCORE")

    var liveNodes = [SKSpriteNode]()
    
    var timerEnemy = Timer()
    var enemyDelay = 3.0
    
    struct physicsBodyNumbers {
        static let spaceshipNumber: UInt32 = 0b1
        static let bulletNumber: UInt32 = 0b10
        static let enemyNumber: UInt32 = 0b100
        static let emptyNumber: UInt32 = 0b1000
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .black
        //self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        spaceship.position = CGPoint(x: self.size.width/2, y: spaceship.size.height*2)
        spaceship.zPosition = 2
        spaceship.physicsBody = SKPhysicsBody(texture: spaceshipTexture, size: spaceship.size)
        //spaceship.physicsBody?.isDynamic = false
        spaceship.physicsBody?.affectedByGravity = false;
        spaceship.physicsBody?.categoryBitMask = physicsBodyNumbers.spaceshipNumber
        spaceship.physicsBody?.collisionBitMask = physicsBodyNumbers.emptyNumber
        spaceship.physicsBody?.contactTestBitMask = physicsBodyNumbers.enemyNumber
        self.addChild(spaceship)
        touchTarget = spaceship.position.x
        
        background1.size = self.size
        background1.anchorPoint = .zero
        background1.position = .zero
        background1.zPosition = -1
        self.addChild(background1)

        background2.size = self.size
        background2.anchorPoint = .zero
        background2.position = .zero
        background2.position.y = background2.size.height - 1
        background2.zPosition = -1
        self.addChild(background2)

        optionMusic.setScale(0.8)
        if audioPlayer.isPlaying {
            optionMusic.color = .red;
        } else {
            optionMusic.color = .green;
        }
        optionMusic.colorBlendFactor = 0.8
        optionMusic.position = CGPoint(x: self.size.width - optionMusic.size.width - 15, y: optionMusic.size.height + 15)
        optionMusic.zPosition = 9
        addChild(optionMusic)
        
        highScoreLabe.fontSize = 16
        highScoreLabe.text = "Highscore: \(highScore)"
        highScoreLabe.zPosition = 6
        highScoreLabe.position = CGPoint(x: self.size.width - highScoreLabe.frame.size.width, y: self.size.height - highScoreLabe.frame.size.height)
        addChild(highScoreLabe)

        currentScore = 0
        currentScoreLabe.fontSize = 16
        currentScoreLabe.text = "Gamescore: \(currentScore)"
        currentScoreLabe.zPosition = 6
        currentScoreLabe.position = CGPoint(x: self.size.width - highScoreLabe.frame.size.width, y: self.size.height - highScoreLabe.frame.size.height * 2)
        addChild(currentScoreLabe)

        
        addLiveToSpaceship(liveNum: 4)
        
        timerEnemy = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (Timer) in
            self.addEnemy()
        })
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let locationUser = touch.location(in: self)
            touchTarget = locationUser.x
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let locationUser = touch.location(in: self)
            touchTarget = locationUser.x
            
            if ((atPoint(locationUser) == spaceship) || (atPoint(locationUser) == spaceshipDamage)) {
                addBulletToSpaceship()
            }

            if atPoint(locationUser) == optionMusic {
                if audioPlayer.isPlaying {
                    optionMusic.color = .red;
                    audioPlayer.pause()
                } else {
                    optionMusic.color = .green;
                    audioPlayer.play()
                }
            }

        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchTarget = spaceship.position.x
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if touchTarget < spaceship.position.x-5 {
            spaceship.position.x -= CGFloat(currentTime/1000)
            if spaceship.position.x < touchTarget {
                spaceship.position.x = touchTarget
            }
            if liveNodes.count < 4 {
                spaceshipDamage.position = spaceship.position
            }
        } else if touchTarget > spaceship.position.x+5 {
            spaceship.position.x += CGFloat(currentTime/1000)
            if spaceship.position.x > touchTarget {
                spaceship.position.x = touchTarget
            }
            if liveNodes.count < 4 {
                spaceshipDamage.position = spaceship.position
            }
        }
        
        background1.position.y -= CGFloat(currentTime/18000)
        background2.position.y -= CGFloat(currentTime/18000)
        if background1.position.y < -background1.size.height {
            background1.position.y = background2.position.y + background2.size.height - 1
        }
        if background2.position.y < -background2.size.height {
            background2.position.y = background1.position.y + background1.size.height - 1
        }
    }
    
    var contactBegin: Bool = true
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
        case physicsBodyNumbers.enemyNumber | physicsBodyNumbers.bulletNumber:
            if contactBegin {
                contactBegin = false
                if (contact.bodyA.categoryBitMask & physicsBodyNumbers.enemyNumber) > 0 {
                    addExplosion(contactPoint: contact.bodyA.node!.position)
                } else {
                    addExplosion(contactPoint: contact.bodyB.node!.position)
                }
                contact.bodyA.node?.removeFromParent()
                contact.bodyB.node?.removeFromParent()
                
                updateCurrentScore(points: 2)
                addEnemy()
            }
        case physicsBodyNumbers.enemyNumber | physicsBodyNumbers.spaceshipNumber:
            if contactBegin {
                contactBegin = false
                addExplosion(contactPoint: contact.bodyB.node!.position)
                contact.bodyB.node?.removeFromParent()
                
                updateCurrentScore(points: 1)
                
                if liveNodes.count > 0 {
                    let liveNode = liveNodes.removeLast()
                    liveNode.removeFromParent()
                    
                    if liveNodes.count <= 0 {
                        gameOver()
                    } else {
                        spaceship.run(SKAction.repeat(SKAction.sequence([
                            SKAction.fadeAlpha(to: 0.1, duration: 0.1),
                            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
                            ]), count: 5))

                        spaceshipDamage.removeFromParent()
                        spaceshipDamage = SKSpriteNode(imageNamed: "playerShip1_damage\(liveNodes.count)")
                        spaceshipDamage.zPosition = 3
                        spaceshipDamage.position = spaceship.position
                        self.addChild(spaceshipDamage)
                        addEnemy()
                    }
                }
            }
        default:
            print("nothing")
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        contactBegin = true
    }
    
    func gameOver() {
        timerEnemy.invalidate()
        self.run(SKAction.wait(forDuration: 0.5)) {
            let transition = SKTransition.doorsCloseHorizontal(withDuration: 2)
            let gScene = MenuScene(size: self.size)
            self.view?.presentScene(gScene, transition: transition)
        }
    }
    
    func addExplosion(contactPoint: CGPoint) {
        let explosion = SKEmitterNode(fileNamed: "enemyFire.sks")!
        explosion.setScale(0.7)
        explosion.position = contactPoint
        explosion.zPosition = 3
        addChild(explosion)
        self.run(SKAction.wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
        self.run(SKAction.playSoundFileNamed("explosion", waitForCompletion: true))
    }
    
    func addBulletToSpaceship() {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.position = spaceship.position
        bullet.zPosition = 1
        bullet.setScale(0.5)
        bullet.physicsBody = SKPhysicsBody(texture: bulletTexture, size: bullet.size)
        bullet.physicsBody?.isDynamic = false
        bullet.physicsBody?.categoryBitMask = physicsBodyNumbers.bulletNumber
        bullet.physicsBody?.collisionBitMask = physicsBodyNumbers.emptyNumber
        //bullet.physicsBody?.contactTestBitMask = physicsBodyNumbers.enemyNumber
        addChild(bullet)
        
        let moveTo = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 2.4)
        let delete = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([moveTo, delete]))
        bullet.run(SKAction.playSoundFileNamed("sfx_laser1", waitForCompletion: true))
    }
    
    func addEnemy() {
        timerEnemy.invalidate()
        var enemyArray = [SKTexture]()
        for index in 1...8 {
            enemyArray.append(SKTexture(imageNamed: "\(index)"))
        }
        let enemy = SKSpriteNode(imageNamed: "spaceship_enemy_start")
        enemy.setScale(0.15)

        enemy.position = CGPoint(x: CGFloat(arc4random_uniform(UInt32(self.size.width - enemy.size.width)) + UInt32(enemy.size.width / 2.0)), y: self.size.height + enemy.size.height)
        enemy.zRotation = CGFloat(Double.pi)
        enemy.physicsBody = SKPhysicsBody(texture: enemyTexture, size: enemy.size)
        //enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.affectedByGravity = false;
        enemy.physicsBody?.categoryBitMask = physicsBodyNumbers.enemyNumber
        enemy.physicsBody?.collisionBitMask = physicsBodyNumbers.emptyNumber
        enemy.physicsBody?.contactTestBitMask = physicsBodyNumbers.spaceshipNumber | physicsBodyNumbers.bulletNumber

        addChild(enemy)
        enemy.run(SKAction.repeatForever(SKAction.animate(with: enemyArray, timePerFrame: 0.1)))
        let moveTo = SKAction.moveTo(y: -enemy.size.height, duration: enemyDelay)
        let delete = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([moveTo, delete])) {
            self.updateCurrentScore(points: -1)
            self.currentScoreLabe.run(
                SKAction.repeat(SKAction.sequence([
                    SKAction.colorize(with: SKColor.red, colorBlendFactor: 0.5, duration: 0.1),
                    SKAction.colorize(with: SKColor.clear, colorBlendFactor: 0.0, duration: 0.1),
                    ])
                    , count: 5)
            )
        }

        if enemyDelay > 0.8 {
            enemyDelay -= 0.01
        }
        timerEnemy = Timer.scheduledTimer(withTimeInterval: enemyDelay, repeats: false, block: { (Timer) in
            self.addEnemy()
        })
    }
    
    func addLiveToSpaceship(liveNum: Int) {
        for index in 0..<liveNum {
            let liveNode = SKSpriteNode(imageNamed: "playerShip1_blue")
            liveNode.anchorPoint = CGPoint(x: 0, y: 1)
            liveNode.setScale(0.3)
            liveNode.position.x = CGFloat(index) * (liveNode.size.width + 3) + 3
            liveNode.position.y = self.size.height - 3
            addChild(liveNode)
            liveNodes.append(liveNode)
        }
    }
    
    func updateCurrentScore(points: Int) {
        currentScore += points;
        currentScoreLabe.text = "Gamescore: \(currentScore)"
        
        if currentScore > highScore {
            highScore = currentScore
            UserDefaults.standard.set(highScore, forKey: "HIGHSCORE")
            highScoreLabe.text = "Highscore: \(highScore)"
        }
        
        if currentScore < 0 {
            gameOver()
        }
    }
    
    
}
