//
//  MessagesViewController.swift
//  ResidentWKApp
//
//  Created by Balram Singh on 03/08/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    let CellIdentifier = "MessageCell"
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    var messages : [Notification] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.registerNib(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: CellIdentifier)
        self.tableView.rowHeight = 100
        self.messages = DataManager.sharedInstance().getAllNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadList), name: AppDelegate.NotificationListUpdate, object: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    func reloadList () {
        self.messages = DataManager.sharedInstance().getAllNotifications()
        self.tableView.reloadData()
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as? MessageCell
        let message = self.messages[indexPath.row]
        cell?.messageLabel.text = message.msg
        cell?.fromLabel.text = message.from
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(message.timeinterval!))
        cell?.timeLabel.text = date.timeAgo
        if message.isRead == true {
            cell?.backgroundColor = .whiteColor()
            cell?.timeLabel.textColor = .lightGrayColor()
        } else {
            cell?.backgroundColor =  UIColor(red: 208.0/255.0, green: 242.0/255.0, blue: 1.0, alpha: 1.0)
            cell?.timeLabel.textColor = UIColor.blueColor()
        }
        return cell!
    }
    
    //MARK: UITableViewCellDelegate 
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let message = self.messages[indexPath.row]
        let vc =  MessageDetailsViewController(nibName: "MessageDetailsViewController", bundle: nil)
        vc.message = message
        vc.isFromMessages = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
