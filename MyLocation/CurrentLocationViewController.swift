//
//  FirstViewController.swift
//  MyLocation
//
//  Created by 龙富宇 on 2018/1/7.
//  Copyright © 2018年 AllenLong. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData


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
    
    //地址解析
    let geocoder = CLGeocoder()
    var placemarks: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    var timer: Timer?
    
    var managedObjectContext: NSManagedObjectContext!
    
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
        
        //给stop按键提供功能
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemarks = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
        configureGetButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemarks
            
            controller.managedObjectContext = managedObjectContext
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetButton()
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
        configureGetButton()
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
        
        //计算新的位置和上一个位置之间的距离差值。可以使用这个差值来判断我们的位置是不是再继续提高精度
        var distance = CLLocationDistance(Float.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
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
            configureGetButton()
            
            //当最后一个地址是你能够找到的精度最高的地址时，这个时候需要跳过仍然在执行的地址解析。
            if distance > 0 {
                performingReverseGeocoding = false
                //设置为false，强制的将最后一个坐标进行抵制解析。
            }
        }
        
        if !performingReverseGeocoding {
            //当调用(didUpdateLocations)方法时，闭包中代码并不是立即执行
            print("*** Going to geocode")
            performingReverseGeocoding = true
            geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
                //闭包
                placemarks,error in
                print("*** Found placemarks:\(placemarks),error:\(error)")
                self.lastLocationError = error
                if error == nil, let p = placemarks, !p.isEmpty {
                // if there's no error and the unwrapped placemarks arrary is not empty
                    //如果这里没有报错并且解包后的placemarks不为空
                    self.placemarks = p.last!
                    //获取数组中的最后一条CLPlacemark对象
                } else {
                    self.placemarks = nil
                }
                self.performingReverseGeocoding = false
                self.updateLabels()
            })
            
            //如果当前读取到的左边和上一个差距不大，并且这种情况维持了10秒，就强制停止location manager
        } else if distance < 1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {
                print("***Force done!")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
    
    }
    func showLocationServicesDeniedAlert() {
        //这个弹出窗口会展示一条有用的信息，如果无法获取位置信息的话，这个app就是无用的，所以应该鼓励用户打开location服务的授权
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert,animated: true,completion: nil)
    }
    
    func string(from placemarks: CLPlacemark) -> String {
        //1 为第一行文本创建一个新的String型变量
        var line1 = ""
        //2 如果placemark有一个子街道，就把它添加到字符串中。z
        if let s = placemarks.subThoroughfare {
            line1 += s + ""
        }
        //3 把街道名称添加进字符串。
        if let s = placemarks.thoroughfare {
            line1 += s
        }
        //4 穿件一个新的变量 保存城市，省份，以及邮政编码
        var line2 = ""
        
        if let s = placemarks.locality {
            line2 += s + " "
        }
        
        if let s = placemarks.administrativeArea {
            line2 += s + " "
        }
        
        if let s = placemarks.postalCode {
            line2 += s
        }
        
        //5 把两个字符串拼接为一个字符串，\n的意思是换行
        return line1 + "\n" + line2
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
            
            if let placemark = placemarks {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text =  "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
            
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
            
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
            //新的一行设置了一个timer对象，用于60秒后发送"didTimeOut"信息给它自己，didTimeOut是一个方法。
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            //updatingLocation作用是，在获取位置信息时，用它来改变Get MyLocation按钮的状态，以及message标签的信息，这样用户就可以知道app的工作状态，而不是一无所知
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            //当location manager在超出时间前就被停止的情况下，你必须取消掉timer。这个情况发生在一分钟内已经获得了精度足够的位置的情况下，或者用户在不到一分钟的时候点击了stop按钮
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get MyLocation", for: .normal)
        }
    }
    
    //使用#selector(didTimeOut)时，需要在func didTimeOut()前添加 @objc
    @objc func didTimeOut() {
        print("*** Time Out")
        
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationErrorDomain", code: 1, userInfo: nil)
            updateLabels()
            configureGetButton()
        }
    }


}

