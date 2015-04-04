//
//  PhotosViewController.swift
//  Flickr
//
//  Created by Jeremy Hageman on 4/3/15.
//  Copyright (c) 2015 CodePath. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UITableViewDataSource {

    var photos: [Photo]?
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var logoutButton: UIView!
    @IBOutlet weak var photoView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let logoutTap = UITapGestureRecognizer(target: self, action: Selector("onLogoutTap"))
        self.logoutButton.addGestureRecognizer(logoutTap)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "fetchPhotos", forControlEvents: UIControlEvents.ValueChanged)
        let dummyTableVC = UITableViewController()
        dummyTableVC.tableView = self.photoView
        dummyTableVC.refreshControl = refreshControl
        
        fetchPhotos()
    }
    
    private func fetchPhotos() {
        FlickrClient.sharedInstance.getUserPhotos(User.currentUser!, completion: { (photos, error) -> () in
            if error != nil {
                println("Error fetching tweets: \(error)")
            } else {
                self.photos = photos
                self.photoView?.reloadData()
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            }
            self.refreshControl.endRefreshing()
        })
    }
    
    private func onLogoutTap() {
        User.currentUser?.logout()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let array = photos {
            return (array.count > 20) ? 20 : array.count
        } else {
            return 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
