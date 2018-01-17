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
    var updatingLocation = false
    var lastLocationError: Error?
    
    
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
        
        startLocationManager()
        updateLabels()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        //调用updateLabels
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - CLLoctionManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        //将error存储到新的实例变量lastlocationError中
        
        stopLocationManager()
        //如果无法获取用户的位置信息时，应该停止location manager
        updateLabels()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdatelocations \(newLocation)")
        
        //1 如果获得location对象的时间过长，那么就返回一个最近的地址，而不是一个新的位置。
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        //2 判断最新的位置精度是否比
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        //3 决定最后获取的这个位置是否比之前一个更精确并且检查location == nil的情况。
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            //4
            lastLocationError = nil
            location = newLocation
        
            //获取一个位置信息时，把之前的错误信息都清除掉
            updateLabels()
        }
        
        //5 如果获取到的位置的精度，比设定要求的精度还要高，就可以直接退出location manager
        if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
            print("*** We're Done!")
            stopLocationManager()
        }
    
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
            
            let statusMessage: String
            if let error = lastLocationError as? NSError{
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    //首先检查授权信息
                    statusMessage = "Location Services Disable"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                //检查位置服务的开关
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
        }
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            //updatingLocation作用是，在获取位置信息时，用它来改变Get MyLocation按钮的状态，以及message标签的信息，这样用户就可以知道app的工作状态，而不是一无所知
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }

}

