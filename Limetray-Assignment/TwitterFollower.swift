//
//  TwitterFollowers.swift
//  Limetray-Assisgnment
//
//  Created by Ravi Shankar on 15/04/16.
//  Copyright (c) 2016 Prabal Malhan. All rights reserved.
//

import Foundation

struct TwitterFollower {
    var tweet: String?
    var created_at: String?
    var id: String?
    
    init (text: String, date: String,id:String) {
        
        self.tweet = text
        self.created_at = date
        self.id = id
//        let pictureURL = NSURL(string: url)
//        profileURL = NSData(contentsOfURL: pictureURL!)
        
    }
}