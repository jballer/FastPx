//
//  EditorsTimelineViewController.swift
//  FastPX
//
//  Created by Ben Sandofsky on 8/6/14.
//  Copyright (c) 2014 Sandofsky. All rights reserved.
//

import UIKit

class EditorsTimelineViewController: PhotoStreamViewController {

    override var photoStream : PhotoStream! {
        get {
            return self.account.editorsTimeline
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Editors' Choice", comment: "")
    }

}
