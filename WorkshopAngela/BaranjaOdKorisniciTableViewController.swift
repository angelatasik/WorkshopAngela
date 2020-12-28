//
//  BaranjaOdKorisniciTableViewController.swift
//  WorkshopAngela
//
//  Created by Angela Tasikj on 12/24/20.
//  Copyright © 2020 Angela Tasikj. All rights reserved.
//

import UIKit
import Parse

class BaranjaOdKorisniciTableViewController: UITableViewController {
    
    
    var Iminja = [String]()
    var Preziminja = [String]()
    var datumi = [NSDate]()
    var opisi = [String]()
    var lokacii = [String]()
    var phones = [String]()
    var emails = [String]()
    var longitudes = [Double]()
    var latitudes = [Double]()
    var index = Int()
    
    var refresher:UIRefreshControl = UIRefreshControl()
    
    @IBAction func LogOut(_ sender: Any) {
        PFUser.logOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateTable()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(BaranjaOdKorisniciTableViewController.updateTable)
            , for: UIControl.Event.valueChanged)
        self.view.addSubview(refresher)
    }
    
    @objc func updateTable() {
        Iminja.removeAll()
        Preziminja.removeAll()
        datumi.removeAll()
        opisi.removeAll()
        emails.removeAll()
        longitudes.removeAll()
        latitudes.removeAll()
        phones.removeAll()
        lokacii.removeAll()
        
        let query = PFQuery(className: "Job")
        query.whereKey("to", equalTo: PFUser.current()?.objectId)
        query.whereKey("status", equalTo: "active")
        query.addDescendingOrder("date")
        query.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else if let obj = objects {
                for object in obj {
                    if let userId = object["from"] {
                        if let datum = object["date"]{
                            if let lokacija = object["location"]{
                                if let opis = object["description"]{
                                    if let lat = object["lat"]{
                                        if let long = object["lon"]{
                                            let userQuery = PFUser.query()
                                            userQuery?.whereKey("objectId", equalTo: userId)
                                            userQuery?.findObjectsInBackground(block: { (users, error) in
                                                if error != nil {
                                                    print(error?.localizedDescription)
                                                }else if let userss = users{
                                                    for user in userss{
                                                        if let user = user as? PFUser {
                                                            if let fName = user["firstName"]{
                                                                if let lName = user["lastName"]{
                                                                    if let pNubmer = user["phoneNumber"]{
                                                                        if let email = user.username{
                                                                            self.Iminja.append(fName as! String)
                                                                            self.Preziminja.append(lName as! String)
                                                                            self.phones.append(pNubmer as! String)
                                                                            self.emails.append(email)
                                                                            self.datumi.append(datum as! NSDate)
                                                                            self.opisi.append(opis as! String)
                                                                            self.lokacii.append(lokacija as! String)
                                                                            self.latitudes.append(lat as! Double)
                                                                            self.longitudes.append(long as! Double)
                                                                            
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
                    self.refresher.endRefreshing()
                    self.tableView.reloadData()
                })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Iminja.count
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let StringDate = dateFormatter.string(from: self.datumi[indexPath.row] as! Date)
        cell.textLabel?.text = StringDate
        cell.detailTextLabel?.text = Iminja[indexPath.row] + " " + Preziminja[indexPath.row]

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = (tableView.indexPathForSelectedRow?.row)!
        performSegue(withIdentifier: "DetailsBaranja", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailsBaranja" {
            let destVC = segue.destination as! BaranjaDetailViewController
            destVC.Ime = Iminja[index]
            destVC.Prezime = Preziminja[index]
            destVC.lokacija = lokacii[index]
            destVC.email = emails[index]
            destVC.tel = phones[index]
            destVC.datum = datumi[index]
            destVC.lat = latitudes[index]
            destVC.lon = longitudes[index]
            destVC.opis = opisi[index]
        }
    }
}
