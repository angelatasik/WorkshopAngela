//
//  KlientViewController.swift
//  WorkshopAngela
//
//  Created by Angela Tasikj on 12/15/20.
//  Copyright © 2020 Angela Tasikj. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse

class KlientViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {
    
    
    var firstNames = [String]()
    var lastNames = [String]()
    var place = String()
    var opis = String()
    var datumi = [NSDate]()
    var lat = Double()
    var long = Double()
    
    var MajstorIds = [String]()
    var statusi = [String]()
    var descriptions = [String]()
    
    @IBOutlet weak var OpisDefekt: UITextField!
    @IBOutlet weak var Izbor: UILabel!
    @IBOutlet weak var Elektricar: UIButton!
    @IBOutlet weak var Vodovodzija: UIButton!
    @IBOutlet weak var Moler: UIButton!
    @IBOutlet weak var Stolar: UIButton!
    @IBOutlet weak var Mapa: MKMapView!
    
    var manager = CLLocationManager()
    var locationChosen = Bool()
    
    @IBAction func LogOut(_ sender: Any) {
        PFUser.logOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func StolarButton(_ sender: Any) {
        self.Stolar.backgroundColor = UIColor.green
        Izbor.text = "Stolar"
        Moler.isHidden = true
        Elektricar.isHidden = true
        Vodovodzija.isHidden = true
    }
    
    @IBAction func VodovodzijaButton(_ sender: Any) {
        self.Vodovodzija.backgroundColor = UIColor.green
        Izbor.text = "Vodovodzija"
        Moler.isHidden = true
        Elektricar.isHidden = true
        Stolar.isHidden = true
    }
    @IBAction func ElektricarButton(_ sender: Any) {
        self.Elektricar.backgroundColor = UIColor.green
        Izbor.text = "Elektricar"
        Moler.isHidden = true
        Stolar.isHidden = true
        Vodovodzija.isHidden = true
    }
    
    @IBAction func MolerButton(_ sender: Any) {
        self.Moler.backgroundColor = UIColor.green
        Izbor.text = "Moler"
        Stolar.isHidden = true
        Elektricar.isHidden = true
        Vodovodzija.isHidden = true
    }
    
    
    @IBAction func Request(_ sender: Any) {
        self.performSegue(withIdentifier: "BaranjaRabotiSeg", sender: nil)
    }
    
    @IBAction func PrikazMajstori(_ sender: Any) {
        if !locationChosen || OpisDefekt.text == ""  || !(Izbor.text == "Moler" || Izbor.text == "Elektricar" || Izbor.text == "Vodovodzija" || Izbor.text == "Stolar"){
            DisplayAlert(title: "Nema dovolno informacii", msg: "Vnesi gi site potrebni informacii")
        }else{
            print("vlaga vo prikaz na majstori")
            firstNames.removeAll()
            lastNames.removeAll()
            
            opis = OpisDefekt.text!
            let query = PFUser.query()
            var TipMajstor = String()
            
            if Izbor.text == "Moler"{
                TipMajstor = "Moler"
            }else if Izbor.text == "Elektricar"{
                TipMajstor = "Elektricar"
            }else if Izbor.text == "Vodovodzija"{
                TipMajstor = "Vodovodzija"
            }else if Izbor.text == "Stolar"{
                TipMajstor = "Stolar"
            }
            
            query?.whereKey("tipMajstor", equalTo: TipMajstor)
            print("kreira query")
            query?.findObjectsInBackground(block: { (object, error) in
                if error != nil{
                    print(error?.localizedDescription)
                }
                else if let majstori = object{
                    for o in majstori{
                        if let majstor = o as? PFUser {
                            print("pocnuva da zima od objektot")
                            if let firstName = majstor["firstName"]{
                                if let lastName = majstor["lastName"]{
                                    print("gi stava")
                                    self.firstNames.append(firstName as! String)
                                    self.lastNames.append(lastName as! String)
                                    print("gi stavi")
                                }
                            }
                         }
                    }
                }
                self.performSegue(withIdentifier: "MajstorSeg", sender: nil)
            })
          
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MajstorSeg" {
            let destinationVC = segue.destination as! MajstoriTableViewController
            destinationVC.Iminja = firstNames
            destinationVC.Preziminja = lastNames
            destinationVC.lokacija = place
            destinationVC.opis = opis
            destinationVC.lon = long
            destinationVC.lat = lat
        }
    }
    
    func DisplayAlert(title: String, msg: String) {
        let alertCotnroller = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertCotnroller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertCotnroller,animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Izbor.isHidden = true
        
        locationChosen = false
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(longpress(gestureRecognizer:)))
            uilpgr.minimumPressDuration = 1
            Mapa.addGestureRecognizer(uilpgr)
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       // print("vlaga tukaa")
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta:  0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        self.Mapa.setRegion(region, animated: true)
       // print("se izvrsi neso")
    }
    
    @objc func longpress(gestureRecognizer: UIGestureRecognizer) {
        //print("Go registrira longpressot")
        print("longpress")
        if !locationChosen{
            print("stisnato ee")
            if gestureRecognizer.state == UIGestureRecognizer.State.began {
                let touchPoint = gestureRecognizer.location(in: self.Mapa)
                let newCoordinate = self.Mapa.convert(touchPoint, toCoordinateFrom: self.Mapa)
                let newLocation = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
                var title = ""
                CLGeocoder().reverseGeocodeLocation(newLocation, completionHandler:  { (placemarks, error) in
                    if error != nil {
                        print(error!)
                    }else{
                        if let placemark = placemarks?[0] {
                            if placemark.subThoroughfare != nil {
                                title += placemark.subThoroughfare! + " "
                            }
                            if placemark.thoroughfare != nil {
                                title += placemark.thoroughfare!
                            }
                        }
                        if title == "" {
                            title = "Added \(NSDate())"
                        }
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = newCoordinate
                        annotation.title = title
                        self.Mapa.addAnnotation(annotation)
                        self.locationChosen = true
                        print(title)

                    }
                })
            }
            }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
