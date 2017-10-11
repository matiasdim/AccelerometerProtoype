//
//  ViewController.swift
//  AccelerometerProtoype
//
//  Created by Matias on 9/14/17.
//  Copyright © 2017 Matias. All rights reserved.
//

import UIKit
import CoreMotion

struct Matrix {
    let rows: Int, columns: Int
    var grid: [Double]
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: 0.0, count: rows * columns)
    }
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    subscript(row: Int, column: Int) -> Double {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}

class ViewController: UIViewController {
    
    var count:Int = 0
    var differenceInterval: Double = 2.0
    var xComparingData:[Double] = [0.0116119384765625, 0.0102386474609375, 0.0152130126953125, 0.0111541748046875, 0.0108184814453125, 0.010772705078125, 0.0102996826171875, 0.0105743408203125, 0.01104736328125, 0.011199951171875, 0.0115509033203125, 0.0103912353515625, 0.0107269287109375, 0.0108795166015625, 0.010894775390625, 0.0111083984375, 0.0108642578125, 0.010223388671875, 0.0104522705078125, 0.010467529296875, 0.0108642578125, 0.0106201171875, 0.0107879638671875, 0.0103607177734375, 0.0110931396484375, 0.0110015869140625, 0.010833740234375, 0.0104217529296875, 0.01043701171875]
    var yComparingData:[Double] = [0.01861572265625, 0.01922607421875, 0.020904541015625, 0.018585205078125, 0.0198974609375, 0.01947021484375, 0.0192413330078125, 0.018951416015625, 0.019012451171875, 0.0182342529296875, 0.0186767578125, 0.0197296142578125, 0.0199127197265625, 0.0195465087890625, 0.0198974609375, 0.0184478759765625, 0.0200653076171875, 0.0188446044921875, 0.0198211669921875, 0.0194854736328125, 0.018585205078125, 0.01934814453125, 0.0185089111328125, 0.01873779296875, 0.0194549560546875, 0.019256591796875, 0.018463134765625, 0.018951416015625, 0.0182647705078125]
    var zComparingData:[Double] = [-0.988616943359375, -0.988815307617188, -1.00791931152344, -0.988723754882812, -0.98822021484375, -0.988555908203125, -0.98895263671875, -0.9874267578125, -0.98846435546875, -0.987960815429688, -0.987945556640625, -0.988021850585938, -0.988449096679688, -0.988677978515625, -0.989181518554688, -0.988388061523438, -0.98834228515625, -0.987884521484375, -0.988418579101562, -0.989044189453125, -0.988082885742188, -0.987625122070312, -0.987655639648438, -0.987640380859375, -0.988494873046875, -0.991912841796875, -0.993118286132812, -0.988082885742188, -0.985519409179688]
    
    var motionManager: CMMotionManager!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderLabel: UILabel!
    
    let arrayX: [Int] = [1,6,2,3,0,9,4,3,6,3]
    let arrayY: [Int] = [1,3,4,9,8,2,1,5,7,3]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.motionManager = CMMotionManager()
        self.slider.value = Float(60)
        self.sliderLabel.text = "60"
        self.slider.maximumValue = 100
        self.slider.minimumValue = 0
        self.slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        var matrix = calc()


    }
    
    func calc() -> Matrix{
        var matrix = Matrix(rows: arrayY.count, columns: arrayX.count)
        
        for i in 1...arrayY.count {
            matrix[i,0] = Double.infinity
        }
        for j in 1...arrayX.count {
            matrix[0,j] = Double.infinity
        }
        matrix[0,0] = 0
        
        var cost:Double = 0
        for i in 1...arrayY.count{
            for j in 1...arrayX.count{
                // Cost is abs value of x - y ---> |x-y|
                cost = Double(abs(arrayY[i] - arrayX[j]))
                matrix[i,j] = cost + getMinimum(a: matrix[i-1,j], b: matrix[i,j-1], c: matrix[i-1,j-1])
            }
        }
        return matrix
    }
    
    func getMinimum(a:Double, b:Double, c:Double) -> Double{
        if (a > b){
            if (a > c){
                return a;
            }else{
                return c;
            }
        }else{
            if (b > c){
                return b
            }else{
                return c;
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func clearTextView(_ sender: Any) {
        self.textView.text = ""
    }
    
    @IBAction func startPressed(_ sender: Any) {
        count = 0
        //let updateInterval = 0.01 + 0.005 * self.slider.value;
        self.motionManager.accelerometerUpdateInterval = 1/1 //TimeInterval(1/self.slider.value) //1.0 / 60.0  // 60 Hz
        if self.motionManager.isAccelerometerAvailable {
            self.motionManager.startAccelerometerUpdates(to: .main, withHandler: { (accelerometerData, error) in
                guard let data = accelerometerData else{
                    print("No data available")
                    return
                }
                let x = data.acceleration.x
                let y = data.acceleration.y
                let z = data.acceleration.z
                
                let notWrong = self.compare(x: x, y: y, z: z)
                
                if !notWrong{ self.count = 0 }
                
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
        if xComparingData.indices.contains(count) && yComparingData.indices.contains(count) && zComparingData.indices.contains(count){
            
            if (xComparingData[count] < x + 1 && x - 1  < xComparingData[count]) &&
                (yComparingData[count] < y + 1 && y - 1  < yComparingData[count]) &&
                (zComparingData[count] < z + 1 && z - 1  < zComparingData[count])
            {
                print (count)
                count += 1
                return true
            }
        }else{
            return true
        }
        print("Wrong move!")
        return false
    }
}

