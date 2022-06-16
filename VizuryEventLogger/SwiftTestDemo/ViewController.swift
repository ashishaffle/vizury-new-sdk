//
//  ViewController.swift
//  SwiftTestDemo
//
//  Created by Ashish on 29/05/22.
//  Copyright © 2022 Chowdhury Md Rajib  Sarwar. All rights reserved.
//

import UIKit
import VizuryEventLogger

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributeDictionary = NSDictionary(dictionary: ["productid" : "AKSJDASNBD",
                                                                 "productPrice": "789",
                                                                 "category": "Shirt"])
             DispatchQueue.main.async {
                 VizuryEventLogger.logEvent("productPage", withAttributes: attributeDictionary as? [AnyHashable : Any])
             }
        // Do any additional setup after loading the view.
    }


}

