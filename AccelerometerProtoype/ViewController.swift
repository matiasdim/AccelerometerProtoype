//
//  ViewController.swift
//  AccelerometerProtoype
//
//  Created by Matias on 9/14/17.
//  Copyright © 2017 Matias. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

struct Constants {
    // Range of Magnitude T
    static let tMax: Double = 2// 8.5
    static let tMin: Double = -2//-8.5
}

class ViewController: UIViewController {
    
    var motionManager: CMMotionManager!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderLabel: UILabel!
    
    var score: Int = 10 // 0, 5 or 10
    var timeCounter = 0
    var isWrong = false
    var penaltyCounter = 0
    var awardCounter = 0
    // This boolean is to avoind a particular sound be played a second time if it alrady was played
    var wrongSoundLastPlayed = false
    
    var wrongSound: AVAudioPlayer!
    var goodSound: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.motionManager = CMMotionManager()
        self.slider.value = Float(60)
        self.sliderLabel.text = "60"
        self.slider.maximumValue = 100
        self.slider.minimumValue = 0
        self.slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        wrongSound = SoundManager.setupSound(wrongSound: false)
        goodSound = SoundManager.setupSound(wrongSound: true)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func clearTextView(_ sender: Any) {
        self.textView.text = ""
    }
    
    @IBAction func startPressed(_ sender: Any) {
        //let updateInterval = 0.01 + 0.005 * self.slider.value;
        self.motionManager.accelerometerUpdateInterval = 1/100 //TimeInterval(1/self.slider.value) //1.0 / 60.0  // 60 Hz
        if self.motionManager.isAccelerometerAvailable {
            self.motionManager.startAccelerometerUpdates(to: .main, withHandler: { (accelerometerData, error) in
                guard let data = accelerometerData else{
                    print("No data available")
                    return
                }
                //let x = data.acceleration.x
                let y = data.acceleration.y
                //let z = data.acceleration.z
                
                self.compare(y: y)
                

            
                
                /*
                self.textView.text = self.textView.text + "X: \(x) \nY: \(y) \nZ: \(z) \n\n"
                //self.textView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                let range = NSMakeRange(self.textView.text.characters.count - 1, 0)
                self.textView.scrollRangeToVisible(range)
                print("X: \(x) \nY: \(y) \nZ: \(z) \n")
                */
            })
        }else {
            let alert = UIAlertController(title: "Alert!", message: "No accelerometerAvailable", preferredStyle: .alert)
            alert.show(self, sender: self)
        }
    }
    @IBAction func stopPressed(_ sender: Any) {
        if self.motionManager.isAccelerometerActive{
            self.motionManager.stopAccelerometerUpdates()
        }
    }
    
    @IBAction func sliderValueChanged(_ slider: UISlider) {
        self.slider.value = self.slider.value
        self.sliderLabel.text = "\(self.slider.value)"
    }
    
    func compare(y:Double) -> Void
    {
        print(y)
       // self.timeCounter += 1
        // General Evaluation is done every 3 seconds
        // Because we run in 1/100 Hz, we are receiving in 300 seconds, 300 reads so when counter is 300, it means tht 3 seconds passed.

            print ("Score is \(self.score)")
            if (y > Constants.tMin && y < Constants.tMax){ // out of range
                self.awardCounter += 1
                if (self.awardCounter > 2){
                    if (self.score != 10){
                        self.score += 5
                    }
                    self.awardCounter = 0
                    self.penaltyCounter = 0
                }
            }else { // in range
                self.penaltyCounter += 1
                // If in the last 3 seconds there are more than 2 wrong read values, reduce score
                if (self.penaltyCounter > 2){
                    if (self.score != 0){
                        self.score -= 5
                    }
                    self.penaltyCounter = 0
                    self.awardCounter = 0
                }
            }
        
        
        /*
        if (self.timeCounter < 299){
            self.timeCounter = 0
            self.penaltyCounter = 0
            self.awardCounter = 0
        }*/
        
        
        // This section validates if the sound that is intended to be played in this point was played the last time a sound was played.
        // if so, then it avoid playing the sound
        if (self.score == 0){
            if (!self.wrongSoundLastPlayed){
                // Sonar mal
                //SoundManager.playSound(wrongSound: true)
                wrongSound.play()
                self.wrongSoundLastPlayed = true
            }
        }else if (self.score == 10){
            if (self.wrongSoundLastPlayed){
                // Sonar bien
                goodSound.play()
                self.wrongSoundLastPlayed = false
            }
        }
        
        
    }
}

