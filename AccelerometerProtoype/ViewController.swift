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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.motionManager = CMMotionManager()
        self.slider.value = 60
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    @IBAction func clearTextView(_ sender: Any) {
        self.textView.text = ""
    }
    
    @IBAction func startPressed(_ sender: Any) {
        let updateInterval = 0.01 + 0.005 * self.slider.value;
        self.motionManager.accelerometerUpdateInterval = updateInterval //1.0 / 60.0  // 60 Hz
        if self.motionManager.isAccelerometerAvailable {
            self.motionManager.startAccelerometerUpdates(to: .main, withHandler: { (accelerometerData, error) in
                guard let data = accelerometerData else{
                    print("No data available")
                    return
                }
                let x = data.acceleration.x
                let y = data.acceleration.y
                let z = data.acceleration.z
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
}

