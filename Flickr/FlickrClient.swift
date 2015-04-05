//
//  FlickrClient.swift
//  Flickr
//
//  Created by Jeremy Hageman on 4/2/15.
//  Copyright (c) 2015 CodePath. All rights reserved.
//

// TODO: Move api creds to plist.
let flickrKey = "3d3f871b83d14ce67ce0053e7caaec6e"
let flickrSecret = "feef26bd826e38aa"

let flickrBaseUrl = NSURL(string: "https://api.flickr.com/services")
let flickrAuthUrl = NSURL(string: "https://www.flickr.com/services/oauth/authorize")

class FlickrClient: BDBOAuth1RequestOperationManager {
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    // Swift class var
    class var sharedInstance: FlickrClient {
        struct Static {
            static let instance = FlickrClient(baseURL: flickrBaseUrl, consumerKey: flickrKey, consumerSecret: flickrSecret)
        }
        return Static.instance
    }
    
    // TODO: DRY up common parameters used on every call in getUserPhotos() and openUrl()
    
    func getUserPhotos(user: User, offset:Int, size:Int, completion: (photos: [Photo]?, error: NSError?) -> ()) {
        if !user.maxPhotosReached {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {

                let uid = user.userId as String!
                let page = (offset < size) ? 1 : ((offset/size) + 1) as Int
                println("> Fetching \(size) photos of page \(page)")
        
                FlickrClient.sharedInstance.GET("rest", parameters: ["method": "flickr.people.getPhotos", "per_page": size, "page": page, "user_id": uid, "api_key": flickrKey, "format": "json", "nojsoncallback": 1], success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                    var photos = Photo.photosWithArray(response["photos"] as NSDictionary)
                    if photos.count < size {
                        user.maxPhotosReached = true
                    }
//                    sleep(1) //for demo effect

                    dispatch_async(dispatch_get_main_queue()) {
                        completion(photos: photos, error: nil)
                    }
                    }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                        println("error getting user photos: \(error.userInfo)")
                        completion(photos: nil, error: error)
                })
            }
        }
    }
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion
        
        // Fetch request token and redirect to  authorization page
        FlickrClient.sharedInstance.requestSerializer.removeAccessToken()
        FlickrClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "myflickrapp://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            let authUrl = NSURL(string: "\(flickrAuthUrl!)?oauth_token=\(requestToken.token)")
            UIApplication.sharedApplication().openURL(authUrl!)
        }) { (error: NSError!) -> Void in
                println("Failed to get request token: \(error)")
                self.loginCompletion?(user: nil, error: error)
        }
    }
    
    func openUrl(url: NSURL) {
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: {(accessToken: BDBOAuth1Credential!) ->
            Void in
            FlickrClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            FlickrClient.sharedInstance.GET("rest", parameters: ["method": "flickr.test.login", "api_key": flickrKey, "format": "json", "nojsoncallback": 1], success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                var user = User(dictionary: response as NSDictionary)
                User.currentUser = user
                self.loginCompletion?(user: user, error: nil)
                }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                    println("error: \(error)")
                    self.loginCompletion?(user: nil, error: error)
            })
            
            }) { (error: NSError!) -> Void in
                println("Failed to receive access token: \(error)")
                self.loginCompletion?(user: nil, error: error)
        }
    }
}
