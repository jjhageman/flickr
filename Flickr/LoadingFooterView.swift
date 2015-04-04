//
//  LoadingFooterView.swift
//  Flickr
//
//  Created by Jeremy Hageman on 4/4/15.
//  Copyright (c) 2015 CodePath. All rights reserved.
//

import Foundation
import UIKit

class LoadingFooterView: UIView {
    
    override var hidden:Bool {
        get {
            return super.hidden
        }
        set(hidden) {
            super.hidden = hidden
        }
    }

    override func awakeFromNib() {
//        self.activityIndicator.startAnimating()
    }

}
