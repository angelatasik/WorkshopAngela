//
//  BaranjaRabotiDetailsViewController.swift
//  WorkshopAngela
//
//  Created by Angela Tasikj on 12/24/20.
//  Copyright © 2020 Angela Tasikj. All rights reserved.
//

import UIKit
import Parse

class BaranjaRabotiDetailsViewController: UIViewController {

    var dataReq = NSDate()
    var MajstoId = String()
    var opis = String()
    var status = String()
    var dateFinished = NSDate()
    var imageFile = [PFFileObject]()
    var DatumPonuda = NSDate()
    var CenaPonuda = String()
    var ZakazanoNa = NSDate()
    
    @IBOutlet weak var DatumBaranje: UILabel!
    @IBOutlet weak var TipMajstor: UILabel!
    @IBOutlet weak var OpisDefekt: UILabel!
    @IBOutlet weak var ImePrezime: UILabel!
    @IBOutlet weak var Email: UILabel!
    @IBOutlet weak var Phone: UILabel!
    @IBOutlet weak var Status: UILabel!
    @IBOutlet weak var CenaP: UILabel!
    @IBOutlet weak var Cena: UILabel!
    @IBOutlet weak var DatumP: UILabel!
    @IBOutlet weak var Datum: UILabel!
    @IBOutlet weak var Zakazano: UILabel!
    @IBOutlet weak var DatumZakazano: UILabel!
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var Prifati: UIButton!
    @IBOutlet weak var Odbij: UIButton!
    
    var datumi = [NSDate]()
    var MajstoriIds = [String]()
    var statuses = [String]()
    var descriptions = [String]()
    
    @IBAction func Prifakjanje(_ sender: Any) {
        let query = PFQuery(className: "Job")
        query.whereKey("from", equalTo: PFUser.current()?.objectId)
        query.whereKey("to", equalTo: MajstoId)
        query.whereKey("description", equalTo: opis)
        query.whereKey("date", equalTo: dataReq)
        query.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else if let obj = objects {
                for o in obj {
                    o["status"] = "scheduled"
                    o.saveInBackground()
                }
            }
        })
        displayAlert(title: "Success" , message: "The job is now scheduled")
    }
    
    
    @IBAction func Odbivanje(_ sender: Any) {
        let query = PFQuery(className: "Job")
        query.whereKey("from", equalTo: PFUser.current()?.objectId)
        query.whereKey("to", equalTo: MajstoId)
        query.whereKey("description", equalTo: opis)
        query.whereKey("date", equalTo: dataReq)
        query.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else if let obj = objects {
                for o in obj {
                    o["status"] = "scheduled"
                    o.deleteInBackground()
                }
            }
        })
        if status == "active"{
            displayAlert(title: "Succes", message: "The request has been canceled")
        }else {
            displayAlert(title: "Succes", message: "The offer has been rejected")
        }
    }
    
    func displayAlert(title: String, message: String){
        let allertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(allertController,animated: true,completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OpisDefekt.text = opis
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd/MM/yyyy HH:mm"
        let stringDate = dateformatter.string(from: dataReq as Date)
        DatumBaranje.text = stringDate
        Status.text = status
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: MajstoId)
        query?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else if let object = objects{
                for o in object {
                    if let majstor = o as? PFUser {
                        if let firsName = majstor["firstName"] {
                            if let lastNAme = majstor["lastName"] {
                                if let phoneNumber = majstor["phoneNumber"]{
                                    if let email = majstor.username {
                                        if let tip = majstor["tipMajstor"]{
                                            self.ImePrezime.text = (firsName as! String)
                                            self.TipMajstor.text = (tip as! String)
                                            self.Email.text = email
                                            self.Phone.text = (phoneNumber as! String)
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
        
        if status == "active" { //aktivno baranje
           
            DatumZakazano.isHidden = true
            Zakazano.isHidden = true
            Cena.isHidden = true
            CenaP.isHidden = true
            Datum.isHidden = true
            DatumP.isHidden = true
            Image.isHidden = true
            Prifati.isHidden = true
            Odbij.setTitle("CANCEL", for: .normal)
            Odbij.isHidden = false
        }else if status == "pending" { //dobiena ponuda
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            let StringDate = dateFormatter.string(from: DatumPonuda as Date)
            Datum.text = StringDate
            Cena.text = CenaPonuda
            Datum.isHidden = false
            Cena.isHidden = false
            CenaP.isHidden = false
            DatumP.isHidden = false
            Prifati.isHidden = false
            Odbij.setTitle("Reject", for: .normal)
            Odbij.isHidden = false
            Image.isHidden = true
            Zakazano.isHidden = true
            DatumZakazano.isHidden = true
        }else if status == "scheduled" { //zakazana rabota
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            let StringDate = dateFormatter.string(from: ZakazanoNa as Date)
            DatumZakazano.text = StringDate
            Cena.isHidden = true
            CenaP.isHidden = true
            DatumP.isHidden = true
            Datum.isHidden = true
            DatumZakazano.isHidden = false
            Zakazano.isHidden = false
            Image.isHidden = true
            Prifati.isHidden = true
            Odbij.isHidden = true
        }else if status == "done" { //zavrsena rabota
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            let StringDate = dateFormatter.string(from: dateFinished as Date)
            DatumZakazano.text = StringDate
            let slika = imageFile[0]
            slika.getDataInBackground { (data, error) in
                if let imageData = data {
                    if let imageToDisplay = UIImage(data: imageData){
                        self.Image.image = imageToDisplay
                    }
                }
            }
            imageFile.removeAll()
            Cena.isHidden = true
            CenaP.isHidden = true
            DatumP.isHidden = true
            Datum.isHidden = true
            DatumZakazano.text = "Done on: "
            DatumZakazano.isHidden = false
            Zakazano.isHidden = false
            Image.isHidden = false
            Prifati.isHidden = true
            Odbij.isHidden = true
        }

    }
    


}
