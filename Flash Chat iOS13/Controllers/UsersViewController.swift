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
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    var currentUser: String = ""
    var selectedUser: String = ""
    var users: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "All Users"
        print("User View Controller Loaded.")
        tableView.dataSource = self
        tableView.delegate = self
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ChatViewController
        destinationVC.recipient = selectedUser
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

extension AllUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = users[indexPath.row]
        performSegue(withIdentifier: K.userSegue, sender: self)
    }
}
