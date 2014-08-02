//
//  Account.swift
//  FastPX
//
//  Created by Ben Sandofsky on 8/2/14.
//  Copyright (c) 2014 Sandofsky. All rights reserved.
//

import Foundation
import CoreData

private let ModelVersion = 4

class Account: NSObject, NSCoding {

    private let GUID_KEY = "GUID"

    var guid : String
    lazy var api : RestAPI = RestAPI(account: self)
    lazy var popularTimeline : PhotoStream = PhotoStream(account: self, streamType: .Popular)
    lazy var editorsTimeline : PhotoStream = PhotoStream(account: self, streamType: .Editors)

    required init(coder aDecoder: NSCoder!) {
        self.guid = aDecoder.decodeObjectForKey(GUID_KEY) as String
        super.init()
    }

    override init(){
        self.guid = NSUUID.UUID().UUIDString
    }

    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(self.guid, forKey:GUID_KEY)
    }

    deinit {
        println("I'm dying")
    }

    private lazy var coordinator : NSPersistentStoreCoordinator = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        let persistantStoreURL = self.persistantStoreURL()
        println("Initializing at: \(persistantStoreURL)")
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: persistantStoreURL, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError.errorWithDomain("YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }

        return coordinator!
    }()

    private lazy var managedObjectModel : NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("FastPX", withExtension: "momd")
        return NSManagedObjectModel(contentsOfURL: modelURL)
    }()

    private func persistantStoreURL() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let url = urls[urls.count-1] as NSURL
        return url.URLByAppendingPathComponent("\(self.guid).\(ModelVersion).sqlite")
    }

    lazy var managedObjectContext : NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.coordinator
        return context
    }()

    func signRequest(request: NSMutableURLRequest){

    }

    func requiredRequestParameters() -> [String:String]? {
        return Dictionary()
    }
}
