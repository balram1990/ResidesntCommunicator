//
//  InterfaceController.swift
//  ResidentWKApp WatchKit Extension
//
//  Created by Balram Singh on 31/07/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var assistanceButton: WKInterfaceButton!
    var session : WCSession!
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func callAssistance() {
        self.assistanceButton.setEnabled(false)
        session.sendMessage(["message":"assistance"], replyHandler: { (data) in
            print("Data received \(data)")
            dispatch_async(dispatch_get_main_queue()) {
                self.assistanceButton.setEnabled(true)
            }
            if let code = data["code"] as? Int {
                if code == 200 {
                    //show success
                    dispatch_async(dispatch_get_main_queue(), {
                        let dismissAction = WKAlertAction(title: "Ok", style: .Default, handler: {})
                        self.presentAlertControllerWithTitle("Success", message: "Concerned people have been informed.", preferredStyle: .Alert, actions: [dismissAction])
                    })
                } else {
                    //show Failure
                    self.showFailure(code)
                }
            }
           
        }) { (error) in
            print("Error while calling for assistance \(error)")
            dispatch_async(dispatch_get_main_queue()) {
                self.assistanceButton.setEnabled(true)
            }
            self.showFailure(100)
        }
    }
    
    @IBAction func showMessages() {
        self.pushControllerWithName("Messages", context: nil)
    }
}

extension WKInterfaceController {
    func showFailure (code : Int) {
        var message = ""
        switch code {
        case 100:
            message = "Something went wrong. Please make sure that your Apple Watch is paired properly with your iPhone."
        case 401:
            message = "Please login through iPhone before proceeding further."
        case 400, 500:
            message = "Something went wrong. Please try again."
        case 404:
            message = "Please login again thorugh iPhone and try again."
        default:
            message = "something went wrong. Please try again later"
        }
        
        dispatch_async(dispatch_get_main_queue()) { 
            let action = WKAlertAction(title: "Dismiss", style: .Default, handler:{})
            self.presentAlertControllerWithTitle("Failure", message: message, preferredStyle: .Alert, actions: [action])
        }
       
    }

}