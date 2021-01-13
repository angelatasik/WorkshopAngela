//
//  BaranjaOdKorisniciTableViewController.swift
//  WorkshopAngela
//
//  Created by Angela Tasikj on 12/24/20.
//  Copyright © 2020 Angela Tasikj. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation

class BaranjaOdKorisniciTableViewController: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    
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
    var currLat = Double()
    var currLong = Double()
    
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
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currLat = locations[0].coordinate.latitude
        currLong = locations[0].coordinate.longitude
        PFUser.current()!["currentLat"] = currLat
        PFUser.current()!["currentLon"] = currLong
        PFUser.current()?.saveInBackground()
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
        print("se kreira query")
        query.whereKey("to", equalTo: PFUser.current()?.objectId)
        query.whereKey("status", equalTo: "active")
        query.addDescendingOrder("date")
        query.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else if let obj = objects {
                for object in obj {
                    print("vlaga vo for-ot")
                    if let userId = object["from"] {
                        if let datum = object["date"]{
                            if let opis = object["description"]{
                                if let lokacija = object["location"]{
                                    if let lat = object["lat"]{
                                        if let long = object["lon"]{
                                            let userQuery = PFUser.query()
                                            userQuery?.whereKey("objectId", equalTo: userId)
                                            userQuery?.findObjectsInBackground(block: { (users, error) in
                                                if error != nil {
                                                    print(error?.localizedDescription)
                                                }else if let userss = users{
                                                    for user in userss{
                                                        if let u = user as? PFUser {
                                                            //print(u)
                                                            if let fName = u["firstName"]{
                                                                print(fName)
                                                                if let lName = u["lastName"]{
                                                                    print(lName)
                                                                    if let pNubmer = u["phoneNumber"]{
                                                                        if let email = u.username{
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
