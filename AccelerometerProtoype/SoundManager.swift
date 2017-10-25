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
    
    static func setupSound(soundName: String) -> AVAudioPlayer{
        var sound: AVAudioPlayer!
        let path = Bundle.main.path(forResource: soundName, ofType:"mp3")!
        let url = URL(fileURLWithPath: path)
        do {
            sound = try AVAudioPlayer(contentsOf: url)
            sound.numberOfLoops = 0
            sound.prepareToPlay()
        } catch {
            print("error loading file")
            // couldn't load file :(
        }
        return sound
    }
    
    /*
    static func setupSound(soundName: String) -> AVAudioPlayer?{
        var player: AVAudioPlayer?
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return nil}
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            //player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            // iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return nil}
            player.numberOfLoops = 1
            player.prepareToPlay()
            
        } catch let error {
            print(error.localizedDescription)
        }
        return player
/*
        var sound: AVAudioPlayer!        
        let path = Bundle.main.path(forResource: soundName, ofType:"mp3")!
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
 */
        */
}
    
    


