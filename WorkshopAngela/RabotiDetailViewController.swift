//
//  RabotiDetailViewController.swift
//  WorkshopAngela
//
//  Created by Angela Tasikj on 12/27/20.
//  Copyright © 2020 Angela Tasikj. All rights reserved.
//

import UIKit
import Parse

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

class RabotiDetailViewController: UIViewController {
    
    var datum = NSDate()
    var status = String()
    var Ime = String()
    var Prezime = String()
    var imageFile = [PFFileObject]()
    var phone = String()
    var email = String()
    var lat = Double()
    var long = Double()
    var adresa = String()
    var jobId = String()
    var datePicker = NSDate()
    var DatumZavrsuvanje = NSDate()
    
    @IBOutlet weak var Adresa: UILabel!
    @IBOutlet weak var Data: UILabel!
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var Status: UILabel!
    @IBOutlet weak var Korisnik: UILabel!
    @IBOutlet weak var Phone: UILabel!
    @IBOutlet weak var Email: UILabel!
    @IBOutlet weak var PhotoLibrary: UIButton!
    @IBOutlet weak var Camera: UIButton!
    @IBOutlet weak var Or: UILabel!
    @IBOutlet weak var FinishDate: UILabel!
    @IBOutlet weak var SaveImage: UIButton!
    @IBOutlet weak var DateFinish: UILabel!
    @IBOutlet weak var VnesiSlika: UILabel!
    
    
    @IBAction func CameraPressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true,completion: nil)
        }else {
            let alert = UIAlertController(title: "Camera Alert", message: "No camera is avilable", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel
            ,handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func PhotoLibraryPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        Image.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func displayAlert(title: String, message: String) {
        let allertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(allertController, animated: true, completion: nil)
    }
    
    @IBAction func SavePressed(_ sender: Any) {
        if Image.image == nil {
            displayAlert(title: "Nevalidno", message: "Izberi slika")
        }else{
            let query = PFQuery(className: "Job")
            query.whereKey("objectId", equalTo: jobId)
            query.findObjectsInBackground { (objects,error) in
                if error != nil {
                    print(error?.localizedDescription)
                }else if let object = objects{
                    for obj in object {
                        obj["finishDate"] = self.datePicker
                        obj["status"] = "done"
                        if let image = self.Image.image {
                            if let imageData = image.jpeg(.medium) {
                                let imageFile = PFFileObject(name: "image.jpeg", data: imageData)
                                obj["imageFile"] = imageFile
                                obj.saveInBackground()
                            }
                        }
                    }
                }
                
            }
            displayAlert(title: "Uspesno", message: "Rabotata e zavrsena")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Korisnik.text = Ime + "" + Prezime
        Status.text = status
        Phone.text = phone
        Email.text = email
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        let StringDate = formatter.string(from: datum as Date)
        Data.text = StringDate
        let stringFDate = formatter.string(from: DatumZavrsuvanje as Date)
        Adresa.text = adresa
        if status == "scheduled" {
            FinishDate.isHidden = true
            DateFinish.isHidden = true
            Camera.isHidden = false
            Or.isHidden = false
            PhotoLibrary.isHidden = false
            SaveImage.isHidden = false
            DatePicker.datePickerMode = .date
            DatePicker.isHidden = false
            datePicker = DatePicker.date as NSDate
            VnesiSlika.isHidden = false
        }else{
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            let StringDate = formatter.string(from: datum as Date)
            FinishDate.text = StringDate
            FinishDate.isHidden = false
            Camera.isHidden = true
            Or.isHidden = true
            PhotoLibrary.isHidden = true
            SaveImage.isHidden = true
            VnesiSlika.isHidden = true
            DatePicker.isHidden = true
            imageFile[0].getDataInBackground{ (data,error) in
                if let imageDate = data {
                    if let imageToDisplay = UIImage(data: imageDate){
                    self.Image.image = imageToDisplay
                }
            }
        }
    }
    }
    
    override func prepare(for seg: UIStoryboardSegue, sender: Any?) {
        if seg.identifier == "toMap" {
            let dVC = seg.destination as! MapViewController
            dVC.lat = lat
            dVC.long = long
            dVC.lokacija = adresa
        }
    }
}
