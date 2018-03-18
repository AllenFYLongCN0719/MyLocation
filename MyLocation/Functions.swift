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
    //以下代码可找到存储Core Data数据的DataModel.sqlite文件
    //创建了一个新的全局变量，其中包含app的documents目录的路径
    let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()
