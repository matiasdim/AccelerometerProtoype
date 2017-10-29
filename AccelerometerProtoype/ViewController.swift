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

extension String {
    var doubleValue: Double {
        return Double(self) ?? 0
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var positiveTMinText: UITextField!
    @IBOutlet weak var positiveTMaxText: UITextField!
    @IBOutlet weak var negativeTMinText: UITextField!
    @IBOutlet weak var negativeTMaxText: UITextField!
    @IBOutlet weak var fMaxText: UITextField!
    @IBOutlet weak var fMinText: UITextField!
    @IBOutlet weak var completionScoreText: UITextField!
    
    var motionManager: CMMotionManager!
    
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
    var initialTimer = Timer()
    
    // Global variables
    var globalScore = 0
    var globalMagnitude: (maxVal: Double, minVal: Double) = (0.0, 0.0)
    var globalFrequency: Double = 0
    // Validator timer
    // Every second checks global values (globalMagnitude, globalFrequency) in order to update global score
    // It is invalidated when the globalScores is equal to completionScore(input from view)
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
    
    // Range of Amplitude T
    // G force over Y that will tell us how hard the movement is done
    var positiveTMax: Double = 0.0
    var positiveTMin: Double = 0.0
    var negativeTMin: Double = 0.0
    var negativeTMax: Double = 0.0
    // Range for frequency
    // Frequency taken from dataset follows an order of : 1 cycle/ number of measures
    // number of measures to complete a cycle for the dataset, Approx = 22.5
    // Frequency = 1/ 22.5 = 0.4
    var fMax: Double = 0.0
    var fMin: Double = 0.0
    
    var completionScore = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.motionManager = CMMotionManager()
        
        //Audios inits
        initAudios()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        if (globalFrequency <= fMax && globalFrequency >= fMin &&
            globalMagnitude.maxVal <= positiveTMax && globalMagnitude.maxVal >= positiveTMin &&
            globalMagnitude.minVal <= negativeTMax && globalMagnitude.minVal >= negativeTMin)
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
                if (globalFrequency > fMax || globalFrequency < fMin){
                    shakeFasterAudio.play()
                }else{
                    shakeHarderAudio.play()
                }
            }
        }
        if(globalScore == completionScore)
        {
            print("Finished!!")
            finishedAudio.play()
            globalTimer.invalidate()
            
            print("Total time needed: \(totalTime)")
            self.motionManager.stopAccelerometerUpdates()
            // Alert showinf results:
            let alert = UIAlertController(title: "Finished!", message: "It took \(totalTime - 3) seconds to achive the needed good shaking time(\(completionScore)s)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func startGettingData(){
        positiveTMin = self.positiveTMinText.text!.doubleValue
        positiveTMax = self.positiveTMaxText.text!.doubleValue
        negativeTMin = self.negativeTMinText.text!.doubleValue
        negativeTMax = self.negativeTMaxText.text!.doubleValue
        fMax = self.fMaxText.text!.doubleValue
        fMin = self.fMinText.text!.doubleValue
        completionScore = Int(self.completionScoreText.text!.doubleValue)
        
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
            initialTimer.invalidate()
            self.startGettingData()
        }
    }
    
    @IBAction func startPressed(_ sender: Any) {
        // Hold 3 seconds to begin analyzing data
        initialTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
    }
    @IBAction func stopPressed(_ sender: Any) {
        if self.motionManager.isAccelerometerActive{
            self.motionManager.stopAccelerometerUpdates()
        }
        globalTimer.invalidate()
        initialTimer.invalidate()

        globalFrequency = 0
        globalMagnitude = (0.0, 0.0)
        frequencyCounter = 0
        isPositive = true
        crossingZero = 0
        secondsToBegin = 0
        globalScore = 0
        periodPoints = []
        totalTime = 0
        wrongMovesCounter = 0

        
        print("Stopped...")
        
    }

}

