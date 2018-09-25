//
//  Message.swift
//  FirebaseChat
//
//  Created by Andrii Pyvovarov on 16.08.18.
//  Copyright © 2018 Andrii Pyvovarov. All rights reserved.
//

import UIKit

import UIKit
import Firebase
class Message: NSObject {
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    var imageUrl : String?
    var imageWidth : NSNumber?
    var imageHeight : NSNumber?
    var videoUrl : String?
    
    init(dictionary: [String: Any]) {
        
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["text"] as? String
        self.toId = dictionary["toId"] as? String
        self.imageUrl = dictionary["imageUrl"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        self.imageWidth = dictionary["imageWidth"] as? NSNumber
        self.imageHeight = dictionary["imageHeight"] as? NSNumber
        self.videoUrl = dictionary["videoUrl"] as? String
    }
    func chatPartnerId() -> String?{
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
}
