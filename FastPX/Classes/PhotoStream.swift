//
//  PhotoStream.swift
//  FastPX
//
//  Created by Ben Sandofsky on 8/2/14.
//  Copyright (c) 2014 Sandofsky. All rights reserved.
//

import Foundation
import CoreData

let PhotoStreamDidUpdateNotification = "PhotoStreamDidUpdateNotification"

class PhotoStream: NSObject {
    private var isLoadingNewer : Bool
    private var isLoadingOlder : Bool
    var entries : [PhotoStreamEntry]
    weak var account : Account?
    var streamType : RestAPI.PhotoStreamType
    init(account:Account, streamType:  RestAPI.PhotoStreamType) {
        entries = Array()
        isLoadingNewer = false
        isLoadingOlder = false
        self.account = account
        self.streamType = streamType
    }

    func loadNewer(){
        self.account?.api.photos(self.streamType) {
            (success, error, photosDictionaryResponse) in
            if success {
                if let ctx = self.account?.managedObjectContext {
                    ctx.performBlock {
                        // Let's purge for now
                        let fetch = NSFetchRequest(entityName: PhotoStreamEntryEntityName)
                        fetch.sortDescriptors = [NSSortDescriptor(key: "position", ascending: false)]
                        for object in ctx.executeFetchRequest(fetch, error: nil) {
                            let entry = object as PhotoStreamEntry
                            ctx.deleteObject(entry)
                        }
                        let photosArray = photosDictionaryResponse!["photos"] as NSArray
                        var photoIDs : [String] = []
                        for object in photosArray {
                            let photoDict = object as NSDictionary
                            photoIDs.append((photoDict["id"] as NSNumber).stringValue)
                        }
                        let photosToDeleteFetch = NSFetchRequest(entityName: PhotoEntityName)
                        photosToDeleteFetch.predicate = NSPredicate(format: "(photoID IN %@)", photoIDs)
                        var deleteError : NSError?
                        let photosToDelete = ctx.executeFetchRequest(photosToDeleteFetch, error: &deleteError)
                        if let e = deleteError {
                            println("error deleting: \(deleteError)")
                        }
                        for object in photosToDelete {
                            let photo = object as Photo
                            ctx.deleteObject(photo)
                        }
                        var photosThatWereInserted: [NSNumber: Photo] = Dictionary()
                        for object in photosArray {
                            let photoDict = object as NSDictionary
                            let photo = Photo(entity:NSEntityDescription.entityForName(PhotoEntityName, inManagedObjectContext: ctx) , insertIntoManagedObjectContext: nil)
                            photo.updateWithDictionary(photoDict)
                            ctx.insertObject(photo)
                            photosThatWereInserted[photoDict["id"] as NSNumber] = photo
                        }
                        var i = 0
                        for object in photosArray {
                            let photoDict = object as NSDictionary
                            let entry = PhotoStreamEntry(entity: NSEntityDescription.entityForName(PhotoStreamEntryEntityName, inManagedObjectContext: ctx), insertIntoManagedObjectContext: ctx)
                            entry.position = Int32(i)
                            entry.streamID = self.streamType.toRaw()
                            entry.photo = photosThatWereInserted[photoDict["id"] as NSNumber]!
                            i++
                        }
                        ctx.save(nil)
                    }
                    self.refetchEntries {
                        NSNotificationCenter.defaultCenter().postNotificationName(PhotoStreamDidUpdateNotification, object: self)
                    }
                }
            } else {
                println("error loading photos: \(error?)")
            }
        }
    }

    func refetchEntries(handler : () -> ()){
        if let ctx = self.account?.managedObjectContext {
            ctx.performBlock {
                let fetch = NSFetchRequest(entityName: PhotoStreamEntryEntityName)
                fetch.sortDescriptors = [NSSortDescriptor(key: "position", ascending: false)]
                fetch.predicate = NSPredicate(format: "streamID = %@", self.streamType.toRaw())
                println("Stream type: \(self.streamType.toRaw())")
                self.entries = ctx.executeFetchRequest(fetch, error: nil) as [PhotoStreamEntry]
                handler()
            }
        }

    }

    func loadOlder(){

    }
}
