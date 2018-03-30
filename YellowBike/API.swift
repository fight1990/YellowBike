//
//  API.swift
//  YellowBike
//
//  Created by butcher on 2018/3/28.
//  Copyright © 2018年 butcher. All rights reserved.
//

import Foundation

let AMapKey = "4a59f16b24f8b9340e1c1c2736d845f7"

let iphoneX = UIScreen.instancesRespond(to:#selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width:1125,height:2436), (UIScreen.main.currentMode?.size)!) : false

let bottomHeight = (iphoneX ? 34.0 : 0.0)
