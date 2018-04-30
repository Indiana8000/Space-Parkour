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
var currentScore = 0


class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        if let view = self.view as! SKView? {
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsPhysics = true

            let mScene = MenuScene(size: CGSize(width: 320, height: 568))
            mScene.scaleMode = .aspectFit
            view.presentScene(mScene)
        }

        let musicFile = Bundle.main.url(forResource: "Broke_For_Free_-_01_-_Night_Owl", withExtension: "mp3")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: musicFile!)
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
