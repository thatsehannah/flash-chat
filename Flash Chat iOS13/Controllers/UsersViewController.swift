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
    var currentUser: String = ""
    var users: [String] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "All Users"
        print("User View Controller Loaded.")
        tableView.dataSource = self
        
        loadAllUsers(currentUser)
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
                        if docs.documentID != currentUser {
                            self.users.append(docs.documentID)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        print("Reloading table data...")
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

extension AllUsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.userCellIdentifier, for: indexPath)
        cell.textLabel?.text = user
        return cell
    }
    
    
}
