//
//  LoginViewController.swift
//  ToDoFire
//
//  Created by Чистяков Василий Александрович on 18.12.2021.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var warnLabel: UILabel!
    @IBOutlet weak var emailTextFeald: UITextField!
    @IBOutlet weak var passwordTextFeald: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        warnLabel.alpha = 0
        ref = Database.database().reference(withPath: "users")
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user != nil {
                self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextFeald.text = ""
        passwordTextFeald.text = ""
    }
    
    func displayWarningLabel(withText text: String) {
        warnLabel.text = text
        
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseOut]) { [weak self] in
            self?.warnLabel.alpha = 1
        } completion: { [weak self ] complete in
            self?.warnLabel.alpha = 0
        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        guard let email = emailTextFeald.text, let password = passwordTextFeald.text ,email != "", password != "" else { displayWarningLabel(withText: "Info is incorrect")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error)
            in
            if error != nil {
                self?.displayWarningLabel(withText: "Error occured")
                return
            }
            if user != nil {
                self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
                return
            }
            self?.displayWarningLabel(withText: "No such user")
        }
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        guard let email = emailTextFeald.text, let password = passwordTextFeald.text ,email != "", password != "" else {
            displayWarningLabel(withText: "Info is incorrect")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self]( user, error) in
            
            guard error == nil, user != nil else {
                print(error?.localizedDescription)
                return
            }
            let userRef = self?.ref.child((user?.user.uid)!)
            userRef?.setValue(["email": (user?.user.email)!])
        }
    }
}
