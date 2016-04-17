//
//  TwitterServiceWrapper.swift
//  Limetray-Assisgnment
//
//  Created by Prabal Malhan on 15/04/16.
//  Copyright (c) 2016 Prabal Malhan. All rights reserved.
//

import Foundation


protocol TweetsDelegate{
    func finishedDownloading(follower:Tweets)
}


public class TwitterServiceWrapper:NSObject {
    var delegate:TweetsDelegate?
    
    let consumerKey = "Bar7t02CdVcbvOmY0lTf4uWNk"
    let consumerSecret = "hN5Gukkaq0PQbMLooIo4A47tpMdsGGHRsePoX4EjoPlUjK4ntd"
    let host = "api.twitter.com"
    
    // MARK:- Bearer Token
    func getBearerToken(completion:(bearerToken: String) ->Void) {
        
        let components = NSURLComponents() 
        components.scheme = "https";
        components.host = self.host
        components.path = "/oauth2/token";
        
        let url = components.URL;
        
        let request = NSMutableURLRequest(URL:url!)
        
        request.HTTPMethod = "POST"
        request.addValue("Basic " + getBase64EncodeString(), forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        let grantType =  "grant_type=client_credentials"
        
        request.HTTPBody = grantType.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        NSURLSession.sharedSession() .dataTaskWithRequest(request, completionHandler: { (data: NSData?, response:NSURLResponse?, error: NSError?) -> Void in
            
            let errorP = NSErrorPointer()
            
                if let results: NSDictionary = NSJSONSerialization .JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments,error: errorP  ) as? NSDictionary {
                    if let token = results["access_token"] as? String {
                        completion(bearerToken: token)
                    } else {
                        print(results["errors"])
                    }
                }
            
        }).resume()
        
    }
    
    
    // MARK:- base64Encode String
    
    func getBase64EncodeString() -> String {
        
        let consumerKeyRFC1738 = consumerKey.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())
        
        let consumerSecretRFC1738 = consumerSecret.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        let concatenateKeyAndSecret = consumerKeyRFC1738! + ":" + consumerSecretRFC1738!
        
        let secretAndKeyData = concatenateKeyAndSecret.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
        
        let base64EncodeKeyAndSecret = secretAndKeyData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        
        return base64EncodeKeyAndSecret!
    }
    
    // MARK:- Service Call
    
    func getResponseForRequest(url:String) {
        
        getBearerToken({ (bearerToken) -> Void in
            
            let request = NSMutableURLRequest(URL: NSURL(string: url)!)
            request.HTTPMethod = "GET"
            
            let token = "Bearer " + bearerToken
            
            request.addValue(token, forHTTPHeaderField: "Authorization")
            
            
            NSURLSession.sharedSession() .dataTaskWithRequest(request, completionHandler: { (data: NSData?, response:NSURLResponse?, error: NSError?) -> Void in
                self.processResult(data!, response: response!, error: error)
               
                
            }).resume()
        })
        
    }
    
    // MARK:- Process results
    
    func processResult(data: NSData, response:NSURLResponse, error: NSError?) {
        
        let errorP = NSErrorPointer()
            
        if let results: NSDictionary = NSJSONSerialization .JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments,error:errorP  ) as? NSDictionary {
            

            if let statuses = results["statuses"] as? NSArray{
                
                for status in statuses{
                  
                    if let tweet = status["text"] as? String{
                       
                        if let date = status["created_at"] as? String{
                            
                            if let id  = status["id_str"] as? String{
                                
                                var shortDate = (date as NSString).substringWithRange(NSMakeRange(8, 2))
                                let tweet = Tweets(text: tweet,date:shortDate,id:id)
                                self.delegate?.finishedDownloading(tweet)
                            }
                        }
                    }
                }

            }

        else {
                    print(results["errors"])
                }
            }
        
    }
}