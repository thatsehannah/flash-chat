//
//  UsersViewController.swift
//  Flash Chat iOS13
//
//  Created by Elliot Hannah III on 2/23/21.
//  Copyright © 2021 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class AllUsersViewController: UIViewController {

    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentUser = Auth.auth().currentUser?.email {
            saveUserToDb(currentUser)
            
            DispatchQueue.main.async {
                self.loadAllUsers(currentUser)
            }
            
        }
        
    }
    

    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func loadAllUsers(_ currentUser: String){
        db.collection(K.FStore.usersCollectionName).getDocuments { (querySnapshot, error) in
            if let e = error {
                print("There was a problem getting the users: \(e.localizedDescription)")
            } else {
                if let snapshot = querySnapshot {
                    for docs in snapshot.documents {
                        print(docs.documentID)
                    }
                }
            }
        }
    }
    
    func saveUserToDb(_ email: String) {
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
}
