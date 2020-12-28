//
//  RabotiDetailViewController.swift
//  WorkshopAngela
//
//  Created by Angela Tasikj on 12/27/20.
//  Copyright © 2020 Angela Tasikj. All rights reserved.
//

import UIKit
import Parse

class RabotiDetailViewController: UIViewController {
    
    var datum = NSDate()
    var status = String()
    var Id = String()
    var imageFile = [PFFileObject]()
    
    @IBOutlet weak var Data: UILabel!
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var Status: UILabel!
    @IBOutlet weak var Korisnik: UILabel!
    @IBOutlet weak var Phone: UILabel!
    @IBOutlet weak var Email: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Status.text = status
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        let StringDate = formatter.string(from: datum as Date)
        Data.text = StringDate
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: Id)
        query?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else if let object = objects {
                for o in object {
                    if let korisnik = o as? PFUser{
                        if let Ime = korisnik["firstName"] {
                            if let Prezime = korisnik["lastName"] {
                                if let phone = korisnik["phoneNumber"] {
                                    if let email = korisnik.username{
                                        self.Korisnik.text = (Ime as! String) + " " + (Prezime as! String)
                                        self.Email.text = email
                                        self.Phone.text = phone as! String
                                    }
                                }
                            }
                    }
                }
            }
            }
        })
    }
    
    @IBAction func LokacijaDefekt(_ sender: Any) {
        self.performSegue(withIdentifier: "toMap", sender: nil)
    }
    

}
