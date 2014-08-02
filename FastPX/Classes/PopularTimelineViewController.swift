//
//  PopularTimelineViewController.swift
//  FastPX
//
//  Created by Ben Sandofsky on 8/2/14.
//  Copyright (c) 2014 Sandofsky. All rights reserved.
//

import UIKit

class PopularTimelineViewController: PhotoStreamViewController {

    override var photoStream : PhotoStream! {
        get {
            return self.account.popularTimeline
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Popular", comment: "")
    }

}
