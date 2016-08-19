//
//  Notification+CoreDataProperties.swift
//  ResidentWKApp
//
//  Created by Balram Singh on 04/08/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Notification {

    @NSManaged var notifId: String?
    @NSManaged var from: String?
    @NSManaged var timeinterval: NSNumber?
    @NSManaged var msg: String?
    @NSManaged var isRead : NSNumber?

}
