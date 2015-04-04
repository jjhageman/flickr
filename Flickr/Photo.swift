//
//  Photo.swift
//  Flickr
//
//  Created by Jeremy Hageman on 4/3/15.
//  Copyright (c) 2015 CodePath. All rights reserved.
//


class Photo: NSObject {
    var id: String?
    var url: NSURL?
    var title: String?
    
    init(dictionary: NSDictionary) {
        super.init()
        
        println(dictionary)
        self.id = dictionary["id"] as? String
        self.title = dictionary["title"] as? String
        let farmId = dictionary["farm"] as? Int
        let serverId = dictionary["server"] as? String
        let photoId = dictionary["id"] as? String
        let secret = dictionary["secret"] as? String
        self.url = self.generateUrl(farmId!, serverId: serverId!, photoId: photoId!, secret: secret!)
    }
    
    class func photosWithArray(dictionary: NSDictionary) -> [Photo] {
        var photos = [Photo]()
        
        if let photoDicts = dictionary["photo"] as? [NSDictionary] {
            for photo in photoDicts {
                photos.append(Photo(dictionary: photo))
            }
        }
        
        return photos
    }
    
    private func generateUrl(farmId: Int, serverId: String, photoId: String, secret: String) -> NSURL {
        return NSURL(string: "https://farm\(farmId).staticflickr.com/\(serverId)/\(photoId)_\(secret).jpg")!
    }
}
