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
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }


    @IBOutlet var assistanceButton: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
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
        NSLog("Extension Delegate callAssistance")
        var session : WCSession!
        self.assistanceButton.setEnabled(false)
        if (WCSession.isSupported()) {
            session = WCSession.default()
            session.delegate = self
            session.activate()
        }
        session.sendMessage(["message":"assistance"], replyHandler: { (data) in
            NSLog("Data received \(data)")
            DispatchQueue.main.async {
                self.assistanceButton.setEnabled(true)
            }
            if let code = data["code"] as? Int {
                if code == 200 {
                    //show success
                    DispatchQueue.main.async(execute: {
                        let dismissAction = WKAlertAction(title: "Ok", style: .default, handler: {})
                        self.presentAlert(withTitle: "Success", message: "Concerned people have been informed.", preferredStyle: .alert, actions: [dismissAction])
                    })
                } else {
                    //show Failure
                    self.showFailure(code)
                }
            }
           
        }) { (error) in
            NSLog("ExtensionDelegate: Error while calling for assistance \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.assistanceButton.setEnabled(true)
            }
            self.showFailure(100)
        }
    }
    
    @IBAction func showMessages() {
        self.pushController(withName: "Messages", context: nil)
    }
}

extension WKInterfaceController {
    func showFailure (_ code : Int) {
        var message = ""
        switch code {
        case 100:
            message = "Something went wrong. Please make sure that your Apple Watch is paired properly with your iPhone."
        case 300:
            message = "Seems like location services are not enabled for this app in your iPhone. Please enable the same and try again."
        case 401:
            message = "Please login through iPhone before proceeding further."
        case 400, 500:
            message = "Something went wrong. Please try again."
        case 404:
            message = "Please login again thorugh iPhone and try again."
        default:
            message = "Something went wrong. Please try again later"
        }
        
        DispatchQueue.main.async { 
            let action = WKAlertAction(title: "Dismiss", style: .default, handler:{ self.pop()})
            self.presentAlert(withTitle: "Failure", message: message, preferredStyle: .alert, actions: [action])
        }
       
    }

    
    
}
