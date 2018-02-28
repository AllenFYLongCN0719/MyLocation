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
        
        let boxRect = CGRect (x: round((bounds.size.width - boxWidth) / 2), y: round((bounds.size.height - boxHeight) / 2), width: boxWidth, height: boxHeight)
        //它是用来代表矩形的结构
        
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        //对绘制矩形的圆角有帮助。只需要输入一个矩形作为参数，再告诉弧度就可以
        
        UIColor(white: 0.3, alpha: 0.8).setFill()
        //设置为灰色，透明度为80%
        
        roundedRect.fill()
        
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(
                x: center.x - round(image.size.width / 2),
                y: center.y - round(image.size.height / 2) - boxHeight / 8)
            
            image.draw(at: imagePoint)
        }
        
        let attribs = [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16),
            NSAttributedStringKey.foregroundColor: UIColor.white ]
        //字典储存
        
        let textSize = text.size(withAttributes: attribs)
        let textPoint = CGPoint(x: center.x - round(textSize.width / 2),
                                y: center.y - round(textSize.height / 2) + boxHeight / 4)
        text.draw(at:textPoint, withAttributes: attribs)
    }
    
    
}
