//
//  LimeTrayTweets.swift
//  Limetray-Assignment
//
//  Created by Prabal Malhan on 4/17/16.
//  Copyright (c) 2016 Prabal Malhan. All rights reserved.
//

import Foundation
import CoreData

@objc(LimeTrayTweets)
class LimeTrayTweets: NSManagedObject {

    @NSManaged var date: String
    @NSManaged var text: String
    @NSManaged var id: String

}
