//
//  MajstoriDetailsTableViewContoller.swift
//  WorkshopAngela
//
//  Created by Angela Tasikj on 12/22/20.
//  Copyright © 2020 Angela Tasikj. All rights reserved.
//

import UIKit
import Parse

class MajstoriDetailsTableViewContoller: UITableViewController {

    var dates = [NSDate]()
    var imageFiles = [PFFileObject]()
    var MajstorId = String()
    var opis = String()
    var lokacija = String()
    var lon = Double()
    var lat = Double()
    var ime = String()
    var Prezime = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        let craftsmanQuery = PFUser.query()
        craftsmanQuery?.whereKey("tipKorisnik", equalTo: "Majstor")
        craftsmanQuery?.whereKey("firstName", equalTo: ime)
        craftsmanQuery?.whereKey("lastName", equalTo: Prezime)
        craftsmanQuery?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let object = objects {
                for obj in object {
                    if let o = obj as? PFUser {
                        if let objectId = o.objectId {
                            self.MajstorId = objectId
                        }
                    }
                }
            }
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dates.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "kelija", for: indexPath) as! MajstoriDetailsTableViewCell

        imageFiles[indexPath.row].getDataInBackground { (data,error) in
            if let imageData = data{
                if let imageToDisplay = UIImage(data: imageData){
                    cell.Slika.image = imageToDisplay
            
                }
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let stringDate = dateFormatter.string(from: dates[indexPath.row] as Date)
        //cell.dateFinished.text = stringDate
        return cell
    }
    
    
    @IBAction func PobarajMajstor(_ sender: Any) {
        let request = PFObject(className: "Job")
        request["from"] = PFUser.current()?.objectId
        request["to"] = MajstorId
        request["date"] = NSDate()
        request["status"] = "active"
        request["description"] = opis
        request["location"] = lokacija
        request["lon"] = lon
        request["lat"] = lat
        request.saveInBackground() { (succes,error) in
            if succes {
                self.displayAlert(title: "Uspesno", message: "Make a request")
            }else{
                self.displayAlert(title: "Ne e uspesno", message:(error?.localizedDescription)! )
            }
        }
    }
    
    func displayAlert(title: String, message: String) {
        let allertContoller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allertContoller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(allertContoller,animated: true,completion: nil)
    }
    
    func fetchData(){
        self.imageFiles.removeAll()
        self.dates.removeAll()
        let craftsmanQuery = PFUser.query()
        craftsmanQuery?.whereKey("tipKorisnik", equalTo: "Majstor")
        craftsmanQuery?.whereKey("firstName", equalTo: ime)
        craftsmanQuery?.whereKey("lastName", equalTo: Prezime)
        craftsmanQuery?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let object = objects {
                for obj in object {
                    if let o = obj as? PFUser {
                        if let objectId = o.objectId {
                            let query = PFQuery(className: "Job")
                            query.whereKey("to", equalTo: objectId)
                            query.whereKey("status", equalTo: "done")
                            query.findObjectsInBackground(block: { (jobs, error) in
                                if error != nil {
                                    print(error?.localizedDescription)
                                } else if let jobs = jobs {
                                    for job in jobs {
                                        if let datum = job["finishDate"] {
                                            if let slika = job["imageFile"] {
                                                self.dates.append(datum as! NSDate)
                                                self.imageFiles.append(slika as! PFFileObject)
                                            }
                                        }
                                    }
                                }
                                self.tableView.reloadData()
                            })
                        }
                    }
                }
            }
        })
    }
}
