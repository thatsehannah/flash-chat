//
//  RegisterViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            createUser(email, password)
            
        }
    }
    
    func createUser(_ email: String, _ password: String){
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let e = error {
                print(e.localizedDescription)
            } else {
                //Navigate to the ChatViewController
                self.performSegue(withIdentifier: K.registerSegue, sender: self)
            }
        }
    }
    
    func saveToDb(_ email: String){
        let user = db.collection(K.FStore.usersCollectionName).document(email)
        user.getDocument { (document, error) in
            if let doc = document, !doc.exists {
                self.db.collection(K.FStore.usersCollectionName).document(email).setData([
                    "email": email,
                    "conversations": []
                ]) { error in
                    if let e = error {
                        print("There was an error saving the user: \(e)")
                    } else {
                        print("User successfully saved.")
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let email = emailTextfield.text {
            let destinationVC = segue.destination as! AllUsersViewController
            destinationVC.currentUser = email
            
            saveToDb(email)
        }
    }
}




