//
//  MessagesController.swift
//  ResidentWKApp
//
//  Created by Balram Singh on 06/08/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class MessagesController: WKInterfaceController, WCSessionDelegate {
    
    var session : WCSession!
    var messages = [Message]()
    @IBOutlet var messageTable: WKInterfaceTable!
    
    @IBOutlet var noMessageLabel: WKInterfaceLabel!
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.noMessageLabel.setHeight(0)
    }
    
    func loadTable () {
    
        if self.messages.count != 0 {
            self.messageTable.setNumberOfRows(self.messages.count, withRowType: "MessageRow")
            for (index, notif) in (self.messages.enumerate()) {
                if let row = messageTable.rowControllerAtIndex(index) as? MessageRow {
                    row.fromLabel.setText(notif.from)
                    row.timeLabel.setText(notif.timeAgo)
                    row.messgeLabel.setText(notif.msg)
                }
            }
        } else {
            self.noMessageLabel.setHeight(25)
            self.messageTable.setHidden(true)
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        session.sendMessage(["message":"Notifications"], replyHandler: { (data) in
            print("Data received \(data)")
            if let code = data["code"] as? Int {
                if code == 200 {
                    if let data = data["notifications"] as? [NSDictionary] {
                        for dict in data {
                            let newMessage = Message()
                            newMessage.parseJSON(dict)
                            self.messages.append(newMessage)
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.loadTable()
                    })

                } else {
                    self.showFailure(code)
                }
            }
            
        }) { (error) in
            print("Error while loading notifications \(error)")
            self.showFailure(100)
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func pop() {
        self.popController()
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        //show message details
        let aMessage = self.messages[rowIndex]
        self.pushControllerWithName("MessageDetails", context: aMessage)
    }
}
