//
//  ViewController.swift
//  Limetray-Assignment
//
//  Created by Prabal Malhan on 4/16/16.
//  Copyright (c) 2016 Prabal Malhan. All rights reserved.
//

import UIKit
import SwifteriOS
import Alamofire
import Charts

class ViewController: UIViewController{
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
////        ally()
////        tweets()
////        var stat = ""
////        var errorPointer = NSErrorPointer()
////        
////        // Do any additional setup after loading the view, typically from a nib.
//    let swifter = Swifter(consumerKey: "Bar7t02CdVcbvOmY0lTf4uWNk", consumerSecret: "hN5Gukkaq0PQbMLooIo4A47tpMdsGGHRsePoX4EjoPlUjK4ntd", appOnly: true)
//        swifter.authorizeAppOnlyWithSuccess({ (accessToken, response) -> Void in
//            
//            swifter.getSearchTweetsWithQuery("limetray", geocode: nil, lang: nil, locale: nil, resultType:nil, count: 800, until: nil, sinceID: nil, maxID: nil, includeEntities: false, callback: nil, success: { (statuses, searchMetadata) -> Void in
//                if let status =  statuses as? NSDictionary{
//                    println(status)
//                }
//            }, failure: { (error) -> Void in
//                println("inside error")
//            })
//        }, failure: { (error) -> Void in
//            println("outside error")
//        })
////
//        swifter.authorizeAppOnlyWithSuccess({ (accessToken, response) -> Void in
//            if let acc = accessToken{
//                let auth = "Bearer \(acc)"
//                println(response)
//                let he = [
//                    "Authorization": auth,
//                    "Accept-Encoding": "gzip"
//                ]
//            
//           
//        
//            Alamofire.request(.GET, "https://api.twitter.com/1.1/search/tweets.json?f=tweets&vertical=default&q=%22limetray%22&src=typd",headers:he)
//                .response { request, response, data, error in
//                    println(request)
//                    println(response)
//                    println(error)
//            }
//            }
//        }, failure: { (error) -> Void in
//            println(error)
//        })
//      
    
//
    
        


    }

    func tweets(){
        
        let accessToken = "FGxT2CyPnDmmcrijH3hPSXJTkXRwObJfHashp15FlrLci"
        let headers = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
            "body":"grant_type=client_credentials",
            "host":"api.twitter.com"
        ]
        Alamofire.request(.GET, "https://api.twitter.com/1.1/search/tweets.json?f=tweets&vertical=default&q=%22limetray%22&src=typd",headers:headers)
                        .response { request, response, JSON, error in
                            println(request)
                            println(response)
                            println(JSON)
                            println(error)
                    }
        
        
    }
        func ally(){
            let consumerKey = "Bar7t02CdVcbvOmY0lTf4uWNk"
            let consUrl = consumerKey.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
            let consumerSecret = "hN5Gukkaq0PQbMLooIo4A47tpMdsGGHRsePoX4EjoPlUjK4ntd"
            let conSecUrl = consumerSecret.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
            let combined = conSecUrl! + ":" + conSecUrl!
            let base64 = combined.dataUsingEncoding(NSUTF8StringEncoding)
            let baseEncodedString =  base64!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            
            bearerToken(baseEncodedString)
            
        }
    func bearerToken(baseEncodedString:String){
        let headers = [
            "Authorization": "Basic \(baseEncodedString)",
            "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
            "Content-Length":"29",
            "Accept-Encoding":"gzip"
        ]
     
        Alamofire.request(.POST, "http://api.twitter.com/oauth2/token",parameters: ["grant_type":"client_credentials"], encoding: .URL, headers: headers)
            .responseJSON { request,response, JSON, error in
               println(request)
                println(response)
                println(JSON)
                println(error)
        }
    }
}

