//
//  FirstViewController.swift
//  MyLocation
//
//  Created by 龙富宇 on 2018/1/7.
//  Copyright © 2018年 AllenLong. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longtitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    var location: CLLocation?
    //将用户目前的位置存放在整个变量里
    
    let locationManager = CLLocationManager()
    
    @IBAction func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        //检查目前的许可状态，如果时禁止访问位置信息的话，app会字啊用户使用时进行许可请求
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - CLLoctionManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdatelocations \(newLocation)")
        location = newLocation
        updateLabels()
    }
    
    func showLocationServicesDeniedAlert() {
        //这个弹出窗口会展示一条有用的信息，如果无法获取位置信息的话，这个app就是无用的，所以应该鼓励用户打开location服务的授权
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert,animated: true,completion: nil)
    }
    
    func updateLabels(){
        if let location = location {
            //location实例变量是可选型，所以你使用if let语句来对它进行解包
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            //%.8f是格式说明符，而字符串中插入的值就是location.coordinate.latitude.
            //%d用于整数，%f用于浮点数，%@用于任意对象
            //这里%.8f与%f作用一样，都是将浮点数放入字符串中，.8的意思是该浮点数仅保留8位小数
            longtitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
        } else {
            latitudeLabel.text = ""
            longtitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            messageLabel.text = "Tap 'Get My Location' to start"
        }
    }

}

