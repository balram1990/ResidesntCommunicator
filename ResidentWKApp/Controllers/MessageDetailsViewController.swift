//
//  MessageDetailsViewController.swift
//  ResidentWKApp
//
//  Created by Balram Singh on 03/08/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

class MessageDetailsViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messagelabel: UITextView!
    @IBOutlet weak var backLabel: UILabel!
    var message : Notification?
    var isFromMessages = false
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.applicationIconBadgeNumber = 0
        if let _ = self.message {
             self.showNewMessage(self.message)
        }
        if isFromMessages {
            self.backLabel.text = "Back To Messages"
        } else {
            self.backLabel.text = "Back"
        }
        
    }

    @IBAction func backButtonPressed(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func showNewMessage (_ notification : Notification?) {
        NSLog("Showing message %@", notification!.notifId!)
        self.message = notification
        self.message?.isRead = true
        DataManager.sharedInstance().saveContext()
        self.fromLabel.text = message?.from
        self.messagelabel.text = message?.msg
        let date = Date(timeIntervalSince1970: TimeInterval((message?.timeinterval)!))
        self.timeLabel.text = date.timeAgo()

    }
    
    func handleMessage(_ messageId : String?) {
        
        let manager = DataManager.sharedInstance()
        if let _ = messageId {
            //show Message
            NSLog("handle message with ID: %@", messageId!)
            if let notif = manager.getNotifcationById(messageId!) {
                //wait for view to be initialized
                NSLog("Already exist messaege, showing message directly %@", messageId!)
                self.perform(#selector(self.showNewMessage), with: notif, afterDelay: 2)
            }else {
                //download Messages and show
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let user = appDelegate!.getUser()
                if let tokenString = user?.token {
                    let completeURL = Constants.MESSAGES_URL + "/" + String(user!.userID!) + "/message/" +  messageId! + "?token=" + tokenString
                    NetworkIO().get(completeURL, callback: { (data, response, error) in
                        if let _ = error {
                            NSLog("Something went wrong while fetching content %@", error!.localizedDescription)
                            self.handleError(error!)
                            return
                        }else {
                            self.runOnUIThread({
                            //save notfication
                            if let _ = data {
                                NSLog("Message content downloaded %@", data!)
                                appDelegate!.addNotification(data: data!)
                                if let notif = manager.getNotifcationById(messageId!) {
                                    self.perform(#selector(self.showNewMessage), with: notif, afterDelay: 1)
                                }
                            }
                           })
                        }
                    })
                }else {
                    self.handleError(NSError(domain: "com.communicator", code: 401, userInfo: nil))
                }
            }
        }else {
            //do nothing
        }
    }
}
