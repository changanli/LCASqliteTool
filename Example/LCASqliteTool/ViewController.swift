//
//  ViewController.swift
//  LCASqliteTool
//
//  Created by 931985308@qq.com on 10/11/2017.
//  Copyright (c) 2017 931985308@qq.com. All rights reserved.
//

import UIKit
import LCASqliteTool

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
      let result =  LCASqliteToolAPI.deleteAll(uid: nil)
        
        if result {
            print("清除缓存陈宫")
        }else {
            print("失败")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
