//
//  User.swift
//  Flickr
//
//  Created by Jeremy Hageman on 4/2/15.
//  Copyright (c) 2015 CodePath. All rights reserved.
//

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject {
    var userId: String?
    var userName: String?
    var userDictionary: NSDictionary
    var maxPhotosReached = false
    
    init(dictionary: NSDictionary) {
        self.userDictionary = dictionary
        
        if let userAttrs = self.userDictionary["user"] as NSDictionary? {
            self.userId = userAttrs["id"] as? String
            if let uname = userAttrs["username"] as NSDictionary? {
                self.userName = uname["_content"] as? String
            }
        }
    }
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                var data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
                if data != nil {
                    var dictionary = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: nil) as NSDictionary
                   _currentUser = User(dictionary: dictionary)
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            
            if _currentUser != nil {
                var data = NSJSONSerialization.dataWithJSONObject(user!.userDictionary, options: nil, error: nil)
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
            
        }
    }
    
    func logout() {
        User.currentUser = nil
        FlickrClient.sharedInstance.requestSerializer.removeAccessToken()
        
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    }
}