//
//  GameScene.swift
//  Space Parkour
//
//  Created by Andreas Kreisl on 25.04.18.
//  Copyright © 2018 Andreas Kreisl. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let spaceshipTexture = SKTexture(imageNamed: "playerShip1_blue")
    let spaceship = SKSpriteNode(imageNamed: "playerShip1_blue")
    var touchTarget = 0 as CGFloat
    
    let bulletTexture = SKTexture(imageNamed: "bullet")
    let enemyTexture = SKTexture(imageNamed: "spaceship_enemy_start")

    let background1 = SKSpriteNode(imageNamed: "background")
    let background2 = SKSpriteNode(imageNamed: "background")

    var audioPlayer = AVAudioPlayer()

    let optionMusic = SKSpriteNode(imageNamed: "194-note-2")
    
    var timerEnemy = Timer()
    
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
        
        let x = Bundle.main.url(forResource: "Broke_For_Free_-_01_-_Night_Owl", withExtension: "mp3")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: x!)
        } catch {
            print("Missing Audio")
        }
        audioPlayer.numberOfLoops = -1
        audioPlayer.volume = 0.7
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        
        optionMusic.setScale(0.8)
        optionMusic.color = .green
        optionMusic.colorBlendFactor = 0.8
        optionMusic.position = CGPoint(x: self.size.width - optionMusic.size.width - 15, y: optionMusic.size.height + 15)
        optionMusic.zPosition = 9
        addChild(optionMusic)
        
        timerEnemy = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (Timer) in
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
            
            if atPoint(locationUser) == spaceship {
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
        } else if touchTarget > spaceship.position.x+5 {
            spaceship.position.x += CGFloat(currentTime/1000)
            if spaceship.position.x > touchTarget {
                spaceship.position.x = touchTarget
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
        case physicsBodyNumbers.enemyNumber | physicsBodyNumbers.bulletNumber:
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            self.run(SKAction.playSoundFileNamed("explosion", waitForCompletion: true))
        case physicsBodyNumbers.enemyNumber | physicsBodyNumbers.spaceshipNumber:

            contact.bodyB.node?.removeFromParent()
            self.run(SKAction.playSoundFileNamed("explosion", waitForCompletion: true))

        default:
            print("nothing")
        }
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
        bullet.physicsBody?.contactTestBitMask = physicsBodyNumbers.enemyNumber
        addChild(bullet)
        
        let moveTo = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 2.4)
        let delete = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([moveTo, delete]))
        bullet.run(SKAction.playSoundFileNamed("sfx_laser1", waitForCompletion: true))
    }
    
    func addEnemy() {
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
        let moveTo = SKAction.moveTo(y: -enemy.size.height, duration: 3)
        let delete = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([moveTo, delete]))

    }
    
    
    
    
    
    
    
    
    
}
