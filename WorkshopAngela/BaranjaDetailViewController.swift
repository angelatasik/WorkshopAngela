//
//  BaranjaDetailViewController.swift
//  WorkshopAngela
//
//  Created by Angela Tasikj on 12/27/20.
//  Copyright © 2020 Angela Tasikj. All rights reserved.
//

import UIKit
import MapKit
import Parse

class BaranjaDetailViewController: UIViewController {

    var Ime = String()
    var Prezime = String()
    var datum = NSDate()
    var opis = String()
    var lokacija = String()
    var tel = String()
    var email = String()
    var lon = Double()
    var lat = Double()
    
    @IBOutlet weak var Datum: UILabel!
    @IBOutlet weak var Phone: UILabel!
    @IBOutlet weak var Korisnik: UILabel!
    @IBOutlet weak var Email: UILabel!
    @IBOutlet weak var Opis: UILabel!
    
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var Cena: UITextField!
    @IBOutlet weak var Mapa: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Opis.text = opis
        Email.text = email
        Phone.text = tel
        Korisnik.text = Ime + " " + Prezime
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let stringDate = dateFormatter.string(from: datum as! Date)
        Datum.text = stringDate
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegion(center: coord, span: span)
        self.Mapa.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coord
        annotation.title = lokacija
        self.Mapa.addAnnotation(annotation)
        
    }
    
    
    @IBAction func Isprati(_ sender: Any) {
        if Cena.text == " " {
            displayAlert(title: "Nevalidno", message: "Vnesi cena")
        }else{
            let DATA = DatePicker.date
            let CENA = Cena.text
            let query = PFUser.query()
            query?.whereKey("firstName", equalTo: Ime)
            query?.whereKey("lastName", equalTo: Prezime)
            query?.whereKey("phoneNumber", equalTo: tel)
            query?.whereKey("username", equalTo: email)
            query?.findObjectsInBackground(block: { (users, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }else if let user = users{
                    for u in user {
                        if let userId = u.objectId{
                            let Query = PFQuery(className: "Job")
                            Query.whereKey("from", equalTo: userId)
                            Query.whereKey("to", equalTo: PFUser.current()?.objectId)
                            Query.whereKey("description", equalTo: self.opis)
                            Query.whereKey("date", equalTo: self.datum)
                            Query.whereKey("location", equalTo: self.lokacija)
                            Query.findObjectsInBackground(block: { (objects, error) in
                                if error != nil {
                                    print(error?.localizedDescription)
                                }else if let object = objects {
                                    for obj in object {
                                        obj["status"] = "pending"
                                        obj["DateTime"] = DATA
                                        obj["Price"] = CENA
                                        obj.saveInBackground()
                                    }
                                }
                            })
                        }
                    }
                }
            })
            displayAlert(title: "Uspesno!", message: "Isprativte Ponuda")
        }
    }
    
    
    
    @IBAction func Odbij(_ sender: Any) {
        let query = PFUser.query()
        query?.whereKey("firstName", equalTo: Ime)
        query?.whereKey("lastName", equalTo: Prezime)
        query?.whereKey("phoneNumber", equalTo: tel)
        query?.whereKey("username", equalTo: email)
        query?.findObjectsInBackground(block: { (users, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else if let user = users{
                for u in user {
                    if let userId = u.objectId{
                        let Query = PFQuery(className: "Job")
                        Query.whereKey("from", equalTo: userId)
                        Query.whereKey("to", equalTo: PFUser.current()?.objectId)
                        Query.whereKey("description", equalTo: self.opis)
                        Query.whereKey("date", equalTo: self.datum)
                        Query.whereKey("location", equalTo: self.lokacija)
                        Query.findObjectsInBackground(block: { (objects, error) in
                            if error != nil {
                                print(error?.localizedDescription)
                            }else if let object = objects {
                                for obj in object {
                                    obj.deleteInBackground()
                                }
                            }
                        })
                    }
                }
            }
        })
        displayAlert(title: "Uspesno", message: "Go odbivte baranjeto")
    }
    
    
    func displayAlert(title: String, message: String) {
        let alertC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertC,animated: true,completion: nil)
    }
}
