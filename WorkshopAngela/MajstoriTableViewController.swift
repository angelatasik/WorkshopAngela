//
//  MajstoriTableViewController.swift
//  WorkshopAngela
//
//  Created by Angela Tasikj on 12/22/20.
//  Copyright © 2020 Angela Tasikj. All rights reserved.
//

import UIKit
import Parse



class MajstoriTableViewController: UITableViewController {

    var Iminja = [String]()
    var Preziminja = [String]()
    //var dates = [NSDate]()
    //var images = [PFFileObject]()
    var kliknatMajstor = String()
    var opis = String()
    var lokacija = String()
    var lon = Double()
    var lat = Double()
    var MajstorId = [String]()
    var index = Int()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Kelija", for: indexPath)
        cell.textLabel?.text = Iminja[indexPath.row] + " " + Preziminja[indexPath.row]
        let DefektLokacija = CLLocation(latitude: lat, longitude: lon)
        let firstName = Iminja[indexPath.row]
        let lastName = Preziminja[indexPath.row]
        //SET UP OUR QUERY FOR A USER OBJ:
        let MajstorQuery = PFUser.query()
        MajstorQuery?.whereKey("tipKorisnik", equalTo: "Majstor")
        MajstorQuery?.whereKey("firstName", equalTo: firstName)
        MajstorQuery?.whereKey("lastName", equalTo: lastName)
        //EXECUTE THE QUERY - IZVRSI GO BARANJETO:
        MajstorQuery?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else if let majstori = objects {
                for object in majstori {
                    if let majstor = object as? PFUser {
                        if let objectID = majstor.objectId {
                            if let currentLat = majstor["currentLat"] {
                                if let currentLong = majstor["currentLong"]{
                                    let MajstorLocation = CLLocation(latitude: currentLat as! Double, longitude: currentLong as! Double)
                                    let distance = MajstorLocation.distance(from: DefektLokacija) / 1000
                                    let roundedDistance = round(distance * 100) / 100
                                    cell.detailTextLabel?.text = "\(roundedDistance)km away"
                                    let query = PFQuery(className: "Job")
                                    query.whereKey("from", equalTo: PFUser.current()?.objectId)
                                    query.whereKey("to", equalTo: objectID)
                                    query.whereKey("status", equalTo: "active")
                                    query.findObjectsInBackground(block: { (objects, error) in
                                        if error != nil {
                                            print(error?.localizedDescription)
                                        } else if let objects = objects {
                                            if objects.count > 0 {
                                                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                                            }
                                        }
                                    })
                            }
                                }
                            }
                    }
                    
        }
            }
    })

        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        performSegue(withIdentifier: "MajstoriDetailSeq", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MajstoriDetailSeg"{
            let destinationVC = segue.destination as! MajstoriDetailsTableViewContoller
            destinationVC.lokacija = lokacija
            destinationVC.opis = opis
            destinationVC.lon = lon
            destinationVC.lat = lat
            destinationVC.ime = Iminja[index]
            destinationVC.Prezime = Preziminja[index]
            
        }
    }
}
