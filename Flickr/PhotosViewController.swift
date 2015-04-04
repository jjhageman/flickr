//
//  PhotosViewController.swift
//  Flickr
//
//  Created by Jeremy Hageman on 4/3/15.
//  Copyright (c) 2015 CodePath. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var photos: [Photo] = []
    var refreshControl: UIRefreshControl!
    let photoCellId = "photoCellIdentifier"
    let pageSize = 12
    var loading = false
    
    @IBOutlet weak var logoutButton: UIView!
    @IBOutlet weak var photoView: UITableView!
    @IBOutlet weak var loadingFooter: LoadingFooterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadingFooter.hidden = true
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let logoutTap = UITapGestureRecognizer(target: self, action: Selector("onLogoutTap"))
        self.logoutButton.addGestureRecognizer(logoutTap)
        
        self.photoView.dataSource = self
        self.photoView.delegate = self
        self.photoView.estimatedRowHeight = 320.0
        self.photoView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "fetchPhotos", forControlEvents: UIControlEvents.ValueChanged)
        let dummyTableVC = UITableViewController()
        dummyTableVC.tableView = self.photoView
        dummyTableVC.refreshControl = refreshControl
        
        fetchPhotos(0, size: pageSize)
    }
    
    // TODO: Extract out table updating from data fetch call. Handle the initial tableview load
    // differently than when adding new photos to the end. Only call reloadData() on initial tableview
    // or pull down to refresh. Otherwise use insertRowsAtIndexPaths()
    private func fetchPhotos(offset:Int, size:Int) {
        
        if (!self.loading) {
            self.setLoadingState(true)
        
            FlickrClient.sharedInstance.getUserPhotos(User.currentUser!, offset: offset, size: size, completion: { (photos, error) -> () in
                if error != nil {
                    println("Error fetching tweets: \(error)")
                } else {
                    if photos!.count > 0 {
                        self.photos += photos!
                        self.photoView.reloadData()
                    }
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
                self.refreshControl.endRefreshing()
                self.setLoadingState(false)
            })
        }
    }
    
    private func onLogoutTap() {
        User.currentUser?.logout()
    }
    
    private func setLoadingState(loading:Bool) {
        self.loading = loading
        self.loadingFooter.hidden = !loading
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(photoCellId, forIndexPath: indexPath) as PhotoViewCell
        let photo = self.photos[indexPath.row] as Photo
        
        let placeholder = UIImage(named: "no_photo")
        
        let imageRequestSuccess = {
            (request : NSURLRequest!, response : NSHTTPURLResponse!, image : UIImage!) -> Void in
            cell.photo.image = image;
            cell.photo.alpha = 0
            UIView.animateWithDuration(0.5, animations: {
                cell.photo.alpha = 1.0
            })
            
            cell.photo.setImageWithURL(photo.url)
        }
        let imageRequestFailure = {
            (request : NSURLRequest!, response : NSHTTPURLResponse!, error : NSError!) -> Void in
            NSLog("imageRequrestFailure")
        }
        
        let urlRequest = NSURLRequest(URL: photo.url!)
        
        cell.photo.setImageWithURLRequest(urlRequest, placeholderImage: placeholder, success: imageRequestSuccess, failure: imageRequestFailure)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if ((maximumOffset - currentOffset) <= 320) && !User.currentUser!.maxPhotosReached {
            fetchPhotos(photos.count, size: pageSize)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
