//
//  LCAObject.swift
//  health_news
//
//  Created by mac on 2017/10/11.
//  Copyright © 2017年 com.cnlod.cn. All rights reserved.
//

import UIKit

open class LCAObject: NSObject{
    //MARK:将服务器返回的json对象转化为Data
   open var data:Data?
    public override init() {
        super.init()
    }
    
    override open func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    override open func value(forUndefinedKey key: String) -> Any? {
        //NSObject无法处理int类型
        if let data = data {
            do {
                if let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any] {
                    let result  = dict[key] as? Int
                    return result
                }
            }catch {
            }
        }
        print("必须给LCAObject的属性data赋值")
        assertionFailure("必须给LCAObject的属性data赋值")
        return nil
    }
}

