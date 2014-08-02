//
//  PhotoStreamEntry.swift
//  FastPX
//
//  Created by Ben Sandofsky on 8/2/14.
//  Copyright (c) 2014 Sandofsky. All rights reserved.
//

import CoreData

let PhotoStreamEntryEntityName = "PhotoStreamEntry"

class PhotoStreamEntry: NSManagedObject {
    @NSManaged var photo : Photo
    @NSManaged var position : Int32
    @NSManaged var streamID : String
}
