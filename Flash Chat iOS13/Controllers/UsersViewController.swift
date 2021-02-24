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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    

}
