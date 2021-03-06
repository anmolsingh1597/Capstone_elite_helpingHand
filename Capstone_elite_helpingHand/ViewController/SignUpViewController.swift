//
//  SignUpViewController.swift
//  Capstone_elite_helpingHand
//
//  Created by Aman Kaur on 2020-08-11.
//  Copyright © 2020 Aman Kaur. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource  {
  
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var contactNumber: UITextField!
    @IBOutlet weak var streetAddress: UITextField!
    @IBOutlet weak var postalAddress: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var radiusField: UITextField!
    var cityPicker = UIPickerView()
    var statePicker = UIPickerView()
    private var _currentSelection: Int = 0
    
    let radiusArray = ["1km", "2km", "3km", "4km", "5km", "6km", "7km", "8km", "9km", "10km"]
    
    
    let cityArrayON = [["Brampton", "Toronto", "Mississauga", "Ottawa", "Hamilton", "Kitchener", "Vaughan", "Windsor", "Markham", "London"],
                       ["Calgary", "Edmonton", "Lethbridge", "Brooks"],
                       ["Abbotsford", "Burnaby", "Vancouver", "Surrey","Richmond", "Kimberley" ,"Duncan"],
                       ["Brandon", "Winnipeg", "Thompson", "Winkler"]]
    
//    var currentSelection: Int {
//        get {
//            return _currentSelection
//        }
//        set {
//            _currentSelection = newValue
//            cityPicker.reloadAllComponents()
//            statePicker.reloadAllComponents()
//
//            radiusField.text = radiusArray[_currentSelection]
//            city.text = cityArrayON[_currentSelection][0]
//
//
//        }
//    }

    var keyboardFlag: Bool = false
    //MARK:- Firebase variables
//    var ref: DatabaseReference!
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        currentSelection = 0;

        statePicker.delegate = self
        statePicker.dataSource = self
        statePicker.tag = 0
        
        cityPicker.delegate = self
        cityPicker.dataSource = self
        cityPicker.tag = 1
        
        radiusField.inputView = statePicker
        city.inputView = cityPicker
        
        initials()
    
    }
    
    func initials(){
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        errorLabel.text = "All fields are mandatory"
        firstName.addTarget(self, action: #selector(checkAndDisplayError(textfield:)), for: UIControl.Event.editingChanged)
        emailAddress.addTarget(self, action: #selector(checkEmailAndDisplayError(textfield:)), for: UIControl.Event.editingChanged)
        password.addTarget(self, action: #selector(checkPasswordAndDisplayError(textfield:)), for: UIControl.Event.editingChanged)
        confirmPassword.addTarget(self, action: #selector(checkConfirmPasswordAndDisplayError(textfield:)), for: UIControl.Event.editingChanged)
        contactNumber.addTarget(self, action: #selector(convertStringToContactNumber(textfield:)), for: UIControl.Event.editingDidEnd)
//        contactNumber.addTarget(self, action: #selector(checkContactNumberAndDisplayError(textfield:)), for: UIControl.Event.editingChanged)
        contactNumber.keyboardType = .asciiCapableNumberPad
        
        
    }
    
    @objc func checkAndDisplayError(textfield: UITextField){
        if(textfield.text?.count ?? 0<3){
            errorLabel.text = "First Name is mandtory"
        }else{
            errorLabel.text = ""
        }
    }
    
    @objc func checkEmailAndDisplayError(textfield: UITextField){
        if(textfield.text?.isEmail() == false){
            errorLabel.text = "Invalid email address"
        }else{
            errorLabel.text = ""
        }
    }
    
    @objc func checkPasswordAndDisplayError(textfield: UITextField){
        if(textfield.text?.isPassword() == false){
                  errorLabel.text = "Must contain: 1 uppercase, 1 digit, 1 lowercase, 1 symbol and min 8 characters"
              }else{
                  errorLabel.text = ""
              }
          }
    
    @objc func checkConfirmPasswordAndDisplayError(textfield: UITextField){
        if(self.password.text != textfield.text){
               errorLabel.text = "Password doesn't match"
           }else{
               errorLabel.text = ""
           }
       }
    @objc func checkContactNumberAndDisplayError(textfield: UITextField){
        if(textfield.text?.isNumber() == false){
                  errorLabel.text = "Format: xxx-xxx-xxxx"
              }else{
                  errorLabel.text = ""
              }
          }
    @objc func convertStringToContactNumber(textfield: UITextField){
        textfield.text = textfield.text!.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "$1-$2-$3", options: .regularExpression, range: nil)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        if !self.keyboardFlag{
            self.view.frame.origin.y -= 110
            self.keyboardFlag = true
        }
    }

    @objc func keyboardWillHide(sender: NSNotification) {
        if self.keyboardFlag{
            self.view.frame.origin.y += 110
            self.keyboardFlag = false
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
          return 1
      }
      
      func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         if pickerView.tag == 0 {
               return radiusArray.count
           } else {
               return cityArrayON.count
           }
      }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       if pickerView.tag == 0 {
           return radiusArray[row]
       } else {
           return cityArrayON[0][row]
       }
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
//                currentSelection = row

               radiusField.text = radiusArray[row]
                radiusField.resignFirstResponder()
            
            } else if pickerView.tag == 1 {
                city.text = cityArrayON[0][row]
                city.resignFirstResponder()
            }
        
    }
    
    func register(email: String, password: String, credentials: [String: String?]){
             
             if email != ""{
                 
                 if password != ""{
                     
                     Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
                         
                         if err != nil{
                             
                            print(err!.localizedDescription)
                            self.displayAlertForTextFields(title: "Error!", message: "\(err!.localizedDescription)", flag: 0)
                            return
                         }
                         
                        print("success")
                        self.saveToFirebase(insert: credentials)
                     }
                 }
            
             }
         
     }
     

    @IBAction func signUpTofirebase(_ sender: UIButton) {
        let fName = self.firstName.text
        let lName = self.lastName.text
        let email = self.emailAddress.text
        let psswrd = self.password.text
        let confirmPsswrd = self.confirmPassword.text
        let contact = self.contactNumber.text
        let street = self.streetAddress.text
        let cityValue = self.city.text
        let radiusValue = self.radiusField.text
        let postalCode = self.postalAddress.text
        
        if(self.errorLabel.text?.isEmpty != true){
         displayAlertForTextFields(title: "Error", message: "Provide data in accurate format", flag: 0)
        }
        else if(fName?.isEmpty == true || lName?.isEmpty == true || email?.isEmpty == true || psswrd?.isEmpty == true || confirmPsswrd?.isEmpty == true || contact?.isEmpty == true || postalCode?.isEmpty ==  true || radiusValue?.isEmpty == true){
            displayAlertForTextFields(title: "Empty fields", message: "Required fields should be filled", flag: 0)
        }
        else if(email?.isEmail() == false){
            displayAlertForTextFields(title: "Email", message: "Invalid email address", flag: 0)
        }else if(psswrd?.isPassword() == false || confirmPsswrd?.isPassword() == false){
            displayAlertForTextFields(title: "Password", message: "Must contain: 1 uppercase, 1 digit, 1 lowercase, 1 symbol and min 8 characters", flag: 0)
        }
        else if(confirmPsswrd != psswrd){
            displayAlertForTextFields(title: "Confirm Password", message: "Password doesn't match", flag: 0)
        }
        else if(contact?.isNumber() == false){
            displayAlertForTextFields(title: "Contact", message: "Contact number should be in this format: xxx-xxx-xxxx", flag: 0)
        }
        else{
             let insert = ["firstName": fName, "lastName":lName, "email": email, "password": psswrd, "contact": contact, "street": street, "city": cityValue,"radius": radiusValue,"postal": postalCode]
            register(email: email!, password: psswrd!, credentials: insert)
        }
    }
    
    func saveToFirebase(insert: [String: String?]){
        guard let key = self.ref.child("users").childByAutoId().key else {return}
        let childUpdates = ["/users/\(key)": insert]
        self.ref.updateChildValues(childUpdates)
        DataStorage.getInstance().addUser(user: User(id: "1", firstName: insert["firstName"]! ?? "", lastName: insert["lastName"]! ?? "", mobileNumber: insert["contact"]! ?? "", emailId: insert["email"]! ?? "", password: insert["password"]! ?? "", radius: insert["radius"]! ?? "", street: insert["street"]! ?? "", postal: insert["postal"]! ?? "", city: insert["city"]! ?? ""))
           displayAlertForTextFields(title: "Success!!", message: "User successfully registered", flag: 1)
          
    }
    
    func displayAlertForTextFields(title: String, message: String, flag: Int){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if(flag == 0){
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }else if (flag == 1){
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
        }
        self.present(alert, animated: true)
    }
}

extension SignUpViewController {
    
    //MARK: hide keyboard by swiping down
    func hideKeyboardWhenTappedAround() {
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        swipe.direction = .up
        self.view.addGestureRecognizer(swipe)


    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
  
}
