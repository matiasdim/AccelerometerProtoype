//
//  ViewController.swift
//  AccelerometerProtoype
//
//  Created by Matias on 9/14/17.
//  Copyright © 2017 Matias. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    var motionManager: CMMotionManager!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderLabel: UILabel!
    var xData:[Double] = []
    var yData:[Double] = []
    var zData:[Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.motionManager = CMMotionManager()
        self.slider.value = Float(60)
        self.sliderLabel.text = "60"
        self.slider.maximumValue = 100
        self.slider.minimumValue = 0
        self.slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func clearTextView(_ sender: Any) {
        self.textView.text = ""
    }
    
    @IBAction func startPressed(_ sender: Any) {
        //let updateInterval = 0.01 + 0.005 * self.slider.value;
        self.motionManager.accelerometerUpdateInterval = TimeInterval(1/self.slider.value) //1.0 / 60.0  // 60 Hz
        if self.motionManager.isAccelerometerAvailable {
            self.motionManager.startAccelerometerUpdates(to: .main, withHandler: { (accelerometerData, error) in
                guard let data = accelerometerData else{
                    print("No data available")
                    return
                }
                let x = data.acceleration.x
                self.xData.append(x)
                let y = data.acceleration.y
                self.yData.append(y)
                let z = data.acceleration.z
                self.zData.append(z)
                self.textView.text = self.textView.text + "X: \(x) \nY: \(y) \nZ: \(z) \n\n"
                //self.textView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                let range = NSMakeRange(self.textView.text.characters.count - 1, 0)
                self.textView.scrollRangeToVisible(range)
                print("X: \(x) \nY: \(y) \nZ: \(z) \n")
                
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
    
    func compare(x:Double, y:Double, z:Double) -> Bool
    {
        return true
    }
}

