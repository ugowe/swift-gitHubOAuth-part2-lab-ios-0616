//
//  ReposTableViewController.swift
//  GitHubOAuth
//
//  Created by Joel Bell on 7/27/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class ReposTableViewController: UITableViewController {

    let store = ReposDataStore.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Repositories"
        
        store.getRepositoriesWithCompletion { success in
            if success {
                NSOperationQueue.mainQueue().addOperationWithBlock({ 
                    self.tableView.reloadData()
                })
            } else {
                print("ERROR: Unable to get repositories for table view")
            }
        }

    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.repositories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell", forIndexPath: indexPath) as! ReposTableViewCell
        cell.repo = store.repositories[indexPath.row]
        return cell
    }

    @IBAction func logoutButtonTapped(sender: AnyObject) {
        
    }

}
