//
//  ViewController.swift
//  CircularPager
//
//  Created by vromano84 on 01/24/2019.
//  Copyright (c) 2019 vromano84. All rights reserved.
//

import UIKit
import CircularPager

class ViewController: CircularPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.viewControllers = ["one", "two", "three"];
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

