//
//  MapViewController.swift
//  WorkshopAngela
//
//  Created by Angela Tasikj on 12/27/20.
//  Copyright © 2020 Angela Tasikj. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var lat = Double()
    var long = Double()
    var lokacija = String()
    
    @IBOutlet weak var Mapa: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.Mapa.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = lokacija
        self.Mapa.addAnnotation(annotation)
        
    }
    

}
