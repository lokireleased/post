//
//  Post.swift
//  Post
//
//  Created by tyson ericksen on 11/18/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

class Post: Codable {
    
    var timestamp: TimeInterval
    var text: String
    var username: String
    
    
    init(text: String, username: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.text = text
        self.username = username
        self.timestamp = timestamp
    }
}
