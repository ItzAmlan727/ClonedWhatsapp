//
//  LoginRegisterViewController.swift
//  ClonedWhatsapp
//
//  Created by Amlan Jyoti on 24/10/21.
//

import UIKit
import FirebaseAuth

class LoginRegisterViewController: UIViewController {
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginRegisterViewController.dismisKeyboard))
        view.addGestureRecognizer(tap)

    }

   @objc func dismisKeyboard(){
        view.endEditing(true)
    }
    func cheakInput() -> Bool {
        if (emailTextfield.text!.count < 5){
            emailTextfield.backgroundColor = UIColor.init(red: 0.8, green: 0, blue: 0, alpha: 0.2)
            return false
        }else {
            emailTextfield.backgroundColor = UIColor.white
        }
        
        if (passwordTextField.text!.count < 5){
            passwordTextField.backgroundColor = UIColor.init(red: 0.8, green: 0, blue: 0, alpha: 0.2)
            return false
        }else {
            passwordTextField.backgroundColor = UIColor.white
        }
        return true
    }
    @IBAction func loginClicked(_ sender: AnyObject){

        if (!cheakInput()) {
            return
        }
        
        
        let email = emailTextfield.text
        let password = passwordTextField.text
        
        Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
            DispatchQueue.main.async {
                if let error = error {
                    Utilities().showAlert(title: "Error!", message: error.localizedDescription, vc: self)
                    self.dismiss(animated: true, completion: nil)
                    print(error.localizedDescription)
                    return
                }else {
                    print("Signed in")
                    self.dismiss(animated: true, completion: nil)
                }

            }
        }
    }
    @IBAction func registerClicked(_ sender: AnyObject){
        if (!cheakInput()) {
            return
        }
        
        let alert = UIAlertController(title: "Register", message: "Please Confirm your Password...", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Your Password Again."
            textField.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .default,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: { (action) -> Void in
            let passswordConfirm = alert.textFields![0] as UITextField
            if ((passswordConfirm.text?.isEqual(self.passwordTextField.text!)) != nil) {
                let email = self.emailTextfield.text
                let password = self.passwordTextField.text
                Auth.auth().createUser(withEmail: email!, password: password!) { (user, error) in
                    if let error = error {
                        Utilities().showAlert(title: "Error", message: error.localizedDescription, vc: self)
                        return
                    }
                    self.dismiss(animated: true, completion: nil)
                }
                
            }else {
                Utilities().showAlert(title: "Error", message: "Password did not match!", vc: self)
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func forgotPasswordClicked(_ sender: AnyObject){
        if emailTextfield.text!.isEmpty {
            Utilities().showAlert(title: "Error", message: "Please enter your valid Email.", vc: self)
        }
        if (!emailTextfield.text!.isEmpty) {
            let email = self.emailTextfield.text
            Auth.auth().sendPasswordReset(withEmail: email!) { (error) in
                if let error = error {
                    Utilities().showAlert(title: "Error", message: error.localizedDescription, vc: self)
                }
                Utilities().showAlert(title: "Success", message: "Please cheak your Email.", vc: self)
            }
        }
    }
   

}
