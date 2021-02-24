//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var recipient: String = ""
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = recipient
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.chatCellIdentifier)
        print("Recipient: \(recipient)")
        
        //loadMessages()
        loadMessageThread(withUser: recipient)
        
        //        navigationItem.hidesBackButton = true
    }
    
    func loadMessageThread(withUser recipient: String){
        if let currentUser = Auth.auth().currentUser?.email {
            let currentThread = "\(currentUser)-\(recipient)"
            let docRef = db.collection(K.FStore.messagesCollectionName).document(currentThread)
            
            docRef.addSnapshotListener { (_, error) in
                docRef.getDocument { (document, error) in
                    self.messages = []
                    if let e = error {
                        print("There was an issue retrieving data from Firestore: \(e.localizedDescription)")
                    } else {
                        if let document = document, document.exists {
                            
                            if let data = document.data(){
                                //print("Document data: \(data)")
                                if let conversations = data[K.FStore.conversationField] as? [[String: String]] {
                                    for convo in conversations {
                                        if let senderFromFs = convo[K.FStore.senderField], let bodyFromFs = convo[K.FStore.bodyField], let dateFromFs = convo[K.FStore.dateField] {
                                            let newMessage = Message(body: bodyFromFs, dateSent: dateFromFs, sender: senderFromFs)
                                            self.messages.append(newMessage)
                                            
                                            
                                        }
                                    }
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                                    }
                                }
                                
                                
                                
                            }
                        } else {
                            print("Document does not exist")
                        }
                    }
                    
                }
            }
            
        }
        
    }
    
//    func loadMessages() {
//        db.collection(K.FStore.messagesCollectionName)
//            .order(by: K.FStore.dateField)
//            .addSnapshotListener { (querySnapshot, error) in
//                
//                self.messages = []
//                if let e = error {
//                    print("There was an issue retrieving data from Firestore: \(e.localizedDescription)")
//                } else {
//                    if let snapshotDocs = querySnapshot?.documents {
//                        for doc in snapshotDocs {
//                            let data = doc.data()
//                            if let senderFromFs = data[K.FStore.senderField] as? String, let bodyFromFs = data[K.FStore.bodyField] as? String {
//                                //                            let newMessage = Message(sender: senderFromFs, body: bodyFromFs)
//                                //                            self.messages.append(newMessage)
//                                
//                                DispatchQueue.main.async {
//                                    self.tableView.reloadData()
//                                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
//                                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//    }
    
    func updateDb(forThread threadName: String, with message: [String:String]){
        let docRef = db.collection(K.FStore.messagesCollectionName).document(threadName)
        docRef.getDocument { (documentSnapshot, error) in
            if let e = error {
                print("There as an issue in saving message to firestore: \(e.localizedDescription)")
            } else {
                if let document = documentSnapshot, document.exists {
                    docRef.updateData([K.FStore.conversationField : FieldValue.arrayUnion([message])]) { (error) in
                        if let e = error {
                            print("Something went wrong: \(e.localizedDescription)")
                        } else {
                            print("Updated successfully")
                        }
                    }
                } else {
                    docRef.setData([K.FStore.conversationField : [message]]) { (error) in
                        if let e = error {
                            print("Something went wrong: \(e.localizedDescription)")
                        } else {
                            print("Save successfully")
                        }
                    }
                    
                }
            }
        }
    }
    
    func sendMessage() {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            
            //let message = Message(body: messageBody, dateSent: Date().timeIntervalSince1970, sender: messageSender)
            let message: [String: String] = [
                K.FStore.bodyField : messageBody,
                K.FStore.dateField : "\(Date().timeIntervalSince1970)",
                K.FStore.senderField : messageSender
            ]
            
            let senderThreadName = "\(messageSender)-\(recipient)"
            updateDb(forThread: senderThreadName, with: message)
            
            let recipientThread = "\(recipient)-\(messageSender)"
            updateDb(forThread: recipientThread, with: message)
            
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        sendMessage()
        DispatchQueue.main.async {
            self.messageTextfield.text = ""
        }
        //        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
        //            db.collection(K.FStore.messagesCollectionName).addDocument(data: [
        //                K.FStore.senderField: messageSender,
        //                K.FStore.bodyField: messageBody,
        //                K.FStore.dateField: Date().timeIntervalSince1970
        //            ]) { (error) in
        //                if let e = error {
        //                    print("There was an issue saving data to firestore: \(e.localizedDescription)")
        //                } else {
        //
        //                    print("Successfully saved data.")
        //
        //                    DispatchQueue.main.async {
        //                        self.messageTextfield.text = ""
        //                    }
        //                }
        //            }
        //        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.chatCellIdentifier, for: indexPath) as! MessageCell
        cell.label?.text = message.body
        
        //This is a message from the current user.
        if message.sender == Auth.auth().currentUser?.email{
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        }
        //This is a message from another sender. 
        else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        
        return cell
    }
}


