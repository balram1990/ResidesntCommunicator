//
//  InterfaceController.swift
//  ResidentWKApp WatchKit Extension
//
//  Created by Balram Singh on 31/07/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func callAssistance() {
    }
    
    @IBAction func showMessages() {
        self.pushControllerWithName("Messages", context: nil)
    }
}
