//
//  URLsViewController.swift
//  ResidentWKApp
//
//  Created by Balram Singh on 14/12/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

class URLsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var names = ["Staging", "Production"]
    var URLs = ["http://aptoseniorcare.com/", "http://residentcommunicator.net/"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var tableView: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "URLCell"
        var cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
        if nil == cell {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: CellIdentifier)
        }
        cell?.textLabel?.text = names[indexPath.row]
        cell?.detailTextLabel?.text = URLs[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Constants.BASE_URL = URLs[indexPath.row] + "wp-json/"
    }
}
