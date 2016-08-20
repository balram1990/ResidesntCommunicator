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
        
        self.showNewMessage(self.message)
        if isFromMessages {
            self.backLabel.text = "Back To Messages"
        } else {
            self.backLabel.text = "Back"
        }
        
    }

    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showNewMessage (notification : Notification?) {
        self.message = notification
        self.message?.isRead = true
        DataManager.sharedInstance().saveContext()
        self.fromLabel.text = message?.from
        self.messagelabel.text = message?.msg
        let date = NSDate(timeIntervalSince1970: NSTimeInterval((message?.timeinterval)!))
        self.timeLabel.text = date.timeAgo

    }
}
