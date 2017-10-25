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
    // Range of Amplitude T
    // G force over Y that will tell us how hard the movement is done
    static let positiveTMax: Double = 9
    static let positiveTMin: Double = 8.0
    static let negativeTMin: Double = -9
    static let negativeTMax: Double = -8.0
    // Range for frequency
    // Frequency taken from dataset follows an order of : 1 cycle/ number of measures
    // number of measures to complete a cycle for the dataset, Approx = 22.5
    // Frequency = 1/ 22.5 = 0.4
    static let fMax: Double = 0.06
    static let fMin: Double = 0.02
    static let accInterval = 1/100 // 100 Hz
    //sound Names
    static let finishedFileName = "finished"
    static let goodJobFileName = "goodJob"
    static let okFileName = "ok"
    static let shakeFasterFileName = "shakeFaster"
    static let shakeHarderFileName = "shakeHarder"
    static let thatsItFileName = "thatsIt"
    static let youCanDoBetterFileName = "youCanDoBetter"
}

class ViewController: UIViewController {
    
    var motionManager: CMMotionManager!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderLabel: UILabel!
    
    // For frequency
    // Frequency taken from dataset follows an order of : 1 cycle/ number of measures
    // number of measures to complete a cycle for the dataset, Approx = 22.5
    // Frequency = 1/ 22.5 = 0.4 => It means that needs 22.5 accelerometer lectures to
    var frequencyCounter = 0
    var isPositive = true
    var crossingZero = 0
    
    // To count 3s before beginning analyzing accelerometer data at the beginning
    var secondsToBegin = 0
    // Initial 3 seconds delay timer
    var timer = Timer()
    
    // Global variables
    var globalScore = 0
    var globalMagnitude: (maxVal: Double, minVal: Double) = (0.0, 0.0)
    var globalFrequency: Double = 0
    // Validator timer
    // Every second checks global values (globalMagnitude, globalFrequency) in order to update global score
    // It is invalidated when the globalScores is 60
    var globalTimer = Timer()
    // To save the points of a particular period
    var periodPoints: [Double] = []
    // To save the total time spent
    var totalTime: Int = 0
    // bad moves counter in order to change the sound when bad movements are consecutive
    var wrongMovesCounter = 0
    
    //Sounds instantiations
    var finishedAudio: AVAudioPlayer!
    var goodJobAudio: AVAudioPlayer!
    var okAudio: AVAudioPlayer!
    var shakeFasterAudio: AVAudioPlayer!
    var shakeHarderAudio: AVAudioPlayer!
    var thatsItAudio: AVAudioPlayer!
    var youCanDoBetterAudio: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.motionManager = CMMotionManager()
        self.slider.value = Float(60)
        self.sliderLabel.text = "60"
        self.slider.maximumValue = 100
        self.slider.minimumValue = 0
        self.slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        //Audios inits
        initAudios()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func clearTextView(_ sender: Any) {
        self.textView.text = ""
    }
    func initAudios(){
        finishedAudio = SoundManager.setupSound(soundName: Constants.finishedFileName)
        goodJobAudio = SoundManager.setupSound(soundName: Constants.goodJobFileName)
        okAudio = SoundManager.setupSound(soundName: Constants.okFileName)
        shakeFasterAudio = SoundManager.setupSound(soundName: Constants.shakeFasterFileName)
        shakeHarderAudio = SoundManager.setupSound(soundName: Constants.shakeHarderFileName)
        thatsItAudio = SoundManager.setupSound(soundName: Constants.thatsItFileName)
        youCanDoBetterAudio = SoundManager.setupSound(soundName: Constants.youCanDoBetterFileName)
    }
    
    func doCalculations(value: Double){
        self.frequencyCounter += 1
        periodPoints.append(value)
        
        // Getting notion of the zero-crossing movement to determine the period for the frequency
        if self.frequencyCounter == 1{
            self.isPositive = value > 0 ? true : false
        }else{
            if (self.isPositive && value < 0) {
                self.crossingZero += 1
                self.isPositive = false
            }else if (!self.isPositive && value > 0){
                self.crossingZero += 1
                self.isPositive = true
            }
        }
        
        // if crossingZero is 2 it means that a perio was completed
        if self.crossingZero == 2{
            globalFrequency = 1.0/Double(self.frequencyCounter)
            globalMagnitude.maxVal = periodPoints.max()!
            globalMagnitude.minVal = periodPoints.min()!
            periodPoints.removeAll()
            //print("Completed Period. GLobal variables updated.")
            self.frequencyCounter = 0
            self.crossingZero = 0
        }else if(self.frequencyCounter > 300){ // Not completing a period on 300 reads (3s) so not moving well at all...
            globalMagnitude = (0.0, 0.0)
            globalFrequency = 0
            self.frequencyCounter = 0
            self.crossingZero = 0
            print("Not completing a period in the last 300 reads!!!!!!")
        }
    }
    
    //Checks every second global values to update global score if needed
    @objc func thickHandler() {
        totalTime += 1
        if (globalFrequency <= Constants.fMax && globalFrequency >= Constants.fMin &&
            globalMagnitude.maxVal <= Constants.positiveTMax && globalMagnitude.maxVal >= Constants.positiveTMin &&
            globalMagnitude.minVal <= Constants.negativeTMax && globalMagnitude.minVal >= Constants.negativeTMin)
        {
            wrongMovesCounter = 0
            globalScore += 1
            print("Global score updated -> \(globalScore)")
            goodJobAudio.play()
        }else{
            wrongMovesCounter += 1
            //print("Values are not good")
            if (wrongMovesCounter > 10){
                wrongMovesCounter = 0 // Toonly play "You can do better once"
                youCanDoBetterAudio.play()
            }else{
                if (globalFrequency > Constants.fMax || globalFrequency < Constants.fMin){
                    shakeFasterAudio.play()
                }else{
                    shakeHarderAudio.play()
                }
            }
        }
        if(globalScore == 60)
        {
            print("Finished!!")
            finishedAudio.play()
            globalTimer.invalidate()
            print("Total time needed: \(totalTime)")
            self.motionManager.stopAccelerometerUpdates()
            // ADD HERE ACTION FOR WHEN MOVEMENT IS COMPLETED!!!!
        }
    }
    
    func startGettingData(){
        //let updateInterval = 0.01 + 0.005 * self.slider.value;
        self.motionManager.accelerometerUpdateInterval = TimeInterval(Constants.accInterval)
        if self.motionManager.isAccelerometerAvailable {
            globalTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.thickHandler), userInfo: nil, repeats: true)
            print("Starting getting data...")
            self.motionManager.startAccelerometerUpdates(to: .main, withHandler: { [weak self] (accelerometerData, error) in
                guard let data = accelerometerData else{
                    print("No data available")
                    return
                }
                let y = data.acceleration.y
                // Validations!
                self?.doCalculations(value: y)
                
            })
        }else {
            let alert = UIAlertController(title: "Alert!", message: "No accelerometerAvailable", preferredStyle: .alert)
            alert.show(self, sender: self)
        }
    }
    
    @objc func updateTimer() {
        secondsToBegin += 1
        if(secondsToBegin == 3)
        {
            timer.invalidate()
            self.startGettingData()
        }
    }
    
    @IBAction func startPressed(_ sender: Any) {
        // Hold 3 seconds to begin analyzing data
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
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
}

