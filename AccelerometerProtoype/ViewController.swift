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
    static let positiveTMax: Double = 90
    static let positiveTMin: Double = 7.5
    static let negativeTMin: Double = -9
    static let negativeTMax: Double = -7.5
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
    
    // For amplitude on Y axis
    var amplitudeScore: Int = 10 // 0, 5 or 10
    var isWrong = false
    var amplitudePenaltyCounter = 0
    var amplitudeAwardCounter = 0
    // This boolean is to avoin a particular sound to be played a second time if it alrady was played
    var wrongSoundLastPlayed = true
    
    // For frequency
    // Frequency taken from dataset follows an order of : 1 cycle/ number of measures
    // number of measures to complete a cycle for the dataset, Approx = 22.5
    // Frequency = 1/ 22.5 = 0.4 => It means that needs 22.5 accelerometer lectures to
    var frequencyCounter = 0
    var isPositive = true
    var crossingZero = 0
    var freqPenaltyCounter = 0
    var freqAwardCounter = 0
    var freqScore: Int = 10 // 0, 5 or 10
    
    // To count 3s before beginning analyzing accelerometer data at the beginning
    var seconds = 0
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
    
    //SOunds instantiations
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
        finishedAudio = SoundManager.setupSound(wrongSound: true)//
        goodJobAudio = SoundManager.setupSound(wrongSound: true)//Constants.goodJobFileName)
        okAudio = SoundManager.setupSound(wrongSound: true)//Constants.okFileName)
        shakeFasterAudio = SoundManager.setupSound(wrongSound: true)//Constants.shakeFasterFileName)
        shakeHarderAudio = SoundManager.setupSound(wrongSound: true)//Constants.shakeHarderFileName)
        thatsItAudio = SoundManager.setupSound(wrongSound: true)//Constants.thatsItFileName)
        youCanDoBetterAudio = SoundManager.setupSound(wrongSound: true)//Constants.youCanDoBetterFileName)
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
                //self?.compare(value: y)
                self?.calcFrequency(value: y)
                
            })
        }else {
            let alert = UIAlertController(title: "Alert!", message: "No accelerometerAvailable", preferredStyle: .alert)
            alert.show(self, sender: self)
        }
    }
    
    //Checks every second global values to update global score if needed
    @objc func thickHandler() {
        if (globalFrequency <= Constants.fMax && globalFrequency >= Constants.fMin &&
            globalMagnitude.maxVal <= Constants.positiveTMax && globalMagnitude.maxVal >= Constants.positiveTMin &&
            globalMagnitude.minVal <= Constants.negativeTMax && globalMagnitude.minVal >= Constants.negativeTMin)
        {
                globalScore += 1
            print("Global score updated -> \(globalScore)")
        }else{
            print("Values are not good")
        }
        if(globalScore == 5)
        {
            print("Finished!!")
            finishedAudio.play()
            globalTimer.invalidate()
            self.motionManager.stopAccelerometerUpdates()
            // ADD HERE ACTION FOR WHEN MOVEMENT IS COMPLETED!!!!
        }
    }
    
    @IBAction func startPressed(_ sender: Any) {
        // Hold 3 seconds to begin analyzing data
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
    }
    @objc func updateTimer() {
        seconds += 1
        if(seconds == 3)
        {
            timer.invalidate()
            self.startGettingData()
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
    /*
    func compare(value y:Double) -> Void
    {
        print(y)
        // General Evaluation is done every 3 seconds
        // Because we run in 1/100 Hz, we are receiving in 300 seconds, 300 reads so when counter is 300, it means tht 3 seconds passed.

        print ("Score is \(self.amplitudeScore)")
        if (y >= Constants.tMin && y <= Constants.tMax){ // in range
            self.amplitudeAwardCounter += 1
            if (self.amplitudeAwardCounter > 100){
                if (self.amplitudeScore != 10){
                    self.amplitudeScore += 5
                }
                self.amplitudeAwardCounter = 0
                self.amplitudePenaltyCounter = 0
            }
        }else { // out range
            self.amplitudePenaltyCounter += 1
            if (self.amplitudePenaltyCounter > 100){
                if (self.amplitudeScore != 0){
                    self.amplitudeScore -= 5
                }
                self.amplitudePenaltyCounter = 0
                self.amplitudeAwardCounter = 0
            }
        }
        
        // This section validates if the sound that is intended to be played in this point was played the last time a sound was played.
        // if so, then it avoid playing the sound
        if (self.amplitudeScore == 0){
            if (!self.wrongSoundLastPlayed){
                self.playWrongSound()
                print("Bad amplitude in Y!!!!!!!!")
            }
        }else if (self.amplitudeScore == 10){
            if (self.wrongSoundLastPlayed){
                self.playGoodSound()
                print("Good amplitude in Y!!!!!!")
            }
        }
    }
     */
    
    func calcFrequency(value: Double){
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
            print("COmpleted Period. GLobal variables updated.")
            self.frequencyCounter = 0
            self.crossingZero = 0
            /*
            print("SCORE \(self.freqScore)")
            let frequency: Double  = 1.0/Double(self.frequencyCounter)
            if (frequency <= Constants.fMax && frequency >= Constants.fMin){ // in of range
                //print("Frequency in bounds: \(frequency)")
                self.freqAwardCounter += 1
                if (self.freqAwardCounter > 5){
                    if (self.freqScore != 10){
                        self.freqScore += 5
                    }
                    self.freqAwardCounter = 0
                    self.freqPenaltyCounter = 0
                }
            }else{ // out of range
                print("Frequency out bounds: \(frequency)")
                self.freqPenaltyCounter += 1
                if (self.freqPenaltyCounter > 5){
                    if (self.freqScore != 0){
                        self.freqScore -= 5
                    }
                    self.freqPenaltyCounter = 0
                    self.freqAwardCounter = 0
                }
            }
             */
            
            /*
            // This section validates if the sound that is intended to be played in this point was played the last time a sound was played.
            // if so, then it avoid playing the sound
            if (self.freqScore == 0){
                if (!self.wrongSoundLastPlayed){
                    print("Bad frequency!!!!!!")
                    self.playWrongSound()
                }
            }else if (self.freqScore == 10){
                if (self.wrongSoundLastPlayed){
                    print("Good frequency!!!!!")
                    self.playGoodSound()
                }
            }
            self.frequencyCounter = 0
            self.crossingZero = 0
             */
        }else if(self.frequencyCounter > 300){ // Not completing a period on 300 reads (3s) so not moving well at all...
            self.frequencyCounter = 0
            print("Not completing a period in the last 300 reads!!!!!!")
            /*
            self.freqScore = 0
            let frequency: Double  = 1.0/Double(self.frequencyCounter)
            print("Not crossing 0. Frequency: \(frequency)")
            if (!self.wrongSoundLastPlayed){
                self.playWrongSound()
            }
            self.frequencyCounter = 0
            self.crossingZero = 0
             */
        }
    }
}

