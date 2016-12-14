//
//  MessageDetailsController.swift
//  ResidentWKApp
//
//  Created by Balram Singh on 06/08/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import WatchKit
import Foundation

class MessageDetailsController: WKInterfaceController {
    
    @IBOutlet var timeLabel: WKInterfaceLabel!
    @IBOutlet var messageLabel: WKInterfaceLabel!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let msg = context as? Message {
            self.showMessage(msg)
            self.setTitle(msg.from)
        } else {
            //handle push notification
            if let notif = context as? NSDictionary{
                print("MessageDetailsController:AwakeWithContext:\(notif)")
                let newMessage = Message()
                newMessage.parseJSON(notif)
                self.showMessage(newMessage)
                self.setTitle(newMessage.from)
                
            }
        }
        // Configure interface objects here.
    }
    
    func showMessage(_ msg : Message) {
        self.messageLabel.setText(msg.msg)
        self.timeLabel.setText(msg.timeAgo)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    @IBAction override func pop() {
        self.pop()
    }

}
