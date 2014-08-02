//
//  PhotoCellTableViewCell.swift
//  FastPX
//
//  Created by Ben Sandofsky on 8/3/14.
//  Copyright (c) 2014 Sandofsky. All rights reserved.
//

import UIKit

class PhotoCellTableViewCell: UITableViewCell {

    var photoImageView: UIImageView

    var photo: Photo! {
        willSet(newPhoto){
            if (self.photo != nil) {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: PhotoDidUpdateNotification, object: self.photo)
            }
            weak var weakSelf : PhotoCellTableViewCell? = self
            if (newPhoto != nil) {
                NSNotificationCenter.defaultCenter().addObserverForName(PhotoDidUpdateNotification, object: newPhoto, queue: NSOperationQueue.mainQueue()) {
                    notification in
                    if let strongSelf = weakSelf {
                        strongSelf.updatePhoto()
                    }
                }
            }
        }
        didSet{
            self.updatePhoto()
        }
    }

    func updatePhoto(){
        self.photoImageView.image = self.photo?.image
    }

    required init(coder aDecoder: NSCoder!) {
        self.photoImageView = UIImageView(frame: CGRectZero)
        super.init(coder: aDecoder)
        self.finishInitialization()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.photoImageView.frame = self.contentView.bounds
    }

    private func finishInitialization() {
        self.photoImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.photoImageView.clipsToBounds = true
        self.contentView.addSubview(self.photoImageView)
        self.photoImageView.backgroundColor = UIColor.blackColor()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String) {
        self.photoImageView = UIImageView(frame: CGRectZero)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.finishInitialization()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
