//
//  ViewController.swift
//  Flickr
//
//  Created by Jeremy Hageman on 4/2/15.
//  Copyright (c) 2015 CodePath. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signInButton.layer.cornerRadius = 4
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
                self.performSegueWithIdentifier("loginSegue", sender: self)
            }
        }
    }

}

