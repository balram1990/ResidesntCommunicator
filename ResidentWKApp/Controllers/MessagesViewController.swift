//
//  MessagesViewController.swift
//  ResidentWKApp
//
//  Created by Balram Singh on 03/08/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class MessagesViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    let CellIdentifier = "MessageCell"
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    var messages : [Notification] = []
    var dFormatter : DateFormatter?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: CellIdentifier)
        self.tableView.rowHeight = 100
        self.messages = DataManager.sharedInstance().getAllNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadList), name: NSNotification.Name(rawValue: AppDelegate.NotificationListUpdate), object: nil)
        
        self.getAllMessages ()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    func reloadList () {
        self.messages = DataManager.sharedInstance().getAllNotifications()
        self.tableView.reloadData()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as? MessageCell
        let message = self.messages[indexPath.row]
        cell?.messageLabel.text = message.msg
        cell?.fromLabel.text = message.from
        let date = Date(timeIntervalSince1970: TimeInterval(message.timeinterval!))
        cell?.timeLabel.text = date.timeAgo()
        if message.isRead == true {
            cell?.backgroundColor = .white
            cell?.timeLabel.textColor = .lightGray
        } else {
            cell?.backgroundColor =  UIColor(red: 208.0/255.0, green: 242.0/255.0, blue: 1.0, alpha: 1.0)
            cell?.timeLabel.textColor = UIColor.blue
        }
        return cell!
    }
    
    //MARK: UITableViewCellDelegate 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let message = self.messages[indexPath.row]
        let vc =  MessageDetailsViewController(nibName: "MessageDetailsViewController", bundle: nil)
        vc.message = message
        vc.isFromMessages = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getAllMessages () {
        let appdelegate = UIApplication.shared.delegate as? AppDelegate
        if  let user = appdelegate?.getUser() {
            let url = Constants.MESSAGES_URL + "/" + String(user.userID!) + "/messages" + "?" + "token=" + (user.token ?? "")
            NetworkIO().get(url, callback: { (data, response, error) in
                if let _ = error {
                    self.runOnUIThread({ 
                        self.handleError(error!)
                        return
                    })
                    return
                }
                print("data \(data)")
                if let dict = data {
                    let msgs = dict["messages"] as! NSArray
                    self.handleMessagesResponse(msgs)
                    self.runOnUIThread({
                        self.tableView.reloadData()
                    })
                }
            })
        }
    }
    
    func handleMessagesResponse (_ dict : NSArray) {
        let manager = DataManager.sharedInstance()
        for (_, item) in dict.enumerated() {
            let itemDictionary  = item as? [String  : AnyObject]
            let itemId = itemDictionary?["id"] as? String
            let list = self.messages.filter({ (msg) -> Bool in
                msg.notifId == itemId
            })
            if list.count == 0 {
                //create notfication object
                if let notif = NSEntityDescription.insertNewObject(forEntityName: "Notification", into: manager.managedObjectContext) as? Notification {
                    notif.from = itemDictionary?["sender_display_name"] as? String
                    notif.msg = itemDictionary?["message"] as? String
                    notif.notifId = itemDictionary?["id"] as? String
                    let dateString = itemDictionary?["time"] as? String
                    notif.timeinterval = Util.dateFromString(dateString).timeIntervalSince1970 as NSNumber?
                }
            }
        }
        manager.saveContext()
        self.messages = manager.getAllNotifications()
    }
}
