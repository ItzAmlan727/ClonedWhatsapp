//
//  ViewController.swift
//  ClonedWhatsapp
//
//  Created by Amlan Jyoti on 21/10/21.
//

import UIKit
import Firebase
import FirebaseAuth


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var  tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    var messages: [DataSnapshot]! = [DataSnapshot]()
    var refrence: DatabaseReference!
    private var _referenceHandler: DatabaseHandle!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //LogOut
       /* let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error SigningOut")
        }*/
        if (Auth.auth().currentUser == nil){
            let vc = self.storyboard?.instantiateViewController(identifier: "firebaseLoginViewController")
            self.navigationController?.present(vc!,
                                               animated: true,
                                               completion: nil)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        configureDatadbase()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil);

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil);
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(ViewController.keyBoardWillShow(_:)),
//                                               name: UIResponder.keyboardWillShowNotification,
//                                               object: self.view.window)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(ViewController.keyBoardWillHide(_:)),
//                                               name: UIResponder.keyboardWillHideNotification,
//                                               object: self.view.window)
//
        
        
    }
    @objc func keyboardWillShow(_ sender: NSNotification) {
         self.view.frame.origin.y = -300 // Move view 150 points upward
    }

    @objc func keyboardWillHide(_ sender: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
    
    
//    override func viewWillDisappear(_ animated: Bool) {
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
//    }
//    @objc func keyBoardWillHide (_ sender: NSNotification) {
//        let userInfo: [AnyHashable : Any] = (sender as NSNotification).userInfo!
//        let keyBoardSize: CGSize = userInfo[UIResponder.keyboardFrameBeginUserInfoKey]! as! CGSize
//        self.view.frame.origin.y += keyBoardSize.height
//
//    }
//
//    @objc func keyBoardWillShow(_ sender: NSNotification) {
//        let userInfo: [AnyHashable : Any] = sender.userInfo!
//        let keyBoardSize: CGSize = userInfo[UIResponder.keyboardFrameBeginUserInfoKey]! as! CGSize
//        let offset: CGSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGSize
//
//        if keyBoardSize.height == offset.height {
//            if self.view.frame.origin.y == 0 {
//                UIView.animate(withDuration: 0.15) {
//                    self.view.frame.origin.y -= keyBoardSize.height
//                }
//            }
//        }else {
//            UIView.animate(withDuration: 0.15) {
//                self.view.frame.origin.y += keyBoardSize.height - offset.height
//            }
//        }
//    }
    //MARK: - For Logging Out
    @IBAction func moreButtonClicked(_ sender: AnyObject) {
        let alert = UIAlertController(title: "You want more?", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                let logVC = self.storyboard?.instantiateViewController(identifier: "firebaseLoginViewController")
                self.navigationController?.present(logVC!, animated: true) {
                    self.navigationController?.popToRootViewController(animated: false)
                    self.tabBarController?.selectedIndex = 0
                }
            }catch {
                Utilities().showAlert(title: "Error", message: "Error while logging you out", vc: self)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Showing that value in app
    func sendMessage(data: [String: String]){
        var packet = data
        packet[Constants.MessageFields.dateTime] = Utilities().getDate()
        self.refrence.childByAutoId().setValue(packet)
        
        
    }
    
    deinit {
        self.refrence.removeObserver(withHandle: _referenceHandler)
    }
    
//  MARK: -  FOR GETTIG DATA FORM DATADASE
    func configureDatadbase() {
        refrence = Database.database().reference()
        _referenceHandler = self.refrence.observe(.childAdded, with: { (snapshot) in
            self.messages.append(snapshot)
            self.tableView.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .automatic)
        })
    }
    
    
    
//  MARK: -   Textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.text?.count == 0) {
            Utilities().showAlert(title: "Invalid", message: "Please enter something before sending", vc: self)
            return true
            
        }
        let data = [Constants.MessageFields.text: textField.text! as String]
        sendMessage(data: data)
        
        print("Ended Editing")
        textField.text = ""
        self.view.endEditing(true)
        return true
    }
//  MARK: -  TableView extensions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "tableViewCell",
                                                                       for: indexPath)
        let messageSnap: DataSnapshot! = self.messages[indexPath.row]
        let message = messageSnap.value as! Dictionary<String, String>
        if let text = message[Constants.MessageFields.text] as String? {
            cell.textLabel?.text = text

        }
        if let subText = message[Constants.MessageFields.dateTime] {
            cell.detailTextLabel?.text = subText
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

}

