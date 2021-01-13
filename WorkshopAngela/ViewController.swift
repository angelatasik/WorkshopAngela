//
//  ViewController.swift
//  WorkshopAngela
//
//  Created by Angela Tasikj on 12/12/20.
//  Copyright © 2020 Angela Tasikj. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var Majstor: UILabel!
    @IBOutlet weak var MajstorOrKlient: UISwitch!
    @IBOutlet weak var Klient: UILabel!
    
    @IBOutlet weak var Ime: UITextField!
    @IBOutlet weak var Prezime: UITextField!
    
    @IBOutlet weak var Phone: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var Email: UITextField!
    
    @IBOutlet weak var LoginOrSignup: UIButton!
    @IBOutlet weak var Switch: UIButton!
    
    
    @IBOutlet weak var Stolar: UIButton!
    @IBOutlet weak var Moler: UIButton!
    @IBOutlet weak var Elektricar: UIButton!
    @IBOutlet weak var Vodovodzija: UIButton!
    
    @IBOutlet weak var Izbor: UILabel!
    @IBOutlet weak var Izberi: UILabel!
    
    var SignUpMode = false
    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBAction func MolerButton(_ sender: Any) {
        print("goo kliknaaav")
        self.Moler.backgroundColor = UIColor.green
        Izbor.text = "Moler"
        Izberi.text = "Vasiot izbor e: "
        Stolar.isHidden = true
        Elektricar.isHidden = true
        Vodovodzija.isHidden = true
    }
    
    @IBAction func VodovodzijaButton(_ sender: Any) {
        self.Vodovodzija.backgroundColor = UIColor.green
        Izbor.text = "Vodovodzija"
        Izberi.text = "Vasiot izbor e: "
        Moler.isHidden = true
        Elektricar.isHidden = true
        Stolar.isHidden = true
    }
    @IBAction func ElektricarButton(_ sender: Any) {
        self.Elektricar.backgroundColor = UIColor.green
        Izbor.text = "Elektricar"
        Izberi.text = "Vasiot izbor e: "
        Moler.isHidden = true
        Stolar.isHidden = true
        Vodovodzija.isHidden = true
    }

    @IBAction func StolarButton(_ sender: Any) {
        self.Stolar.backgroundColor = UIColor.green
        Izbor.text = "Stolar"
        Izberi.text = "Vasiot izbor e: "
        Moler.isHidden = true
        Elektricar.isHidden = true
        Vodovodzija.isHidden = true
    }
    
    @IBAction func KlinetOrMajstor(_ sender: Any) {
        if MajstorOrKlient.isOn{
            Izberi.isHidden = true
            Izbor.isHidden = true
            Vodovodzija.isHidden = true
            Stolar.isHidden = true
            Moler.isHidden = true
            Elektricar.isHidden = true
        }else{
            Izberi.isHidden = false
            Izbor.isHidden = true
            Vodovodzija.isHidden = false
            Stolar.isHidden = false
            Moler.isHidden = false
            Elektricar.isHidden = false
        }
    }
    
    
    @IBAction func Button1(_ sender: Any) {
        if SignUpMode{
            if Email.text == "" || Password.text == "" || Phone.text == "" || Ime.text == "" || Prezime.text == "" {
                DisplayAlert(title: "Error in form", msg: "You must provide all ")
            }else{
                activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                activityIndicator.center = view.center //da vrti vo sredina
                activityIndicator.hidesWhenStopped = true // da se skrie koga ke bide prekinat activityindicator-or
                activityIndicator.style = UIActivityIndicatorView.Style.gray
                view.addSubview(activityIndicator)
                UIApplication.shared.beginIgnoringInteractionEvents() //blokirano e klikanjeto na sekoe kopce ili pole po pritiskanje na Login/SignUp za da ne se klika bilo so dr

                let user = PFUser()
                user.username = Email.text
                user.password = Password.text
                user.email = Email.text
                
                user["firstName"] = Ime.text
                user["lastName"] = Prezime.text
                user["phoneNumber"] = Phone.text

                
                if MajstorOrKlient.isOn{
                    
                    user["tipKorisnik"] = "Klient"
                    
                }else{
                    user["tipKorisnik"] = "Majstor"
                    
                    user["tipMajstor"] = Izbor.text
                    
                }
                
                user.signUpInBackground { (succes,error) in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if let error = error{
                        let errorString = error.localizedDescription
                        self.DisplayAlert(title: "Error", msg: errorString)
                    }else{
                        //print("Sign Up succes")
                        
                        if PFUser.current()!["tipKorisnik"] as! String == "Klient" {
                            self.performSegue(withIdentifier: "KorisnikSeg", sender: self)
                            print("Signed up - Klient")
                        }else{
                            self.performSegue(withIdentifier: "KonBaranja", sender: self)
                            //MajstorSeg
                            //print("Signed up- Majstor")
                        }
                        
                    }
                }

            }
        }else{
            if Email.text == "" || Password.text == ""{
                DisplayAlert(title: "Error in form", msg: "You must provide all ")
            }else{
                activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                activityIndicator.center = view.center //da vrti vo sredina
                activityIndicator.hidesWhenStopped = true // da se skrie koga ke bide prekinat activityindicator-or
                activityIndicator.style = UIActivityIndicatorView.Style.gray
                view.addSubview(activityIndicator)
                UIApplication.shared.beginIgnoringInteractionEvents() //blokirano e klikanjeto na sekoe kopce ili pole po pritiskanje na Login/SignUp za da ne se klika bilo so dr

                PFUser.logInWithUsername(inBackground: Email.text! , password: Password.text!) { (user,error) in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    if let error = error{
                        let errorString = error.localizedDescription
                        self.DisplayAlert(title: "Error", msg: errorString)
                    }else{
                        //print("LogIn succes")
                        
                        if user!["tipKorisnik"] as! String == "Klient" {
                            self.performSegue(withIdentifier: "KorisnikSeg", sender: self)
                            //print("Logged In - Korisnik")
                        }else if user!["tipKorisnik"] as! String == "Majstor" {
                            self.performSegue(withIdentifier: "KonBaranja", sender: self)
                            //print("Logged In- Majstor")
                        }

                    }
                    
                }
            }
        }
    }

 
    @IBAction func SwitchButton(_ sender: Any) {
        
        if SignUpMode {
            SignUpMode = false
            LoginOrSignup.setTitle("Login", for: .normal)
            Switch.setTitle("Switch to Sign Up", for: .normal)
            Ime.isHidden = true
            Prezime.isHidden = true
            Phone.isHidden = true
            
            Izberi.isHidden = true
            Izbor.isHidden = true
            Vodovodzija.isHidden = true
            Stolar.isHidden = true
            Moler.isHidden = true
            Elektricar.isHidden = true
            MajstorOrKlient.isHidden = true
            Majstor.isHidden = true
            Klient.isHidden = true
        }else{
            SignUpMode = true
            LoginOrSignup.setTitle("Sign Up", for: .normal)
            Switch.setTitle("Switch to Login", for: .normal)
            Ime.isHidden = false
            Prezime.isHidden = false
            Phone.isHidden = false
            MajstorOrKlient.isHidden = false
            Majstor.isHidden = false
            Klient.isHidden = false
            
            if MajstorOrKlient.isOn{
                Izberi.isHidden = true
                Izbor.isHidden = true
                Vodovodzija.isHidden = true
                Stolar.isHidden = true
                Moler.isHidden = true
                Elektricar.isHidden = true
            }else{
                Izberi.isHidden = false
                Izbor.isHidden = true
                Vodovodzija.isHidden = false
                Stolar.isHidden = false
                Moler.isHidden = false
                Elektricar.isHidden = false
            }
            
        }
    }
    
    func DisplayAlert(title: String, msg: String) {
        let alertCotnroller = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertCotnroller.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alertCotnroller,animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if SignUpMode == false{
            Ime.isHidden = true
            Prezime.isHidden=true
            Phone.isHidden = true
            
            Izberi.isHidden = true
            Izbor.isHidden = true
            Vodovodzija.isHidden = true
            Stolar.isHidden = true
            Moler.isHidden = true
            Elektricar.isHidden = true
            
            MajstorOrKlient.isHidden = true
            Majstor.isHidden = true
            Klient.isHidden = true
        }else{
            Ime.isHidden = false
            Prezime.isHidden = false
            Phone.isHidden = false
            MajstorOrKlient.isHidden = false
            Majstor.isHidden = false
            Klient.isHidden = false
            
        }
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

}
