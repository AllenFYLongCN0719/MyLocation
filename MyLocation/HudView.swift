//
//  HudView.swift
//  MyLocation
//
//  Created by 龙富宇 on 2018/2/22.
//  Copyright © 2018年 AllenLong. All rights reserved.
//

import UIKit

class HudView: UIView {
    var text = ""
    
    class func hud(inView view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        return hudView
    }
    
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        let boxRect = CGRect (x: round((bounds.size.width - boxWidth) / 2), y: round((bounds.size.height) / 2), width: boxWidth, height: boxHeight)
        //它是用来代表矩形的结构
        
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        //对绘制矩形的圆角有帮助。只需要输入一个矩形作为参数，再告诉弧度就可以
        
        UIColor(white: 0.3, alpha: 0.8).setFill()
        //设置为灰色，透明度为80%
        
        roundedRect.fill()
    }
}
