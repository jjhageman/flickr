//
//  ViewController.swift
//  Flickr
//
//  Created by Jeremy Hageman on 4/2/15.
//  Copyright (c) 2015 CodePath. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogin(sender: UIButton) {
        FlickrClient.sharedInstance.loginWithCompletion() { (user: User?, error: NSError?) in
            if error != nil {
                println("Login error: \(error)")
            } else {
                println("Logged In")
            }
        }
    }

}

