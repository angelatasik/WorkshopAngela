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

    var datumi = [NSDate]()
    var statusi = [String]()
    var Iminja = [String]()
    var Preziminja = [String]()
    var phones = [String]()
    var emails = [String]()
    var lats = [Double]()
    var longs = [Double]()
    var images = [PFFileObject?]()
    var finishDates = [NSDate?]()
    var adresiDefekt = [String]()
    var jobIds = [String]()
    
    
    var refresher: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTable()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(RabotiTableViewController.updateTable), for: UIControl.Event.valueChanged)
        self.view.addSubview(refresher)
        
    }

    @objc func updateTable() {
        statusi.removeAll()
        Iminja.removeAll()
        Preziminja.removeAll()
        datumi.removeAll()
        phones.removeAll()
        emails.removeAll()
        lats.removeAll()
        longs.removeAll()
        images.removeAll()
        finishDates.removeAll()
        adresiDefekt.removeAll()
        jobIds.removeAll()
        
        let array = ["done", "scheduled"]
        let predicate = NSPredicate(format: "status = %@ OR status = %@", argumentArray: array)
        let query = PFQuery(className: "Job", predicate: predicate)
        query.whereKey("to", equalTo: PFUser.current()?.objectId)
        query.addDescendingOrder("DateTime")
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let object = objects {
                for obj in object {
                    if let status = obj["status"] {
                        if let date = obj["DateTime"] {
                            if let adresa = obj["location"] {
                                if let lat = obj["lat"] {
                                    if let lon = obj["lon"] {
                                        if let slika = obj["imageFile"] {
                                            self.images.append(slika as! PFFileObject)
                                        }else {
                                            self.images.append(nil)
                                        }
                                        if let fDate = obj["finishDate"] {
                                            self.finishDates.append(fDate as! NSDate)
                                        }else {
                                            self.finishDates.append(nil)
                                        }
                                        if let jobId = obj.objectId {
                                            print(jobId)
                                            if let userId = obj["from"] {
                                                let userQuery = PFUser.query()
                                                userQuery?.whereKey("objectId", equalTo: userId)
                                                userQuery?.findObjectsInBackground(block: { (users, error) in
                                                    if error != nil {
                                                        print(error?.localizedDescription)
                                                    } else if let user = users {
                                                        for u in user{
                                                            if let u = u as? PFUser {
                                                                if let fName = u["firstName"] {
                                                                    if let lName = u["lastName"] {
                                                                        if let email = u.username {
                                                                            if let pNumber = u["phoneNumber"] {
                                                                                self.datumi.append(date as! NSDate)
                                                                                self.statusi.append(status as! String)
                                                                                self.Iminja.append(fName as! String)
                                                                                self.Preziminja.append(lName as! String)
                                                                                self.phones.append(pNumber as! String)
                                                                                self.emails.append(email)
                                                                                self.lats.append(lat as! Double)
                                                                                self.longs.append(lon as! Double)
                                                                                self.adresiDefekt.append(adresa as! String)
                                                                                self.jobIds.append(jobId as! String)
                                                                            }
                                                                        }
                                                                    }
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
                        }
                    }
                }
            }
        }
    }

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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "konRabota" {
            if let index = tableView.indexPathForSelectedRow?.row {
            let destinationVC = segue.destination as! RabotiDetailViewController
            destinationVC.Ime = Iminja[index]
            destinationVC.Prezime = Preziminja[index]
            destinationVC.adresa = adresiDefekt[index]
            destinationVC.status = statusi[index]
            destinationVC.phone = phones[index]
            destinationVC.lat = lats[index]
            destinationVC.email = emails[index]
            destinationVC.long = longs[index]
            destinationVC.datum = datumi[index]
            destinationVC.jobId = jobIds[index]
                if statusi[index] == "done" {
                    destinationVC.DatumZavrsuvanje = finishDates[index]!
                    destinationVC.imageFile.append(images[index]!)
                }
            }
        }
    }
}
