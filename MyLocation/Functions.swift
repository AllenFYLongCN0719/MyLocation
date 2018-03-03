//
//  Functions.swift
//  MyLocation
//
//  Created by 龙富宇 on 2018/3/3.
//  Copyright © 2018年 AllenLong. All rights reserved.
//

import Foundation

import Dispatch

func afterDelay(_ seconds: Double, closure: @escaping () -> ()) {
    // () -> () 的意思是一个没有参数及返回值的闭包 完整的定义是 (parameter list) -> return type
    // afterDelay()将这个闭包传递给DispatchQueue.main.asyncAfter()
    // @escaping的意思是，闭包的代码不要立即执行。
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
}
