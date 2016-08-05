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
    var message : Notification?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fromLabel.text = message?.from
        self.messagelabel.text = message?.msg
        let date = NSDate(timeIntervalSince1970: NSTimeInterval((message?.timeinterval)!))
        self.timeLabel.text = date.timeAgo
    }

    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
