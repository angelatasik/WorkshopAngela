//
//  BaranjaRabotiTableViewController.swift
//  WorkshopAngela
//
//  Created by Angela Tasikj on 12/24/20.
//  Copyright © 2020 Angela Tasikj. All rights reserved.
//

import UIKit
import Parse

class BaranjaRabotiTableViewController: UITableViewController {
    
    var index = Int()
    var datumii = [NSDate]()
    var MajstoriIds = [String]()
    var statusi = [String]()
    var descriptions = [String]()
    var datumPonuda = [NSDate]()
    var cenaPonuda = [String]()
    var DatumZavrsuvanje = [NSDate?]()
    var image = [PFFileObject?]()
    
    var refresher: UIRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTable()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(BaranjaRabotiTableViewController.updateTable), for: UIControl.Event.valueChanged)
        self.view.addSubview(refresher)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return datumii.count
    }

    @objc func updateTable() {
        datumii.removeAll()
        MajstoriIds.removeAll()
        statusi.removeAll()
        descriptions.removeAll()
        image.removeAll()
        DatumZavrsuvanje.removeAll()
        datumPonuda.removeAll()
        cenaPonuda.removeAll()
        
        let query = PFQuery(className: "Job")
        query.whereKey("from", equalTo: PFUser.current()?.objectId)
        query.addDescendingOrder("date")
        query.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else if let objects = objects {
                for object in objects {
                    if let datumB = object["date"] {
                        if let status = object["status"]{
                            if let MajstorId = object["to"]{
                                if let desc = object["description"]{
                                    self.datumii.append(datumB as! NSDate)
                                    self.MajstoriIds.append(MajstorId as! String)
                                    self.statusi.append(status as! String)
                                    self.descriptions.append(desc as! String)
                                    if let DateTime = object["DateTime"] {
                                        if let Price = object["Price"] {
                                            self.cenaPonuda.append(Price as! String)
                                            self.datumPonuda.append(DateTime as! NSDate)
                                        }
                                    }else{
                                        self.datumPonuda.append(NSDate())
                                        self.cenaPonuda.append("<#T##newElement: String##String#>")
                                    }
                                    if let fDate = object["finishDate"]{
                                        if let imageFile = object["imageFile"]{
                                            self.DatumZavrsuvanje.append(fDate as! NSDate)
                                            self.image.append(imageFile as! PFFileObject)
                                        }
                                    }else {
                                        self.DatumZavrsuvanje.append(nil)
                                        self.image.append(nil)
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let MajstorId = MajstoriIds[indexPath.row]
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: MajstorId)
        query?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else if let obj = objects {
                for o in obj {
                    if let Majstor = o as? PFUser{
                        if let firstName = Majstor["firstName"]{
                            if let lastName = Majstor["lastName"]{
                                print(firstName)
                                print(lastName)
                                cell.textLabel?.text = (firstName as! String) + " " + (lastName as! String)
                            }
                        }
                    }
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let StringDate = dateFormatter.string(from: self.datumii[indexPath.row] as! Date)
                cell.detailTextLabel?.text = StringDate
                let status = self.statusi[indexPath.row]
                if status == "active" {
                    cell.backgroundColor = UIColor.yellow
                }else if status == "pending" {
                    cell.backgroundColor = UIColor.red
                }else if status == "scheduled" {
                    cell.backgroundColor = UIColor.blue
                }else if status == "done"{
                    cell.backgroundColor = UIColor.green
                }
            }
        })

        return cell
    }
  

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = (tableView.indexPathForSelectedRow?.row)!
        performSegue(withIdentifier: "DetaliBaranjaRaboti", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetaliBaranjaRaboti" {
            let destinationVC = segue.destination as! BaranjaRabotiDetailsViewController
            destinationVC.MajstoId = MajstoriIds[index]
            destinationVC.opis = descriptions[index]
            destinationVC.dataReq = datumii[index]
            destinationVC.status = statusi[index]
            if statusi[index] == "pending"{
                destinationVC.DatumPonuda = datumPonuda[index]
                destinationVC.CenaPonuda = cenaPonuda[index]
            }else if statusi[index] == "scheduled" {
                destinationVC.DatumPonuda = datumPonuda[index]
            }else if statusi[index] == "done" {
                destinationVC.imageFile.append(image[index]!)
                destinationVC.dateFinished = DatumZavrsuvanje[index]!
            }
        }
    }

}
