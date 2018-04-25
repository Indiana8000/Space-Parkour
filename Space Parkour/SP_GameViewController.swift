//
//  GameViewController.swift
//  Space Parkour
//
//  Created by Andreas Kreisl on 25.04.18.
//  Copyright © 2018 Andreas Kreisl. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

var audioPlayer = AVAudioPlayer()

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

        let x = Bundle.main.url(forResource: "Broke_For_Free_-_01_-_Night_Owl", withExtension: "mp3")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: x!)
        } catch {
            print("Missing Audio")
        }
        audioPlayer.numberOfLoops = -1
        audioPlayer.volume = 0.7
        audioPlayer.prepareToPlay()
        audioPlayer.currentTime = 50
        audioPlayer.play()
    }

}
