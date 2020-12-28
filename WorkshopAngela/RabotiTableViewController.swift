//
//  RabotiTableViewController.swift
//  WorkshopAngela
//
//  Created by Angela Tasikj on 12/27/20.
//  Copyright © 2020 Angela Tasikj. All rights reserved.
//

import UIKit
import Parse

class RabotiTableViewController: UITableViewController {

    var statusi = [String]()
    var Iminja = [String]()
    var Preziminja = [String]()
    var datumi = [NSDate]()
    
    var refresher: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTable()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(RabotiTableViewController.updateTable), for: UIControl.Event.valueChanged)
        self.view.addSubview(refresher)
        
    }
    
    @objc func updateTable(){
        statusi.removeAll()
        Iminja.removeAll()
        Preziminja.removeAll()
        datumi.removeAll()
        
        let array = ["done" , "scheduled"]
        let predicate = NSPredicate(format: "status = %@ OR status = %@", argumentArray: array)
        let query = PFQuery(className: "Job", predicate: predicate)
        query.whereKey("to", equalTo: PFUser.current()?.objectId)
        query.addDescendingOrder("DateTime")
        query.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else if let objects = objects {
                for object in objects {
                    if let status = object["status"] {
                        if let date = object["DateTime"]{
                            if let userId = object["from"]{
                                    let Query = PFUser.query()
                                    Query?.whereKey("bjectId", equalTo: userId)
                                    Query?.findObjectsInBackground(block: { (users, error) in
                                    if error != nil {
                                        print(error?.localizedDescription)
                                    }else if let user = users{
                                        for u in user {
                                            if let fname = u["firstName"]{
                                                if let lname = u["lastName"]{
                                                    self.datumi.append(date as! NSDate)
                                                    self.statusi.append(status as! String)
                                                    self.Iminja.append(fname as! String)
                                                    self.Preziminja.append(lname as! String)
                                                }
                                            }
                                        }
                                    }
                                    self.refresher.endRefreshing()
                                    self.tableView.reloadData()
                                })
                            }
                        }
                    }
                }
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return statusi.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Kelijaa", for: indexPath)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let StringDate = dateFormatter.string(from: self.datumi[indexPath.row] as! Date)
        cell.textLabel?.text = StringDate
        cell.detailTextLabel?.text = Iminja[indexPath.row] + " " + Preziminja[indexPath.row]
        if statusi[indexPath.row] == "scheduled" {
            cell.backgroundColor = .red
        }else {
            cell.backgroundColor = .green
        }

        return cell
    }


}
