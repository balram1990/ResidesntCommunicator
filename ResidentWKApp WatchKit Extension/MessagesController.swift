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
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

    
    var session : WCSession!
    var messages = [Message]()
    @IBOutlet var messageTable: WKInterfaceTable!
    
    @IBOutlet var noMessageLabel: WKInterfaceLabel!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Back")
        if (WCSession.isSupported()) {
            session = WCSession.default()
            session.delegate = self
            session.activate()
        }
        self.noMessageLabel.setText("Loading...")
        self.noMessageLabel.setHeight(25)
        self.messageTable.setHidden(true)
        session.sendMessage(["message":"Notifications"], replyHandler: { (data) in
            print("Data received \(data)")
            if let code = data["code"] as? Int {
                if code == 200 {
                    if let data = data["notifications"] as? [NSDictionary] {
                        self.messages.removeAll()
                        for dict in data {
                            let newMessage = Message()
                            newMessage.parseJSON(dict)
                            self.messages.append(newMessage)
                        }
                    }
                    DispatchQueue.main.async(execute: {
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
    
    func loadTable () {
    
        if self.messages.count != 0 {
            self.noMessageLabel.setHeight(0)
            self.messageTable.setHidden(false)
            self.messageTable.setNumberOfRows(self.messages.count, withRowType: "MessageRow")
            for (index, notif) in (self.messages.enumerated()) {
                if let row = messageTable.rowController(at: index) as? MessageRow {
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
    }
    
    
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction override func pop() {
        self.pop()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        //show message details
        let aMessage = self.messages[rowIndex]
        self.pushController(withName: "MessageDetails", context: aMessage)
    }
}
