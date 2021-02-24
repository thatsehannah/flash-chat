//
//  Constants.swift
//  Flash Chat iOS13
//
//  Created by Elliot Hannah III on 2/22/21.
//  Copyright © 2021 Angela Yu. All rights reserved.
//

struct K {
    static let appName = "⚡️FlashChat"
    static let chatCellIdentifier = "ReusableCell"
    static let userCellIdentifier = "UserCell"
    static let cellNibName = "MessageCell"
    static let registerSegue = "RegisterToUsers"
    static let loginSegue = "LoginToUsers"
    
    struct BrandColors {
        static let purple = "BrandPurple"
        static let lightPurple = "BrandLightPurple"
        static let blue = "BrandBlue"
        static let lighBlue = "BrandLightBlue"
    }
    
    struct FStore {
        static let messagesCollectionName = "messages"
        static let usersCollectionName = "users"
        static let usersDocument = "allusers"
        static let senderField = "sender"
        static let bodyField = "body"
        static let dateField = "date"
        static let userField = "user"
    }
}
