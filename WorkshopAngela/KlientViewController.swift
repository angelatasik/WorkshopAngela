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
    
    
    @IBOutlet weak var OpisDefekt: UITextField!
    @IBOutlet weak var Izbor: UILabel!
    @IBOutlet weak var Elektricar: UIButton!
    @IBOutlet weak var Vodovodzija: UIButton!
    @IBOutlet weak var Moler: UIButton!
    @IBOutlet weak var Stolar: UIButton!
    @IBOutlet weak var Mapa: MKMapView!
    
    var locationManager = CLLocationManager()
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
    
    
    @IBAction func PrikazMajstori(_ sender: Any) {
        if !locationChosen || OpisDefekt.text == ""  || !(Izbor.text == "Moler" || Izbor.text == "Elektricar" || Izbor.text == "Vodovodzija" || Izbor.text == "Stolar"){
            DisplayAlert(title: "Nema dovolno informacii", msg: "Vnesi gi site potrebni informacii")
        }
        //else: segue: table view - lista majstori
    }
    
    func DisplayAlert(title: String, msg: String) {
        let alertCotnroller = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertCotnroller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertCotnroller,animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationChosen = false
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(longpress(gestureRecognizer:)))
            uilpgr.minimumPressDuration = 2
            Mapa.addGestureRecognizer(uilpgr)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @objc func longpress(gestureRecognizer: UIGestureRecognizer) {
        if !locationChosen{
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

                    }
                })
            }
            }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta:  0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        self.Mapa.setRegion(region, animated: true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
