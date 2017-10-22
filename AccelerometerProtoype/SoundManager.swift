//
//  SoundManager.swift
//  AccelerometerProtoype
//
//  Created by Matias on 10/22/17.
//  Copyright © 2017 Matias. All rights reserved.
//

import UIKit
import AVFoundation

class SoundManager: NSObject {
    
    
    static func setupSound(wrongSound: Bool!) -> AVAudioPlayer{
        var sound: AVAudioPlayer!
        let fileName = wrongSound ? "wrong" : "good"
        let path = Bundle.main.path(forResource: fileName, ofType:"mp3")!
        let url = URL(fileURLWithPath: path)
        do {
            sound = try AVAudioPlayer(contentsOf: url)
            sound.numberOfLoops = 1
            sound.prepareToPlay()
        } catch {
            print("error loading file")
            // couldn't load file :(
        }
        return sound
    }
    
    

}
