//
//  LocationDetailsViewController.swift
//  MyLocation
//
//  Created by 龙富宇 on 2018/1/29.
//  Copyright © 2018年 AllenLong. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

//这个常量时私有的，不能在本文件之外使用它。
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    print("123")
    return formatter
}() //说明这是一个闭包

class LocationDetailsViewController: UITableViewController {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0,longitude: 0)
    var placemark: CLPlacemark?
    
    var categoryName = "No Category"
    
    @IBAction func done() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            //用户可能会在table view内部轻点，而不在单元格内，例如在两个部分之间的某个位置或者text view上。在这种情况下，indexPath将是nil。
            //只有indexpath.section不是0，row不是0的时候，才隐藏小键盘
            return
        }
        
        /* 意思是indexPath为nil或者indexpath不是section为0和row为0时，隐藏小键盘（感叹号处在在表达式前面时，是 非 的意思）
         if indexPath == nil ||
         !(indexPath!.section == 0 && indexPath!.row == 0) {
          descriptionTextView.resignFirstReponder()
         }
         */
        descriptionTextView.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.text = ""
        categoryLabel.text = categoryName
        
        
        latitudeLabel.text = String(format: "%.8f",coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f",coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        dateLabel.text = format(date: Date())
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            gestureRecognizer.cancelsTouchesInView = false
            tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        
        if let s = placemark.subThoroughfare {
            text += s + " "
        }
        if let s = placemark.thoroughfare {
            text += s + ", "
        }
        if let s = placemark.locality {
            text += s + " "
        }
        if let s = placemark.administrativeArea {
            text += s + ", "
        }
        if let s = placemark.postalCode {
            text += s + ", "
        }
        if let s = placemark.country {
            text += s
        }
        return text
    }
    
    //创建format(date)方法
    func format(date: Date) -> String {
        return dateFormatter.string(from:date)
    }
// MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0  {
            return 88
        } else if indexPath.section == 2 && indexPath.row == 2 {
            //1. 改变label的宽度为 正好比界面的宽度少115点，同时使得高为10000.
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            //2. 使标签适应文本的大小
            addressLabel.sizeToFit()
            //3. 调用sizeToFit()会移除掉label右侧和底部的多余的空间。同时也可能改变label的宽度，以便label内部的文本尽可能和label贴近，所以我们需要重新摆放它的位置，正好和界面边缘有15点的空隙。
            //通过改变frame的origin.x属性来实现这个目的。
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            //4. 然后在label的高度上加上20点的余量（顶部10点和底部10点）
            return addressLabel.frame.size.height + 20
            
        } else {
            return 44
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            // section= 0 或者 1时
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            // and
            descriptionTextView.becomeFirstResponder()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }

    
    
}

