//
//  Photo.swift
//  FastPX
//
//  Created by Ben Sandofsky on 8/2/14.
//  Copyright (c) 2014 Sandofsky. All rights reserved.
//

import UIKit
import CoreData
import CoreGraphics
import QuartzCore

let PhotoEntityName = "Photo"

let PhotoDidUpdateNotification = "PhotoDidUpdateNotification"

class Photo: NSManagedObject {
    @NSManaged var name : String
    @NSManaged var imageURL : String
    @NSManaged var photoID : String
    @NSManaged var imageData : NSData?
    func updateWithDictionary(dictionary : NSDictionary){
        self.name = dictionary["name"] as String
        self.imageURL = dictionary["image_url"] as String
        self.photoID = (dictionary["id"] as NSNumber).stringValue
    }

    // MARK: - Image Loading

    private var _image : UIImage?
    var image : UIImage? {
        get {
            if _image != nil {
                return _image
            } else {
                if self.imageData != nil {
                    _image = UIImage(data: self.imageData!)
                    return _image
                } else {
                    if let account = AccountManager.sharedManager.accountForContext(self.managedObjectContext) {
                        account.api.downloadPhotoWithURL(self.imageURL) {
                            (success, error, image) in
                            if image != nil {
                                let multiplier = 640.0 / image!.size.width
                                let newSize = CGSize(width: 640.0, height: image!.size.height * multiplier)
                                UIGraphicsBeginImageContext(newSize)
                                let ctx = UIGraphicsGetCurrentContext()
                                CGContextSaveGState(ctx)
                                CGContextTranslateCTM(ctx, 0, newSize.height)
                                CGContextScaleCTM(ctx, 1.0, -1.0)
                                CGContextDrawImage(ctx, CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height), image?.CGImage)
                                CGContextRestoreGState(ctx)
                                let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
                                UIGraphicsEndImageContext()
                                self.imageData = UIImagePNGRepresentation(scaledImage)
                                self._image = scaledImage
                                let moc = self.managedObjectContext
                                moc.performBlock {
                                    moc.save(nil)
                                    NSNotificationCenter.defaultCenter().postNotificationName(PhotoDidUpdateNotification, object: self)
                                }
                            }
                        }
                    }
                    return nil
                }
            }
        }
    }
}
