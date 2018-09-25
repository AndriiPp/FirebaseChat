//
//  User.swift
//  FirebaseChat
//
//  Created by Andrii Pyvovarov on 09.08.18.
//  Copyright © 2018 Andrii Pyvovarov. All rights reserved.
//

import UIKit

class User: NSObject {
    var name : String?
    var email : String?
    var imageUrl : String?
    var id : String?
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String 
        self.email = dictionary["email"] as? String
        self.imageUrl = dictionary["imageUrl"] as? String
        self.id = dictionary["Id"] as? String
    }
}
