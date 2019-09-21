//
//  SwiftDefine.swift
//  vs
//
//  Created by Xie Shu on 2017/7/20.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

import UIKit

open class SwiftDefine: NSObject {
    class func RGB(_ r:CGFloat,g:CGFloat,b:CGFloat) ->UIColor{
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
    class func RGB_CLEAR(_ r:CGFloat,g:CGFloat,b:CGFloat, d:CGFloat) ->UIColor{
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: d)
    }
    open class func kSwiftTableViewColor() -> UIColor {
        return RGB(243, g: 243, b: 243)
    }
    open class func kSwiftTableCellSepViewColor() -> UIColor {
        return RGB(231, g: 231, b: 231)
    }
    open class func KMapWhiteBg() -> UIColor {
        return RGB_CLEAR(255, g: 255, b: 255, d: 0.7)
    }
    
    open class func isX() -> Bool {
        
        if UIScreen.main.bounds.height == 812 || UIScreen.main.bounds.height == 896 {
            
            return true
            
        }
        
        return false
        
    }
}
