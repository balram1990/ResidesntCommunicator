//
//  Message.swift
//  ResidentWKApp
//
//  Created by Balram Singh on 06/08/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import Foundation

class Message: NSObject {
    var from : String?
    var timeAgo : String?
    var msg : String?
    var id : String?
    
    func parseJSON (_ dictionary : NSDictionary) {
        self.from = dictionary["from"] as? String
        self.msg = dictionary["message"] as? String
        self.id = dictionary["id"] as? String
        self.timeAgo = dictionary["time"] as? String
    }
}
